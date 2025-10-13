import Foundation

public enum StatsGranularity: String, Sendable, CaseIterable {
    case day
    case month
}

/// Key for caching wear aggregations.
public struct WearCacheKey: Hashable, Sendable {
    public let start: Date?
    public let end: Date?
    public let granularity: StatsGranularity
    public let brands: [String]
    public let movementTypes: [String]
    public let complications: [String]
    public let conditions: [String]
    public let priceBracketUSD: (Int, Int)?
    public let inRotationOnly: Bool?

    public init(
        start: Date?,
        end: Date?,
        granularity: StatsGranularity,
        brands: Set<String> = [],
        movementTypes: Set<String> = [],
        complications: Set<String> = [],
        conditions: Set<String> = [],
        priceBracketUSD: (Int, Int)? = nil,
        inRotationOnly: Bool? = nil
    ) {
        self.start = start
        self.end = end
        self.granularity = granularity
        self.brands = brands.sorted()
        self.movementTypes = movementTypes.sorted()
        self.complications = complications.sorted()
        self.conditions = conditions.sorted()
        self.priceBracketUSD = priceBracketUSD
        self.inRotationOnly = inRotationOnly
    }
}

// Explicit Equatable/Hashable to support tuple hashing across toolchains
public extension WearCacheKey {
    static func == (lhs: WearCacheKey, rhs: WearCacheKey) -> Bool {
        lhs.start == rhs.start &&
        lhs.end == rhs.end &&
        lhs.granularity == rhs.granularity &&
        lhs.brands == rhs.brands &&
        lhs.movementTypes == rhs.movementTypes &&
        lhs.complications == rhs.complications &&
        lhs.conditions == rhs.conditions &&
        lhs.priceBracketUSD?.0 == rhs.priceBracketUSD?.0 &&
        lhs.priceBracketUSD?.1 == rhs.priceBracketUSD?.1 &&
        lhs.inRotationOnly == rhs.inRotationOnly
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(end)
        hasher.combine(granularity)
        hasher.combine(brands)
        hasher.combine(movementTypes)
        hasher.combine(complications)
        hasher.combine(conditions)
        if let pb = priceBracketUSD {
            hasher.combine(pb.0)
            hasher.combine(pb.1)
        } else {
            hasher.combine(0)
            hasher.combine(0)
        }
        hasher.combine(inRotationOnly)
    }
}

/// In-memory cache for stats aggregations.
public actor StatsCache {
    private var wearCache: [WearCacheKey: WearAggregationResult] = [:]

    public init() {}

    public func getWearAggregation(for key: WearCacheKey) -> WearAggregationResult? {
        wearCache[key]
    }

    public func setWearAggregation(_ value: WearAggregationResult, for key: WearCacheKey) {
        wearCache[key] = value
    }

    public func invalidateAll() {
        wearCache.removeAll()
    }

    public func invalidateForWatchesChange() {
        invalidateAll()
    }

    public func invalidateForWearEntriesChange() {
        invalidateAll()
    }
}


