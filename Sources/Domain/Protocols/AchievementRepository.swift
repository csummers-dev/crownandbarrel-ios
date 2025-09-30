import Foundation

/// Repository abstraction for achievement data access and persistence.
/// - What: Provides methods to fetch achievement definitions, manage user achievement state,
///         and query achievements by various criteria.
/// - Why: Separates achievement data access from business logic, enabling testability and
///        allowing different storage implementations (GRDB, in-memory for tests, etc.).
/// - How: Implementations (e.g., AchievementRepositoryGRDB) handle the actual data persistence
///        and retrieval, while consumers work with this protocol interface.
public protocol AchievementRepository: Sendable {
    
    // MARK: - Achievement Definitions
    
    /// Fetches all achievement definitions (the 50 hardcoded achievements).
    /// - Returns: Array of all available achievements in the system
    /// - Note: Achievement definitions are constant and defined in AchievementDefinitions.swift
    func fetchAllDefinitions() async throws -> [Achievement]
    
    /// Fetches achievements filtered by category.
    /// - Parameter category: The category to filter by (e.g., .collectionSize, .wearingFrequency)
    /// - Returns: Array of achievements in the specified category
    func fetchByCategory(_ category: AchievementCategory) async throws -> [Achievement]
    
    /// Fetches a specific achievement definition by ID.
    /// - Parameter id: The unique identifier of the achievement
    /// - Returns: The achievement if found, nil otherwise
    func fetchDefinition(id: UUID) async throws -> Achievement?
    
    // MARK: - User Achievement State
    
    /// Fetches the user's state for a specific achievement.
    /// - Parameter achievementId: The ID of the achievement to fetch state for
    /// - Returns: The achievement state if it exists, nil if not yet initialized
    func fetchUserState(achievementId: UUID) async throws -> AchievementState?
    
    /// Fetches all user achievement states.
    /// - Returns: Array of all achievement states for the current user
    func fetchAllUserStates() async throws -> [AchievementState]
    
    /// Updates or creates the user's achievement state.
    /// - Parameter state: The achievement state to persist
    /// - Note: If a state with the same achievementId exists, it will be updated.
    ///         Otherwise, a new state record will be created.
    func updateUserState(_ state: AchievementState) async throws
    
    /// Batch updates multiple achievement states efficiently.
    /// - Parameter states: Array of achievement states to update
    func updateUserStates(_ states: [AchievementState]) async throws
    
    // MARK: - Filtered Queries
    
    /// Fetches all unlocked achievements for the user.
    /// - Returns: Array of achievement states where isUnlocked is true
    func fetchUnlocked() async throws -> [AchievementState]
    
    /// Fetches all locked achievements for the user.
    /// - Returns: Array of achievement states where isUnlocked is false
    func fetchLocked() async throws -> [AchievementState]
    
    // MARK: - Watch-Specific Achievements
    
    /// Fetches achievements associated with a specific watch.
    /// - Parameter watchId: The ID of the watch to fetch achievements for
    /// - Returns: Array of achievement states for achievements triggered by or related to this watch
    /// - Note: This includes achievements like "This was your 10th watch" or "Worn 50 times"
    ///         that are specifically associated with a particular watch.
    func fetchAchievementsForWatch(watchId: UUID) async throws -> [AchievementState]
    
    // MARK: - Combined Queries
    
    /// Fetches achievements with their user states in a single query.
    /// - Returns: Array of tuples containing achievement definitions and their corresponding states
    /// - Note: If a user state doesn't exist for an achievement, it may be nil or initialized with default values
    func fetchAchievementsWithStates() async throws -> [(achievement: Achievement, state: AchievementState?)]
    
    /// Fetches unlocked achievements with their definitions.
    /// - Returns: Array of tuples containing unlocked achievement states and their definitions
    func fetchUnlockedWithDefinitions() async throws -> [(achievement: Achievement, state: AchievementState)]
    
    /// Fetches locked achievements with their definitions.
    /// - Returns: Array of tuples containing locked achievement states and their definitions
    func fetchLockedWithDefinitions() async throws -> [(achievement: Achievement, state: AchievementState)]
    
    // MARK: - Initialization
    
    /// Initializes achievement states for all achievements if they don't exist.
    /// - Note: This should be called on first launch or when new achievements are added.
    ///         Creates initial AchievementState records with isUnlocked=false and currentProgress=0
    ///         for any achievements that don't have user state yet.
    func initializeUserStates() async throws
    
    /// Deletes all user achievement states (for testing or data reset).
    /// - Warning: This is a destructive operation that cannot be undone.
    func deleteAllUserStates() async throws
}

// MARK: - Default Implementations

public extension AchievementRepository {
    /// Convenience method to check if a specific achievement is unlocked.
    /// - Parameter achievementId: The ID of the achievement to check
    /// - Returns: True if the achievement is unlocked, false otherwise
    func isAchievementUnlocked(achievementId: UUID) async throws -> Bool {
        guard let state = try await fetchUserState(achievementId: achievementId) else {
            return false
        }
        return state.isUnlocked
    }
    
    /// Convenience method to get the progress for a specific achievement.
    /// - Parameter achievementId: The ID of the achievement to get progress for
    /// - Returns: The current progress value, or 0.0 if state doesn't exist
    func getProgress(for achievementId: UUID) async throws -> Double {
        guard let state = try await fetchUserState(achievementId: achievementId) else {
            return 0.0
        }
        return state.currentProgress
    }
}
