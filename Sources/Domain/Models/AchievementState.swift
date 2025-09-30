import Foundation
import GRDB

/// Represents the user's state for a specific achievement.
/// - What: Tracks whether an achievement is locked/unlocked and the user's current progress toward unlocking it.
/// - Why: Separates achievement definitions (which are constant) from user-specific achievement state
///        (which changes as the user interacts with the app). This allows for efficient progress tracking
///        and real-time achievement evaluation.
/// - How: Each achievement has a corresponding AchievementState that stores unlock status, unlock date,
///        and current progress. Progress is calculated by the AchievementEvaluator and persisted here.
public struct AchievementState: Identifiable, Hashable, Codable, Sendable, FetchableRecord, PersistableRecord {
    /// Unique identifier for this achievement state record
    public let id: UUID
    
    /// Reference to the achievement definition this state belongs to
    public let achievementId: UUID
    
    /// Whether this achievement has been unlocked by the user
    public var isUnlocked: Bool
    
    /// Timestamp when the achievement was unlocked (nil if still locked)
    public var unlockedAt: Date?
    
    /// Current progress toward unlocking the achievement
    /// - Note: For count-based achievements (e.g., "Own 10 watches"), this is the current count.
    ///         For streak achievements, this is the current or best streak length.
    ///         The meaning depends on the achievement's criteria type.
    public var currentProgress: Double
    
    /// Target value required to unlock the achievement
    /// - Note: This is copied from Achievement.targetValue for convenience in queries and display.
    ///         It allows progress calculation without joining to the achievements table.
    public var progressTarget: Double
    
    /// Timestamp when this state was created
    public let createdAt: Date
    
    /// Timestamp when this state was last updated
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        achievementId: UUID,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil,
        currentProgress: Double = 0.0,
        progressTarget: Double,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.achievementId = achievementId
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        self.currentProgress = currentProgress
        self.progressTarget = progressTarget
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - GRDB Table and Column Mapping
    
    /// Specifies the exact database table name (snake_case)
    public static let databaseTableName = "user_achievement_state"
    
    /// Explicit CodingKeys to map Swift properties to snake_case database columns
    public enum CodingKeys: String, CodingKey, ColumnExpression {
        case id
        case achievementId = "achievement_id"
        case isUnlocked = "is_unlocked"
        case unlockedAt = "unlocked_at"
        case currentProgress = "current_progress"
        case progressTarget = "progress_target"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Display Helpers

public extension AchievementState {
    /// Returns a formatted progress string (e.g., "8/10" or "50/100")
    var progressString: String {
        let current = Int(currentProgress)
        let target = Int(progressTarget)
        return "\(current)/\(target)"
    }
    
    /// Returns the progress percentage as a value between 0.0 and 1.0
    var progressPercentage: Double {
        guard progressTarget > 0 else { return 0.0 }
        return min(currentProgress / progressTarget, 1.0)
    }
    
    /// Returns true if the current progress meets or exceeds the target
    var isProgressComplete: Bool {
        return currentProgress >= progressTarget
    }
}

// MARK: - Mutations

public extension AchievementState {
    /// Updates the current progress and timestamp
    mutating func updateProgress(_ newProgress: Double) {
        self.currentProgress = newProgress
        self.updatedAt = Date()
    }
    
    /// Marks the achievement as unlocked with the current timestamp
    mutating func unlock() {
        self.isUnlocked = true
        self.unlockedAt = Date()
        self.updatedAt = Date()
    }
    
    /// Creates a new state with updated progress (immutable version)
    func withProgress(_ newProgress: Double) -> AchievementState {
        var state = self
        state.updateProgress(newProgress)
        return state
    }
    
    /// Creates a new unlocked state (immutable version)
    func withUnlocked() -> AchievementState {
        var state = self
        state.unlock()
        return state
    }
}
