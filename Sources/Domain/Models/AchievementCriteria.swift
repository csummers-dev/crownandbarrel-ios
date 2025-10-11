import Foundation

/// Defines the unlock criteria for achievements.
/// - What: Specifies what condition must be met for an achievement to unlock.
/// - Why: Different achievements require different types of evaluation (counts, streaks, ratios, etc.).
///        This enum provides type-safe criteria definitions with associated values where needed.
/// - How: Each case represents a different evaluation strategy. The AchievementEvaluator uses
///        these criteria to determine when to unlock achievements based on current user data.
public enum AchievementCriteria: Codable, Hashable, Sendable {
    // MARK: - Collection Size Criteria

    /// Achievement unlocks when the user owns a specific number of watches
    /// - Parameter count: The target number of watches required
    case watchCountReached(count: Int)

    // MARK: - Wearing Frequency Criteria

    /// Achievement unlocks when total wear entries across all watches reaches a count
    /// - Parameter count: The target number of total wears required
    case totalWearsReached(count: Int)

    /// Achievement unlocks when a single specific watch is worn a certain number of times
    /// - Parameter count: The target number of wears for one watch
    case singleWatchWornCount(count: Int)

    // MARK: - Consistency/Streak Criteria

    /// Achievement unlocks when user logs wears on consecutive days
    /// - Parameter days: The target number of consecutive days
    case consecutiveDaysStreak(days: Int)

    /// Achievement unlocks when user logs wears on consecutive weekends
    /// - Parameter weekends: The target number of consecutive weekends
    case consecutiveWeekendsStreak(weekends: Int)

    /// Achievement unlocks when user logs wears on consecutive weekdays
    /// - Parameter weekdays: The target number of consecutive weekdays
    case consecutiveWeekdaysStreak(weekdays: Int)

    // MARK: - Diversity Criteria

    /// Achievement unlocks when user owns watches from a certain number of unique brands
    /// - Parameter count: The target number of unique brands
    case uniqueBrandsReached(count: Int)

    /// Achievement unlocks when user wears a certain number of different watches in a week
    /// - Parameter count: The target number of different watches
    case differentWatchesInWeek(count: Int)

    /// Achievement unlocks when user wears a certain number of different watches in a month
    /// - Parameter count: The target number of different watches
    case differentWatchesInMonth(count: Int)

    /// Achievement unlocks when user wears a certain number of different watches in a quarter
    /// - Parameter count: The target number of different watches
    case differentWatchesInQuarter(count: Int)

    /// Achievement unlocks when user has worn each watch in their collection at least once
    case allWatchesWornAtLeastOnce

    /// Achievement unlocks when no single watch accounts for more than a certain percentage of total wears
    /// - Parameter maxPercentage: Maximum percentage (0.0 to 1.0) any single watch can account for
    case balancedWearDistribution(maxPercentage: Double)

    // MARK: - Special Occasion Criteria

    /// Achievement unlocks when the first watch is added to the collection
    case firstWatchAdded

    /// Achievement unlocks when the first wear entry is logged
    case firstWearLogged

    /// Achievement unlocks when user has tracked wears for a certain number of consecutive days
    /// - Parameter days: The target number of consecutive tracking days
    case trackingConsecutiveDays(days: Int)

    /// Achievement unlocks when user has used the app for a certain period
    /// - Parameter days: The target number of days since first use
    case appUsageDuration(days: Int)

    /// Achievement unlocks when user logs a certain number of wear entries on their first day
    /// - Parameter count: The target number of wears on day one
    case wearsOnFirstDay(count: Int)

    /// Achievement unlocks when user has logged entries on a certain number of different calendar days
    /// - Parameter days: The target number of unique days with entries
    case uniqueDaysWithEntries(days: Int)
}

// MARK: - Display Helpers

public extension AchievementCriteria {
    /// Returns a human-readable description of the criteria
    var description: String {
        switch self {
        case .watchCountReached(let count):
            return "Own \(count) watch\(count == 1 ? "" : "es")"
        case .totalWearsReached(let count):
            return "Log \(count) total wear\(count == 1 ? "" : "s")"
        case .singleWatchWornCount(let count):
            return "Wear a single watch \(count) time\(count == 1 ? "" : "s")"
        case .consecutiveDaysStreak(let days):
            return "Log wears \(days) day\(days == 1 ? "" : "s") in a row"
        case .consecutiveWeekendsStreak(let weekends):
            return "Log wears on \(weekends) consecutive weekend\(weekends == 1 ? "" : "s")"
        case .consecutiveWeekdaysStreak(let weekdays):
            return "Log wears on \(weekdays) consecutive weekday\(weekdays == 1 ? "" : "s")"
        case .uniqueBrandsReached(let count):
            return "Own watches from \(count) different brand\(count == 1 ? "" : "s")"
        case .differentWatchesInWeek(let count):
            return "Wear \(count) different watch\(count == 1 ? "" : "es") in a week"
        case .differentWatchesInMonth(let count):
            return "Wear \(count) different watch\(count == 1 ? "" : "es") in a month"
        case .differentWatchesInQuarter(let count):
            return "Wear \(count) different watch\(count == 1 ? "" : "es") in a quarter"
        case .allWatchesWornAtLeastOnce:
            return "Wear each watch in your collection at least once"
        case .balancedWearDistribution(let maxPercentage):
            let percentage = Int(maxPercentage * 100)
            return "No single watch accounts for more than \(percentage)% of wears"
        case .firstWatchAdded:
            return "Add your first watch"
        case .firstWearLogged:
            return "Log your first wear"
        case .trackingConsecutiveDays(let days):
            return "Track wears for \(days) consecutive day\(days == 1 ? "" : "s")"
        case .appUsageDuration(let days):
            return "Use the app for \(days) day\(days == 1 ? "" : "s")"
        case .wearsOnFirstDay(let count):
            return "Log \(count) wear\(count == 1 ? "" : "s") on your first day"
        case .uniqueDaysWithEntries(let days):
            return "Log entries on \(days) different day\(days == 1 ? "" : "s")"
        }
    }

    /// Returns the target value for progress tracking
    var targetValue: Double {
        switch self {
        case .watchCountReached(let count):
            return Double(count)
        case .totalWearsReached(let count):
            return Double(count)
        case .singleWatchWornCount(let count):
            return Double(count)
        case .consecutiveDaysStreak(let days):
            return Double(days)
        case .consecutiveWeekendsStreak(let weekends):
            return Double(weekends)
        case .consecutiveWeekdaysStreak(let weekdays):
            return Double(weekdays)
        case .uniqueBrandsReached(let count):
            return Double(count)
        case .differentWatchesInWeek(let count):
            return Double(count)
        case .differentWatchesInMonth(let count):
            return Double(count)
        case .differentWatchesInQuarter(let count):
            return Double(count)
        case .allWatchesWornAtLeastOnce:
            return 1.0 // Boolean achievement
        case .balancedWearDistribution:
            return 1.0 // Boolean achievement
        case .firstWatchAdded:
            return 1.0 // Boolean achievement
        case .firstWearLogged:
            return 1.0 // Boolean achievement
        case .trackingConsecutiveDays(let days):
            return Double(days)
        case .appUsageDuration(let days):
            return Double(days)
        case .wearsOnFirstDay(let count):
            return Double(count)
        case .uniqueDaysWithEntries(let days):
            return Double(days)
        }
    }
}

// MARK: - Codable Implementation

extension AchievementCriteria {
    private enum CodingKeys: String, CodingKey {
        case type
        case count
        case days
        case weekends
        case weekdays
        case maxPercentage
    }

    private enum CriteriaType: String, Codable {
        case watchCountReached
        case totalWearsReached
        case singleWatchWornCount
        case consecutiveDaysStreak
        case consecutiveWeekendsStreak
        case consecutiveWeekdaysStreak
        case uniqueBrandsReached
        case differentWatchesInWeek
        case differentWatchesInMonth
        case differentWatchesInQuarter
        case allWatchesWornAtLeastOnce
        case balancedWearDistribution
        case firstWatchAdded
        case firstWearLogged
        case trackingConsecutiveDays
        case appUsageDuration
        case wearsOnFirstDay
        case uniqueDaysWithEntries
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CriteriaType.self, forKey: .type)

        switch type {
        case .watchCountReached:
            let count = try container.decode(Int.self, forKey: .count)
            self = .watchCountReached(count: count)
        case .totalWearsReached:
            let count = try container.decode(Int.self, forKey: .count)
            self = .totalWearsReached(count: count)
        case .singleWatchWornCount:
            let count = try container.decode(Int.self, forKey: .count)
            self = .singleWatchWornCount(count: count)
        case .consecutiveDaysStreak:
            let days = try container.decode(Int.self, forKey: .days)
            self = .consecutiveDaysStreak(days: days)
        case .consecutiveWeekendsStreak:
            let weekends = try container.decode(Int.self, forKey: .weekends)
            self = .consecutiveWeekendsStreak(weekends: weekends)
        case .consecutiveWeekdaysStreak:
            let weekdays = try container.decode(Int.self, forKey: .weekdays)
            self = .consecutiveWeekdaysStreak(weekdays: weekdays)
        case .uniqueBrandsReached:
            let count = try container.decode(Int.self, forKey: .count)
            self = .uniqueBrandsReached(count: count)
        case .differentWatchesInWeek:
            let count = try container.decode(Int.self, forKey: .count)
            self = .differentWatchesInWeek(count: count)
        case .differentWatchesInMonth:
            let count = try container.decode(Int.self, forKey: .count)
            self = .differentWatchesInMonth(count: count)
        case .differentWatchesInQuarter:
            let count = try container.decode(Int.self, forKey: .count)
            self = .differentWatchesInQuarter(count: count)
        case .allWatchesWornAtLeastOnce:
            self = .allWatchesWornAtLeastOnce
        case .balancedWearDistribution:
            let maxPercentage = try container.decode(Double.self, forKey: .maxPercentage)
            self = .balancedWearDistribution(maxPercentage: maxPercentage)
        case .firstWatchAdded:
            self = .firstWatchAdded
        case .firstWearLogged:
            self = .firstWearLogged
        case .trackingConsecutiveDays:
            let days = try container.decode(Int.self, forKey: .days)
            self = .trackingConsecutiveDays(days: days)
        case .appUsageDuration:
            let days = try container.decode(Int.self, forKey: .days)
            self = .appUsageDuration(days: days)
        case .wearsOnFirstDay:
            let count = try container.decode(Int.self, forKey: .count)
            self = .wearsOnFirstDay(count: count)
        case .uniqueDaysWithEntries:
            let days = try container.decode(Int.self, forKey: .days)
            self = .uniqueDaysWithEntries(days: days)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .watchCountReached(let count):
            try container.encode(CriteriaType.watchCountReached, forKey: .type)
            try container.encode(count, forKey: .count)
        case .totalWearsReached(let count):
            try container.encode(CriteriaType.totalWearsReached, forKey: .type)
            try container.encode(count, forKey: .count)
        case .singleWatchWornCount(let count):
            try container.encode(CriteriaType.singleWatchWornCount, forKey: .type)
            try container.encode(count, forKey: .count)
        case .consecutiveDaysStreak(let days):
            try container.encode(CriteriaType.consecutiveDaysStreak, forKey: .type)
            try container.encode(days, forKey: .days)
        case .consecutiveWeekendsStreak(let weekends):
            try container.encode(CriteriaType.consecutiveWeekendsStreak, forKey: .type)
            try container.encode(weekends, forKey: .weekends)
        case .consecutiveWeekdaysStreak(let weekdays):
            try container.encode(CriteriaType.consecutiveWeekdaysStreak, forKey: .type)
            try container.encode(weekdays, forKey: .weekdays)
        case .uniqueBrandsReached(let count):
            try container.encode(CriteriaType.uniqueBrandsReached, forKey: .type)
            try container.encode(count, forKey: .count)
        case .differentWatchesInWeek(let count):
            try container.encode(CriteriaType.differentWatchesInWeek, forKey: .type)
            try container.encode(count, forKey: .count)
        case .differentWatchesInMonth(let count):
            try container.encode(CriteriaType.differentWatchesInMonth, forKey: .type)
            try container.encode(count, forKey: .count)
        case .differentWatchesInQuarter(let count):
            try container.encode(CriteriaType.differentWatchesInQuarter, forKey: .type)
            try container.encode(count, forKey: .count)
        case .allWatchesWornAtLeastOnce:
            try container.encode(CriteriaType.allWatchesWornAtLeastOnce, forKey: .type)
        case .balancedWearDistribution(let maxPercentage):
            try container.encode(CriteriaType.balancedWearDistribution, forKey: .type)
            try container.encode(maxPercentage, forKey: .maxPercentage)
        case .firstWatchAdded:
            try container.encode(CriteriaType.firstWatchAdded, forKey: .type)
        case .firstWearLogged:
            try container.encode(CriteriaType.firstWearLogged, forKey: .type)
        case .trackingConsecutiveDays(let days):
            try container.encode(CriteriaType.trackingConsecutiveDays, forKey: .type)
            try container.encode(days, forKey: .days)
        case .appUsageDuration(let days):
            try container.encode(CriteriaType.appUsageDuration, forKey: .type)
            try container.encode(days, forKey: .days)
        case .wearsOnFirstDay(let count):
            try container.encode(CriteriaType.wearsOnFirstDay, forKey: .type)
            try container.encode(count, forKey: .count)
        case .uniqueDaysWithEntries(let days):
            try container.encode(CriteriaType.uniqueDaysWithEntries, forKey: .type)
            try container.encode(days, forKey: .days)
        }
    }
}
