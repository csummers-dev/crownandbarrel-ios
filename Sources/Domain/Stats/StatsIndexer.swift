import Foundation

/// Snapshot of filter inputs used for caching keys and precomputation.
public struct StatsFilterSnapshot: Sendable {
    public let brands: Set<String>
    public let movementTypes: Set<String>
    public let complications: Set<String>
    public let conditions: Set<String>
    public let priceBracketUSD: (Int, Int)?
    public let inRotationOnly: Bool?

    public init(
        brands: Set<String> = [],
        movementTypes: Set<String> = [],
        complications: Set<String> = [],
        conditions: Set<String> = [],
        priceBracketUSD: (Int, Int)? = nil,
        inRotationOnly: Bool? = nil
    ) {
        self.brands = brands
        self.movementTypes = movementTypes
        self.complications = complications
        self.conditions = conditions
        self.priceBracketUSD = priceBracketUSD
        self.inRotationOnly = inRotationOnly
    }
}

/// Background precomputation for common ranges to improve perceived performance.
public actor StatsIndexer {
    private let aggregator: StatsAggregator
    private let cache: StatsCache

    public init(aggregator: StatsAggregator, cache: StatsCache) {
        self.aggregator = aggregator
        self.cache = cache
    }

    /// Precompute wear aggregations for common ranges (7D/30D/90D/YTD/All).
    public func precomputeCommonRanges(filterSnapshot: StatsFilterSnapshot, now: Date = Date(), calendar: Calendar = .current) async {
        let presets: [(start: Date?, end: Date?)] = [
            // 7D
            {
                let end = calendar.startOfDay(for: now)
                let start = calendar.date(byAdding: .day, value: -6, to: end)
                return (start, end)
            }(),
            // 30D
            {
                let end = calendar.startOfDay(for: now)
                let start = calendar.date(byAdding: .day, value: -29, to: end)
                return (start, end)
            }(),
            // 90D
            {
                let end = calendar.startOfDay(for: now)
                let start = calendar.date(byAdding: .day, value: -89, to: end)
                return (start, end)
            }(),
            // YTD
            {
                let comps = calendar.dateComponents([.year], from: now)
                let start = comps.year.flatMap { calendar.date(from: DateComponents(year: $0, month: 1, day: 1)) }
                let end = calendar.startOfDay(for: now)
                return (start, end)
            }(),
            // All (unbounded)
            (nil, nil)
        ]

        for window in presets {
            do {
                let agg = try await aggregator.aggregateWear(start: window.start, end: window.end, calendar: calendar)
                // Store for both day and month granularities using same payload (consumers can read appropriate field)
                let dayKey = WearCacheKey(
                    start: window.start,
                    end: window.end,
                    granularity: .day,
                    brands: filterSnapshot.brands,
                    movementTypes: filterSnapshot.movementTypes,
                    complications: filterSnapshot.complications,
                    conditions: filterSnapshot.conditions,
                    priceBracketUSD: filterSnapshot.priceBracketUSD,
                    inRotationOnly: filterSnapshot.inRotationOnly
                )
                await cache.setWearAggregation(agg, for: dayKey)

                let monthKey = WearCacheKey(
                    start: window.start,
                    end: window.end,
                    granularity: .month,
                    brands: filterSnapshot.brands,
                    movementTypes: filterSnapshot.movementTypes,
                    complications: filterSnapshot.complications,
                    conditions: filterSnapshot.conditions,
                    priceBracketUSD: filterSnapshot.priceBracketUSD,
                    inRotationOnly: filterSnapshot.inRotationOnly
                )
                await cache.setWearAggregation(agg, for: monthKey)
            } catch {
                // Swallow errors during background precompute to avoid impacting UX
            }
        }
    }
}


