import Foundation
import GRDB

/// GRDB implementation of the AchievementRepository protocol.
/// - What: Provides persistence for achievement definitions and user achievement state using GRDB.
/// - Why: Enables efficient querying and updating of achievement data with proper indexing and
///        transaction support for real-time achievement evaluation.
/// - How: Achievement definitions are stored in the achievements table (seeded from AchievementDefinitions),
///        and user progress is tracked in the user_achievement_state table.
public final class AchievementRepositoryGRDB: AchievementRepository {
    private let dbQueue: DatabaseQueue
    
    public init(dbQueue: DatabaseQueue = AppDatabase.shared.dbQueue) {
        self.dbQueue = dbQueue
    }
    
    // MARK: - Achievement Definitions
    
    public func fetchAllDefinitions() async throws -> [Achievement] {
        return AchievementDefinitions.all
    }
    
    public func fetchByCategory(_ category: AchievementCategory) async throws -> [Achievement] {
        return AchievementDefinitions.achievements(in: category)
    }
    
    public func fetchDefinition(id: UUID) async throws -> Achievement? {
        return AchievementDefinitions.achievement(withId: id)
    }
    
    // MARK: - User Achievement State
    
    public func fetchUserState(achievementId: UUID) async throws -> AchievementState? {
        return try await dbQueue.read { db in
            guard let row = try Row.fetchOne(
                db,
                sql: "SELECT * FROM user_achievement_state WHERE achievement_id = ?",
                arguments: [achievementId.uuidString]
            ) else {
                return nil
            }
            return try self.inflateState(from: row)
        }
    }
    
    public func fetchAllUserStates() async throws -> [AchievementState] {
        return try await dbQueue.read { db in
            let rows = try Row.fetchAll(db, sql: "SELECT * FROM user_achievement_state")
            return try rows.map { try self.inflateState(from: $0) }
        }
    }
    
    public func updateUserState(_ state: AchievementState) async throws {
        try await dbQueue.write { db in
            // Check if state already exists
            let exists = try Bool.fetchOne(
                db,
                sql: "SELECT COUNT(*) > 0 FROM user_achievement_state WHERE id = ?",
                arguments: [state.id.uuidString]
            ) ?? false
            
            if exists {
                // Update existing state
                try db.execute(
                    sql: """
                        UPDATE user_achievement_state SET
                            achievement_id = ?,
                            is_unlocked = ?,
                            unlocked_at = ?,
                            current_progress = ?,
                            progress_target = ?,
                            updated_at = ?
                        WHERE id = ?
                    """,
                    arguments: [
                        state.achievementId.uuidString,
                        state.isUnlocked ? 1 : 0,
                        state.unlockedAt.map(ISO8601.string(from:)),
                        state.currentProgress,
                        state.progressTarget,
                        ISO8601.string(from: state.updatedAt),
                        state.id.uuidString
                    ]
                )
            } else {
                // Insert new state
                try db.execute(
                    sql: """
                        INSERT INTO user_achievement_state (
                            id, achievement_id, is_unlocked, unlocked_at,
                            current_progress, progress_target, created_at, updated_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    arguments: [
                        state.id.uuidString,
                        state.achievementId.uuidString,
                        state.isUnlocked ? 1 : 0,
                        state.unlockedAt.map(ISO8601.string(from:)),
                        state.currentProgress,
                        state.progressTarget,
                        ISO8601.string(from: state.createdAt),
                        ISO8601.string(from: state.updatedAt)
                    ]
                )
            }
        }
    }
    
    public func updateUserStates(_ states: [AchievementState]) async throws {
        try await dbQueue.write { db in
            for state in states {
                // Check if state already exists
                let exists = try Bool.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) > 0 FROM user_achievement_state WHERE id = ?",
                    arguments: [state.id.uuidString]
                ) ?? false
                
                if exists {
                    // Update existing state
                    try db.execute(
                        sql: """
                            UPDATE user_achievement_state SET
                                achievement_id = ?,
                                is_unlocked = ?,
                                unlocked_at = ?,
                                current_progress = ?,
                                progress_target = ?,
                                updated_at = ?
                            WHERE id = ?
                        """,
                        arguments: [
                            state.achievementId.uuidString,
                            state.isUnlocked ? 1 : 0,
                            state.unlockedAt.map(ISO8601.string(from:)),
                            state.currentProgress,
                            state.progressTarget,
                            ISO8601.string(from: state.updatedAt),
                            state.id.uuidString
                        ]
                    )
                } else {
                    // Insert new state
                    try db.execute(
                        sql: """
                            INSERT INTO user_achievement_state (
                                id, achievement_id, is_unlocked, unlocked_at,
                                current_progress, progress_target, created_at, updated_at
                            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        arguments: [
                            state.id.uuidString,
                            state.achievementId.uuidString,
                            state.isUnlocked ? 1 : 0,
                            state.unlockedAt.map(ISO8601.string(from:)),
                            state.currentProgress,
                            state.progressTarget,
                            ISO8601.string(from: state.createdAt),
                            ISO8601.string(from: state.updatedAt)
                        ]
                    )
                }
            }
        }
    }
    
    // MARK: - Filtered Queries
    
    public func fetchUnlocked() async throws -> [AchievementState] {
        return try await dbQueue.read { db in
            let rows = try Row.fetchAll(
                db,
                sql: "SELECT * FROM user_achievement_state WHERE is_unlocked = 1 ORDER BY unlocked_at DESC"
            )
            return try rows.map { try self.inflateState(from: $0) }
        }
    }
    
    public func fetchLocked() async throws -> [AchievementState] {
        return try await dbQueue.read { db in
            let rows = try Row.fetchAll(
                db,
                sql: "SELECT * FROM user_achievement_state WHERE is_unlocked = 0 ORDER BY current_progress DESC"
            )
            return try rows.map { try self.inflateState(from: $0) }
        }
    }
    
    // MARK: - Watch-Specific Achievements
    
    public func fetchAchievementsForWatch(watchId: UUID) async throws -> [AchievementState] {
        // For now, return empty array - will be enhanced when we track watch-specific achievements
        // This would require additional tracking of which watch triggered which achievement
        return []
    }
    
    // MARK: - Combined Queries
    
    public func fetchAchievementsWithStates() async throws -> [(achievement: Achievement, state: AchievementState?)] {
        let allDefinitions = AchievementDefinitions.all
        let allStates = try await fetchAllUserStates()
        
        // Create a dictionary for efficient lookups
        let statesByAchievementId = Dictionary(
            uniqueKeysWithValues: allStates.map { ($0.achievementId, $0) }
        )
        
        return allDefinitions.map { achievement in
            (achievement: achievement, state: statesByAchievementId[achievement.id])
        }
    }
    
    public func fetchUnlockedWithDefinitions() async throws -> [(achievement: Achievement, state: AchievementState)] {
        let unlockedStates = try await fetchUnlocked()
        let allDefinitions = AchievementDefinitions.all
        
        // Create a dictionary for efficient lookups
        let definitionsByAchievementId = Dictionary(
            uniqueKeysWithValues: allDefinitions.map { ($0.id, $0) }
        )
        
        return unlockedStates.compactMap { state in
            guard let achievement = definitionsByAchievementId[state.achievementId] else {
                return nil
            }
            return (achievement: achievement, state: state)
        }
    }
    
    public func fetchLockedWithDefinitions() async throws -> [(achievement: Achievement, state: AchievementState)] {
        let lockedStates = try await fetchLocked()
        let allDefinitions = AchievementDefinitions.all
        
        // Create a dictionary for efficient lookups
        let definitionsByAchievementId = Dictionary(
            uniqueKeysWithValues: allDefinitions.map { ($0.id, $0) }
        )
        
        return lockedStates.compactMap { state in
            guard let achievement = definitionsByAchievementId[state.achievementId] else {
                return nil
            }
            return (achievement: achievement, state: state)
        }
    }
    
    // MARK: - Initialization
    
    public func initializeUserStates() async throws {
        let allDefinitions = AchievementDefinitions.all
        let existingStates = try await fetchAllUserStates()
        let existingAchievementIds = Set(existingStates.map { $0.achievementId })
        
        // Create states for achievements that don't have user state yet
        let newStates = allDefinitions
            .filter { !existingAchievementIds.contains($0.id) }
            .map { achievement in
                AchievementState(
                    achievementId: achievement.id,
                    isUnlocked: false,
                    unlockedAt: nil,
                    currentProgress: 0.0,
                    progressTarget: achievement.targetValue
                )
            }
        
        if !newStates.isEmpty {
            try await updateUserStates(newStates)
        }
    }
    
    public func deleteAllUserStates() async throws {
        try await dbQueue.write { db in
            try db.execute(sql: "DELETE FROM user_achievement_state")
        }
    }
    
    // MARK: - Private Helpers
    
    private func inflateState(from row: Row) throws -> AchievementState {
        let id = UUID(uuidString: row["id"]) ?? UUID()
        let achievementId = UUID(uuidString: row["achievement_id"]) ?? UUID()
        let isUnlocked = (row["is_unlocked"] as Int) == 1
        let unlockedAt = (row["unlocked_at"] as String?).flatMap(ISO8601.date(from:))
        let currentProgress: Double = row["current_progress"]
        let progressTarget: Double = row["progress_target"]
        let createdAt = ISO8601.date(from: row["created_at"]) ?? Date()
        let updatedAt = ISO8601.date(from: row["updated_at"]) ?? Date()
        
        return AchievementState(
            id: id,
            achievementId: achievementId,
            isUnlocked: isUnlocked,
            unlockedAt: unlockedAt,
            currentProgress: currentProgress,
            progressTarget: progressTarget,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
