import Foundation

/// Represents an achievement definition in the Crown & Barrel achievements system.
/// - What: Defines a single achievement with its criteria, metadata, and display properties.
/// - Why: Achievements gamify the watch collecting experience and provide visual recognition
///        of collecting habits, wearing patterns, and collection growth milestones.
/// - How: Each achievement has unique criteria (e.g., "Own 10 watches"), a category,
///        target value for progress tracking, and an associated image asset.
public struct Achievement: Identifiable, Hashable, Codable, Sendable {
    /// Unique identifier for the achievement
    public let id: UUID

    /// Display name of the achievement (e.g., "Serious Collector")
    public let name: String

    /// Detailed description of the achievement (e.g., "Own 10 watches")
    public let description: String

    /// Asset catalog name for the achievement's trophy/badge image
    public let imageAssetName: String

    /// Category this achievement belongs to (collection size, wearing frequency, etc.)
    public let category: AchievementCategory

    /// Unlock criteria type that determines when this achievement is earned
    public let unlockCriteria: AchievementCriteria

    /// Target value for progress tracking (e.g., 10 for "Own 10 watches")
    /// - Note: This is the goal value that must be reached to unlock the achievement.
    ///         Current progress is tracked separately in AchievementState.
    public let targetValue: Double

    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        imageAssetName: String,
        category: AchievementCategory,
        unlockCriteria: AchievementCriteria,
        targetValue: Double
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageAssetName = imageAssetName
        self.category = category
        self.unlockCriteria = unlockCriteria
        self.targetValue = targetValue
    }
}

// MARK: - Display Helpers

public extension Achievement {
    /// Returns a formatted progress string (e.g., "8/10" or "50/100")
    func progressString(currentValue: Double) -> String {
        let current = Int(currentValue)
        let target = Int(targetValue)
        return "\(current)/\(target)"
    }

    /// Returns the progress percentage as a value between 0.0 and 1.0
    func progressPercentage(currentValue: Double) -> Double {
        guard targetValue > 0 else { return 0.0 }
        return min(currentValue / targetValue, 1.0)
    }

    /// Returns true if the achievement criteria is met based on current value
    func isCriteriaMet(currentValue: Double) -> Bool {
        currentValue >= targetValue
    }
}
