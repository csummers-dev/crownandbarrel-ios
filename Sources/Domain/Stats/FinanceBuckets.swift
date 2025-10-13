import Foundation

/// Aggregated finance metrics derived from ownership and valuation data.
public struct FinanceAggregationResult: Sendable, Equatable {
    /// Total purchase spend grouped by acquisition year (calendar year of `ownership.dateAcquired`).
    public let spendByYear: [Int: Decimal]
    /// Total purchase spend grouped by manufacturer (brand).
    public let spendByBrand: [String: Decimal]
    /// Sum of all `ownership.purchasePriceAmount` across watches.
    public let totalPurchase: Decimal
    /// Sum of estimated values across watches.
    /// Uses `ownership.currentEstimatedValueAmount` or falls back to latest `ValuationEntry.valueAmount` when available.
    public let totalEstimatedValue: Decimal
    /// Estimated portfolio gain/loss: `totalEstimatedValue - totalPurchase`.
    public let deltaAbsolute: Decimal
    /// Percentage gain/loss relative to cost basis; `nil` if `totalPurchase` is zero.
    public let deltaPercent: Double?
}


