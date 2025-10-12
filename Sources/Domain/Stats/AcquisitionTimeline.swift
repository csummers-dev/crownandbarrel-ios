import Foundation

/// Aggregated acquisition timeline (month buckets).
public struct AcquisitionTimelineAggregation: Sendable, Equatable {
    /// Count of watches acquired per month keyed by the first day of that month (home TZ).
    public let countByMonth: [Date: Int]
    /// Total purchase spend per month keyed by the first day of that month (home TZ).
    public let spendByMonth: [Date: Decimal]
}


