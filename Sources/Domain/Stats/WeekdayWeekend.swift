import Foundation

public struct WeekdayWeekendBreakdown: Sendable, Equatable {
    /// 1 = Sunday ... 7 = Saturday (Calendar weekday numbers)
    public let countsByWeekday: [Int: Int]
    public let weekdayTotal: Int
    public let weekendTotal: Int
}


