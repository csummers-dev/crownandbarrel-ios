import Foundation

/// Rotation balance metrics computed from wear-day distribution across watches.
public struct RotationBalanceResult: Sendable, Equatable {
    /// Wear-day counts per watch within the selected range
    public let perWatchDays: [UUID: Int]
    /// Gini coefficient (0 = perfectly even, 1 = maximally uneven)
    public let gini: Double
    /// Convenience score where higher is better (1 - gini)
    public let balanceScore: Double
}


