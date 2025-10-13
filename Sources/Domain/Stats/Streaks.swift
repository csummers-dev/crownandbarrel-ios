import Foundation

public struct StreaksResult: Sendable, Equatable {
    public let currentDailyStreak: Int
    public let currentNoRepeatStreakDistinctWatches: Int
    public let currentBrandStreaks: [String: Int] // brand -> consecutive days ending today
}


