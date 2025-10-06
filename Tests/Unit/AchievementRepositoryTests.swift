import XCTest
@testable import CrownAndBarrel
import GRDB

/// Unit tests for AchievementRepositoryGRDB.
/// Tests cover persistence, querying, filtering, and state management.
final class AchievementRepositoryTests: XCTestCase {
    
    var inMemoryDB: DatabaseQueue!
    var repository: AchievementRepositoryGRDB!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory database for testing
        inMemoryDB = try DatabaseQueue()
        
        // Run migrations
        var migrator = DatabaseMigrator()
        migrator.registerMigration("test_schema") { db in
            // Achievement tables
            try db.create(table: "achievements") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("description", .text).notNull()
                t.column("image_asset_name", .text).notNull()
                t.column("category", .text).notNull()
                t.column("criteria_json", .text).notNull()
                t.column("target_value", .double).notNull()
                t.column("created_at", .text).notNull()
            }
            
            try db.create(table: "user_achievement_state") { t in
                t.column("id", .text).primaryKey()
                // Note: No FK here because several tests use ad-hoc achievements; production uses definitions
                t.column("achievement_id", .text).notNull().indexed()
                t.column("is_unlocked", .integer).notNull().defaults(to: 0)
                t.column("unlocked_at", .text)
                t.column("current_progress", .double).notNull().defaults(to: 0.0)
                t.column("progress_target", .double).notNull()
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
            }
            
            try db.create(index: "idx_user_achievement_state_unlocked", on: "user_achievement_state", columns: ["is_unlocked"])
            try db.create(index: "idx_user_achievement_state_achievement_id", on: "user_achievement_state", columns: ["achievement_id"])
        }
        
        try migrator.migrate(inMemoryDB)
        
        // Seed achievement definitions so FK constraints succeed during tests
        try await inMemoryDB.write { db in
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.withoutEscapingSlashes]
            for a in AchievementDefinitions.all {
                let criteriaData = try encoder.encode(a.unlockCriteria)
                guard let criteriaJSON = String(data: criteriaData, encoding: .utf8) else { continue }
                try db.execute(
                    sql: """
                        INSERT INTO achievements (
                            id, name, description, image_asset_name, category,
                            criteria_json, target_value, created_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    arguments: [
                        a.id.uuidString,
                        a.name,
                        a.description,
                        a.imageAssetName,
                        a.category.rawValue,
                        criteriaJSON,
                        a.targetValue,
                        ISO8601.string(from: Date())
                    ]
                )
            }
        }
        
        repository = AchievementRepositoryGRDB(dbQueue: inMemoryDB)
    }
    
    override func tearDown() async throws {
        inMemoryDB = nil
        repository = nil
        try await super.tearDown()
    }
    
    // MARK: - Achievement Definition Tests
    
    func testFetchAllDefinitions() async throws {
        let definitions = try await repository.fetchAllDefinitions()
        
        XCTAssertEqual(definitions.count, 50, "Should have all 50 achievement definitions")
    }
    
    func testFetchByCategory() async throws {
        let collectionSizeAchievements = try await repository.fetchByCategory(.collectionSize)
        
        XCTAssertEqual(collectionSizeAchievements.count, 10, "Should have 10 collection size achievements")
        XCTAssertTrue(collectionSizeAchievements.allSatisfy { $0.category == .collectionSize })
    }
    
    func testFetchAllCategoriesHaveTenAchievements() async throws {
        for category in AchievementCategory.allCases {
            let achievements = try await repository.fetchByCategory(category)
            XCTAssertEqual(achievements.count, 10, "Category \(category) should have 10 achievements")
        }
    }
    
    func testFetchDefinitionById() async throws {
        // Get first achievement
        let allDefinitions = try await repository.fetchAllDefinitions()
        guard let first = allDefinitions.first else {
            XCTFail("No achievements found")
            return
        }
        
        let fetched = try await repository.fetchDefinition(id: first.id)
        
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, first.id)
        XCTAssertEqual(fetched?.name, first.name)
    }
    
    func testFetchDefinitionByIdNonExistent() async throws {
        let randomId = UUID()
        let fetched = try await repository.fetchDefinition(id: randomId)
        
        XCTAssertNil(fetched)
    }
    
    // MARK: - User Achievement State Persistence Tests (Task 7.9)
    
    func testCreateUserState() async throws {
        let achievementId = UUID()
        let state = AchievementState(
            achievementId: achievementId,
            isUnlocked: false,
            currentProgress: 5,
            progressTarget: 10
        )
        
        // Create state
        try await repository.updateUserState(state)
        
        // Fetch back
        let fetched = try await repository.fetchUserState(achievementId: achievementId)
        
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.achievementId, achievementId)
        XCTAssertEqual(fetched?.currentProgress, 5)
        XCTAssertEqual(fetched?.progressTarget, 10)
        XCTAssertFalse(fetched?.isUnlocked ?? true)
        XCTAssertNil(fetched?.unlockedAt)
    }
    
    func testUpdateUserState() async throws {
        let achievementId = UUID()
        let state = AchievementState(
            achievementId: achievementId,
            isUnlocked: false,
            currentProgress: 5,
            progressTarget: 10
        )
        
        // Create initial state
        try await repository.updateUserState(state)
        
        // Update progress
        var updatedState = state
        updatedState.updateProgress(8)
        try await repository.updateUserState(updatedState)
        
        // Fetch back
        let fetched = try await repository.fetchUserState(achievementId: achievementId)
        
        XCTAssertEqual(fetched?.currentProgress, 8)
        XCTAssertEqual(fetched?.id, state.id, "Should update same record, not create new one")
    }
    
    func testUpdateUserStateUnlock() async throws {
        let achievementId = UUID()
        var state = AchievementState(
            achievementId: achievementId,
            isUnlocked: false,
            currentProgress: 10,
            progressTarget: 10
        )
        
        // Create initial state
        try await repository.updateUserState(state)
        
        // Unlock achievement
        state.unlock()
        try await repository.updateUserState(state)
        
        // Fetch back
        let fetched = try await repository.fetchUserState(achievementId: achievementId)
        
        XCTAssertTrue(fetched?.isUnlocked ?? false)
        XCTAssertNotNil(fetched?.unlockedAt)
    }
    
    func testFetchAllUserStates() async throws {
        // Create multiple states
        for i in 0..<5 {
            let state = AchievementState(
                achievementId: UUID(),
                currentProgress: Double(i),
                progressTarget: 10
            )
            try await repository.updateUserState(state)
        }
        
        let allStates = try await repository.fetchAllUserStates()
        
        XCTAssertEqual(allStates.count, 5)
    }
    
    func testBatchUpdateUserStates() async throws {
        var states: [AchievementState] = []
        for i in 0..<10 {
            let state = AchievementState(
                achievementId: UUID(),
                currentProgress: Double(i),
                progressTarget: 10
            )
            states.append(state)
        }
        
        // Batch update
        try await repository.updateUserStates(states)
        
        // Fetch all
        let fetched = try await repository.fetchAllUserStates()
        
        XCTAssertEqual(fetched.count, 10)
    }
    
    // MARK: - Filtering Tests (Task 7.10)
    
    func testFetchUnlockedOnly() async throws {
        // Create mix of locked and unlocked states
        for i in 0..<10 {
            var state = AchievementState(
                achievementId: UUID(),
                currentProgress: Double(i),
                progressTarget: 10
            )
            
            // Unlock half of them
            if i % 2 == 0 {
                state.unlock()
            }
            
            try await repository.updateUserState(state)
        }
        
        let unlocked = try await repository.fetchUnlocked()
        
        XCTAssertEqual(unlocked.count, 5, "Should have 5 unlocked achievements")
        XCTAssertTrue(unlocked.allSatisfy { $0.isUnlocked })
    }
    
    func testFetchLockedOnly() async throws {
        // Create mix of locked and unlocked states
        for i in 0..<10 {
            var state = AchievementState(
                achievementId: UUID(),
                currentProgress: Double(i),
                progressTarget: 10
            )
            
            // Unlock half of them
            if i % 2 == 0 {
                state.unlock()
            }
            
            try await repository.updateUserState(state)
        }
        
        let locked = try await repository.fetchLocked()
        
        XCTAssertEqual(locked.count, 5, "Should have 5 locked achievements")
        XCTAssertTrue(locked.allSatisfy { !$0.isUnlocked })
    }
    
    func testFetchByCategoryFiltersCorrectly() async throws {
        let collectionAchievements = try await repository.fetchByCategory(.collectionSize)
        let wearingAchievements = try await repository.fetchByCategory(.wearingFrequency)
        let consistencyAchievements = try await repository.fetchByCategory(.consistency)
        let diversityAchievements = try await repository.fetchByCategory(.diversity)
        let specialAchievements = try await repository.fetchByCategory(.specialOccasions)
        
        // Verify each category has correct achievements
        XCTAssertTrue(collectionAchievements.allSatisfy { $0.category == .collectionSize })
        XCTAssertTrue(wearingAchievements.allSatisfy { $0.category == .wearingFrequency })
        XCTAssertTrue(consistencyAchievements.allSatisfy { $0.category == .consistency })
        XCTAssertTrue(diversityAchievements.allSatisfy { $0.category == .diversity })
        XCTAssertTrue(specialAchievements.allSatisfy { $0.category == .specialOccasions })
        
        // Verify all categories sum to 50
        let total = collectionAchievements.count + wearingAchievements.count +
                    consistencyAchievements.count + diversityAchievements.count +
                    specialAchievements.count
        XCTAssertEqual(total, 50)
    }
    
    // MARK: - Combined Query Tests
    
    func testFetchAchievementsWithStates() async throws {
        // Initialize states for all achievements
        try await repository.initializeUserStates()
        
        let combined = try await repository.fetchAchievementsWithStates()
        
        XCTAssertEqual(combined.count, 50, "Should have 50 achievement-state pairs")
        
        // All should have states
        for item in combined {
            XCTAssertNotNil(item.state, "All achievements should have states after initialization")
        }
    }
    
    func testFetchUnlockedWithDefinitions() async throws {
        // Initialize states
        try await repository.initializeUserStates()
        
        // Unlock a few achievements
        let allStates = try await repository.fetchAllUserStates()
        for i in 0..<3 {
            var state = allStates[i]
            state.unlock()
            try await repository.updateUserState(state)
        }
        
        let unlocked = try await repository.fetchUnlockedWithDefinitions()
        
        XCTAssertEqual(unlocked.count, 3)
        for item in unlocked {
            XCTAssertTrue(item.state.isUnlocked)
            XCTAssertEqual(item.achievement.id, item.state.achievementId)
        }
    }
    
    func testFetchLockedWithDefinitions() async throws {
        // Initialize states
        try await repository.initializeUserStates()
        
        // Unlock a few achievements
        let allStates = try await repository.fetchAllUserStates()
        for i in 0..<3 {
            var state = allStates[i]
            state.unlock()
            try await repository.updateUserState(state)
        }
        
        let locked = try await repository.fetchLockedWithDefinitions()
        
        XCTAssertEqual(locked.count, 47, "Should have 47 locked achievements (50 - 3 unlocked)")
        for item in locked {
            XCTAssertFalse(item.state.isUnlocked)
            XCTAssertEqual(item.achievement.id, item.state.achievementId)
        }
    }
    
    // MARK: - Initialization Tests
    
    func testInitializeUserStates() async throws {
        // Should start with no states
        var allStates = try await repository.fetchAllUserStates()
        XCTAssertEqual(allStates.count, 0)
        
        // Initialize
        try await repository.initializeUserStates()
        
        // Should now have 50 states (one for each achievement)
        allStates = try await repository.fetchAllUserStates()
        XCTAssertEqual(allStates.count, 50)
        
        // All should be locked initially
        XCTAssertTrue(allStates.allSatisfy { !$0.isUnlocked })
        XCTAssertTrue(allStates.allSatisfy { $0.currentProgress == 0 })
    }
    
    func testInitializeUserStatesIdempotent() async throws {
        // Initialize once
        try await repository.initializeUserStates()
        let firstCount = try await repository.fetchAllUserStates().count
        
        // Initialize again
        try await repository.initializeUserStates()
        let secondCount = try await repository.fetchAllUserStates().count
        
        // Should not create duplicates
        XCTAssertEqual(firstCount, secondCount)
        XCTAssertEqual(firstCount, 50)
    }
    
    func testInitializeUserStatesPreservesExisting() async throws {
        // Create and unlock one state
        let achievement = try await repository.fetchAllDefinitions().first!
        var state = AchievementState(achievementId: achievement.id, progressTarget: achievement.targetValue)
        state.unlock()
        try await repository.updateUserState(state)
        
        // Initialize (should create others but not overwrite this one)
        try await repository.initializeUserStates()
        
        // Fetch the state we unlocked
        let fetchedState = try await repository.fetchUserState(achievementId: achievement.id)
        
        XCTAssertTrue(fetchedState?.isUnlocked ?? false, "Should preserve unlocked state")
        XCTAssertEqual(fetchedState?.id, state.id, "Should be the same record")
    }
    
    func testDeleteAllUserStates() async throws {
        // Initialize states
        try await repository.initializeUserStates()
        
        var allStates = try await repository.fetchAllUserStates()
        XCTAssertEqual(allStates.count, 50)
        
        // Delete all
        try await repository.deleteAllUserStates()
        
        allStates = try await repository.fetchAllUserStates()
        XCTAssertEqual(allStates.count, 0)
    }
    
    // MARK: - State Persistence Tests
    
    func testUserStateRoundTrip() async throws {
        let achievementId = UUID()
        let originalState = AchievementState(
            id: UUID(),
            achievementId: achievementId,
            isUnlocked: true,
            unlockedAt: Date(),
            currentProgress: 25.5,
            progressTarget: 50.0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Persist
        try await repository.updateUserState(originalState)
        
        // Retrieve
        let retrieved = try await repository.fetchUserState(achievementId: achievementId)
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, originalState.id)
        XCTAssertEqual(retrieved?.achievementId, originalState.achievementId)
        XCTAssertEqual(retrieved?.isUnlocked, originalState.isUnlocked)
        XCTAssertEqual(retrieved?.currentProgress, originalState.currentProgress)
        XCTAssertEqual(retrieved?.progressTarget, originalState.progressTarget)
    }
    
    func testUserStateUpsertBehavior() async throws {
        let achievementId = UUID()
        let state = AchievementState(
            achievementId: achievementId,
            currentProgress: 5,
            progressTarget: 10
        )
        
        // First update (insert)
        try await repository.updateUserState(state)
        let firstFetch = try await repository.fetchUserState(achievementId: achievementId)
        XCTAssertEqual(firstFetch?.currentProgress, 5)
        
        // Second update (update existing)
        var updatedState = state
        updatedState.updateProgress(8)
        try await repository.updateUserState(updatedState)
        
        let secondFetch = try await repository.fetchUserState(achievementId: achievementId)
        XCTAssertEqual(secondFetch?.currentProgress, 8)
        XCTAssertEqual(secondFetch?.id, state.id, "Should update same record")
        
        // Should still only have one record
        let allStates = try await repository.fetchAllUserStates()
        let matchingStates = allStates.filter { $0.achievementId == achievementId }
        XCTAssertEqual(matchingStates.count, 1)
    }
    
    func testFetchUserStateNonExistent() async throws {
        let randomAchievementId = UUID()
        let fetched = try await repository.fetchUserState(achievementId: randomAchievementId)
        
        XCTAssertNil(fetched)
    }
    
    func testUnlockedStatesPersistCorrectly() async throws {
        let achievementId = UUID()
        var state = AchievementState(
            achievementId: achievementId,
            currentProgress: 10,
            progressTarget: 10
        )
        
        // Unlock
        state.unlock()
        try await repository.updateUserState(state)
        
        // Fetch back
        let fetched = try await repository.fetchUserState(achievementId: achievementId)
        
        XCTAssertTrue(fetched?.isUnlocked ?? false)
        XCTAssertNotNil(fetched?.unlockedAt)
    }
    
    // MARK: - Default Implementation Tests
    
    func testIsAchievementUnlocked() async throws {
        let achievementId = UUID()
        var state = AchievementState(achievementId: achievementId, progressTarget: 10)
        
        // Create locked state
        try await repository.updateUserState(state)
        
        var isUnlocked = try await repository.isAchievementUnlocked(achievementId: achievementId)
        XCTAssertFalse(isUnlocked)
        
        // Unlock it
        state.unlock()
        try await repository.updateUserState(state)
        
        isUnlocked = try await repository.isAchievementUnlocked(achievementId: achievementId)
        XCTAssertTrue(isUnlocked)
    }
    
    func testGetProgress() async throws {
        let achievementId = UUID()
        let state = AchievementState(
            achievementId: achievementId,
            currentProgress: 7.5,
            progressTarget: 10
        )
        
        try await repository.updateUserState(state)
        
        let progress = try await repository.getProgress(for: achievementId)
        XCTAssertEqual(progress, 7.5)
    }
    
    func testGetProgressNonExistent() async throws {
        let randomId = UUID()
        let progress = try await repository.getProgress(for: randomId)
        
        XCTAssertEqual(progress, 0.0, "Non-existent state should return 0 progress")
    }
    
    // MARK: - Data Integrity Tests
    
    func testAchievementIdsAreUnique() async throws {
        let allDefinitions = try await repository.fetchAllDefinitions()
        let uniqueIds = Set(allDefinitions.map { $0.id })
        
        XCTAssertEqual(uniqueIds.count, allDefinitions.count, "All achievement IDs should be unique")
    }
    
    func testAchievementNamesAreUnique() async throws {
        let allDefinitions = try await repository.fetchAllDefinitions()
        let uniqueNames = Set(allDefinitions.map { $0.name })
        
        XCTAssertEqual(uniqueNames.count, allDefinitions.count, "All achievement names should be unique")
    }
    
    func testAchievementImageNamesAreUnique() async throws {
        let allDefinitions = try await repository.fetchAllDefinitions()
        let uniqueImageNames = Set(allDefinitions.map { $0.imageAssetName })
        
        XCTAssertEqual(uniqueImageNames.count, allDefinitions.count, "All achievement image names should be unique")
    }
    
    func testAchievementImageNamesFollowNamingConvention() async throws {
        let allDefinitions = try await repository.fetchAllDefinitions()
        
        for achievement in allDefinitions {
            XCTAssertTrue(
                achievement.imageAssetName.hasPrefix("achievement_"),
                "Image name '\(achievement.imageAssetName)' should start with 'achievement_'"
            )
        }
    }
    
    func testAllAchievementsHaveValidTargetValues() async throws {
        let allDefinitions = try await repository.fetchAllDefinitions()
        
        for achievement in allDefinitions {
            XCTAssertGreaterThan(achievement.targetValue, 0, "\(achievement.name) should have positive target value")
        }
    }
}
