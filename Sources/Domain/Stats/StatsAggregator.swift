import Foundation

/// Aggregated wear metrics for the selected date window.
public struct WearAggregationResult: Sendable, Equatable {
    /// Total wear entries per calendar day (keyed by start-of-day in home TZ)
    public let byDay: [Date: Int]
    /// Total wear entries per first day of month (home TZ)
    public let byMonth: [Date: Int]
    /// Wear day counts per watch (each watch contributes at most 1 per day)
    public let perWatchCounts: [UUID: Int]
}

/// Provides offline aggregation utilities over watches and wear entries.
/// - Important: Aggregations normalize dates to the user's home timezone
///   by truncating to start-of-day using the provided Calendar.
public actor StatsAggregator {
    private let repository: WatchRepositoryV2

    public init(repository: WatchRepositoryV2 = WatchRepositoryGRDB()) {
        self.repository = repository
    }

    /// Computes wear aggregates for the given date window.
    /// - Parameters:
    ///   - start: Inclusive start date (start-of-day will be applied). Pass `nil` for unbounded.
    ///   - end: Inclusive end date (treated as exclusive bound by adding one day internally). Pass `nil` for unbounded.
    ///   - calendar: Calendar representing the user's home timezone for normalization.
    public func aggregateWear(start: Date?, end: Date?, calendar: Calendar = .current) async throws -> WearAggregationResult {
        let entries = try await repository.allWearEntries()

        // Normalize inclusive end to exclusive upper bound by adding 1 day to end-of-day
        let lowerBound = start.map { calendar.startOfDay(for: $0) }
        let upperBoundExclusive: Date? = {
            guard let end else { return nil }
            let endStart = calendar.startOfDay(for: end)
            return calendar.date(byAdding: .day, value: 1, to: endStart)
        }()

        // Group wear entries by day and watch for per-watch unique-day counting
        var byDay: [Date: Int] = [:]
        var byMonth: [Date: Int] = [:]
        var perWatchUniqueDays: [UUID: Set<Date>] = [:]

        for entry in entries {
            let day = calendar.startOfDay(for: entry.date)

            // Range filtering
            if let lb = lowerBound, day < lb { continue }
            if let ub = upperBoundExclusive, day >= ub { continue }

            // by day: total entries (multiple watches per day allowed)
            byDay[day, default: 0] += 1

            // by month: first day of month as key
            if let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: day)) {
                byMonth[monthStart, default: 0] += 1
            }

            // per watch: count unique days per watch
            var set = perWatchUniqueDays[entry.watchId, default: []]
            set.insert(day)
            perWatchUniqueDays[entry.watchId] = set
        }

        let perWatchCounts = perWatchUniqueDays.mapValues { $0.count }

        return WearAggregationResult(byDay: byDay, byMonth: byMonth, perWatchCounts: perWatchCounts)
    }

    /// Computes collection composition tallies from `WatchV2` fields.
    public func collectionTallies() async throws -> CollectionCompositionTallies {
        let watches = try await repository.fetchAll()

        var brand: [String: Int] = [:]
        var movement: [String: Int] = [:]
        var complications: [String: Int] = [:]
        var caseMaterials: [String: Int] = [:]

        for w in watches {
            // brand
            brand[w.manufacturer, default: 0] += 1

            // movement type (string raw values from MovementType)
            if let t = w.movement.type?.rawValue {
                movement[t, default: 0] += 1
            }

            // complications (free-form strings)
            for c in w.dial.complications {
                let key = c.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !key.isEmpty else { continue }
                complications[key, default: 0] += 1
            }

            // case material (string via enum asString)
            if let mat = w.watchCase.material?.asString() {
                caseMaterials[mat, default: 0] += 1
            }
        }

        return CollectionCompositionTallies(
            brandCounts: brand,
            movementTypeCounts: movement,
            complicationCounts: complications,
            caseMaterialCounts: caseMaterials
        )
    }

    /// Computes finance aggregates: spend by year/brand and portfolio deltas (USD only display later).
    public func financeAggregation(calendar: Calendar = .current) async throws -> FinanceAggregationResult {
        let watches = try await repository.fetchAll()

        var spendByYear: [Int: Decimal] = [:]
        var spendByBrand: [String: Decimal] = [:]
        var totalPurchase: Decimal = 0
        var totalEstimatedValue: Decimal = 0

        for w in watches {
            if let price = w.ownership.purchasePriceAmount {
                totalPurchase += price

                if let date = w.ownership.dateAcquired {
                    let y = calendar.component(.year, from: date)
                    spendByYear[y, default: 0] += price
                }

                spendByBrand[w.manufacturer, default: 0] += price
            }

            // estimated value from ownership or latest valuation entry
            if let est = w.ownership.currentEstimatedValueAmount {
                totalEstimatedValue += est
            } else if let latestVal = w.valuations.sorted(by: { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }).first,
                      let amount = latestVal.valueAmount {
                totalEstimatedValue += amount
            }
        }

        let deltaAbs = totalEstimatedValue - totalPurchase
        let deltaPct: Double? = totalPurchase == 0 ? nil : (NSDecimalNumber(decimal: deltaAbs).doubleValue / NSDecimalNumber(decimal: totalPurchase).doubleValue)

        return FinanceAggregationResult(
            spendByYear: spendByYear,
            spendByBrand: spendByBrand,
            totalPurchase: totalPurchase,
            totalEstimatedValue: totalEstimatedValue,
            deltaAbsolute: deltaAbs,
            deltaPercent: deltaPct
        )
    }

    /// Computes acquisition timeline: counts and spend grouped by first day of month.
    public func acquisitionTimeline(calendar: Calendar = .current) async throws -> AcquisitionTimelineAggregation {
        let watches = try await repository.fetchAll()
        var countByMonth: [Date: Int] = [:]
        var spendByMonth: [Date: Decimal] = [:]

        for w in watches {
            guard let date = w.ownership.dateAcquired else { continue }
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
            countByMonth[monthStart, default: 0] += 1
            if let price = w.ownership.purchasePriceAmount {
                spendByMonth[monthStart, default: 0] += price
            }
        }

        return AcquisitionTimelineAggregation(countByMonth: countByMonth, spendByMonth: spendByMonth)
    }

    /// Computes distributions for size and water resistance using simple bins.
    public func collectionDistributions() async throws -> CollectionDistributions {
        let watches = try await repository.fetchAll()

        func bin(_ value: Double?, step: Double, unit: String) -> String? {
            guard let v = value else { return nil }
            let bucket = (floor(v / step) * step)
            let next = bucket + step
            let fmt: (Double) -> String = { String(format: "%.0f", $0) }
            return "\(fmt(bucket))–\(fmt(next)) \(unit)"
        }

        func binInt(_ value: Int?, step: Int, unit: String) -> String? {
            guard let v = value else { return nil }
            let bucket = (v / step) * step
            let next = bucket + step
            return "\(bucket)–\(next) \(unit)"
        }

        var diameter: [String: Int] = [:]
        var thickness: [String: Int] = [:]
        var l2l: [String: Int] = [:]
        var water: [String: Int] = [:]

        for w in watches {
            if let key = bin(w.watchCase.diameterMM, step: 2.0, unit: "mm") { diameter[key, default: 0] += 1 }
            if let key = bin(w.watchCase.thicknessMM, step: 1.0, unit: "mm") { thickness[key, default: 0] += 1 }
            if let key = bin(w.watchCase.lugToLugMM, step: 2.0, unit: "mm") { l2l[key, default: 0] += 1 }
            if let key = binInt(w.water.waterResistanceM, step: 50, unit: "m") { water[key, default: 0] += 1 }
        }

        return CollectionDistributions(
            diameterBins: diameter,
            thicknessBins: thickness,
            lugToLugBins: l2l,
            waterResistanceBins: water
        )
    }

    /// Computes last service date and upcoming warranty deadline per watch.
    public func serviceOverview(calendar: Calendar = .current) async throws -> [ServiceStatus] {
        let watches = try await repository.fetchAll()
        return watches.map { w in
            let lastService = w.serviceHistory
                .compactMap { $0.date }
                .sorted(by: >)
                .first
            let nextWarranty = w.serviceHistory
                .compactMap { $0.warrantyUntil }
                .sorted(by: >)
                .first
            return ServiceStatus(
                watchId: w.id,
                manufacturer: w.manufacturer,
                modelName: w.modelName,
                lastServiceDate: lastService,
                warrantyUntil: nextWarranty
            )
        }
    }

    /// Computes counts for ownership box/papers categories.
    public func boxPapersCounts() async throws -> [String: Int] {
        let watches = try await repository.fetchAll()
        var counts: [String: Int] = [:]
        for w in watches {
            if let bp = w.ownership.boxPapers?.asString() {
                counts[bp, default: 0] += 1
            } else {
                counts["unknown", default: 0] += 1
            }
        }
        return counts
    }

    /// Computes most/least worn rankings by unique days in the window, tie-breaking by most recent wear date.
    public func wearingRankings(start: Date?, end: Date?, calendar: Calendar = .current) async throws -> [WearingRankItem] {
        let watches = try await repository.fetchAll()
        let wear = try await aggregateWear(start: start, end: end, calendar: calendar)

        // We rely on repository.lastWornDate for tie-breaker; range-specific last dates omitted for now

        // Count map is available in perWatchCounts
        var items: [WearingRankItem] = []
        for w in watches {
            let days = wear.perWatchCounts[w.id] ?? 0
            // Use repository lastWornDate(watchId:) to get global last worn, but we need within range; fallback to global
            let last = try await repository.lastWornDate(watchId: w.id)
            items.append(WearingRankItem(id: w.id, watch: w, daysWorn: days, lastWornDateInRange: last))
        }

        // Sort by days desc, then last worn desc
        items.sort { lhs, rhs in
            if lhs.daysWorn != rhs.daysWorn { return lhs.daysWorn > rhs.daysWorn }
            let l = lhs.lastWornDateInRange ?? .distantPast
            let r = rhs.lastWornDateInRange ?? .distantPast
            return l > r
        }
        return items
    }

    /// Computes rotation balance using Gini coefficient over wear-day counts.
    public func rotationBalance(start: Date?, end: Date?, calendar: Calendar = .current) async throws -> RotationBalanceResult {
        let agg = try await aggregateWear(start: start, end: end, calendar: calendar)
        let counts = agg.perWatchCounts.values.map { Double($0) }.sorted()
        guard !counts.isEmpty else { return RotationBalanceResult(perWatchDays: [:], gini: 0, balanceScore: 1) }
        let n = Double(counts.count)
        let sum = counts.reduce(0, +)
        if sum == 0 { return RotationBalanceResult(perWatchDays: agg.perWatchCounts, gini: 0, balanceScore: 1) }
        // Gini formula for discrete values: 1 - (2/(n-1)) * (n - (sum_i (n+1-i)*x_i)/sum)
        var cumulative: Double = 0
        for (idx, x) in counts.enumerated() { cumulative += (Double(idx) + 1.0) * x }
        let gini = 1.0 - (2.0 / (n - 1.0)) * (n - (cumulative / sum))
        let score = max(0.0, min(1.0, 1.0 - gini))
        return RotationBalanceResult(perWatchDays: agg.perWatchCounts, gini: gini, balanceScore: score)
    }

    /// Computes neglect index: watches with zero days in range, listing days since last wear overall.
    public func neglectIndex(start: Date?, end: Date?, calendar: Calendar = .current) async throws -> [NeglectItem] {
        let agg = try await aggregateWear(start: start, end: end, calendar: calendar)
        let watches = try await repository.fetchAll()
        var items: [NeglectItem] = []
        for w in watches {
            let inRangeDays = agg.perWatchCounts[w.id] ?? 0
            let last = try await repository.lastWornDate(watchId: w.id)
            let daysSince: Int? = last.flatMap { date in
                calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: Date())).day
            }
            items.append(NeglectItem(id: w.id, watch: w, daysSinceLastWear: daysSince, isNeglectedInRange: inRangeDays == 0))
        }
        // Sort: neglected first by daysSince desc, then non-neglected by daysSince desc
        items.sort { lhs, rhs in
            if lhs.isNeglectedInRange != rhs.isNeglectedInRange { return lhs.isNeglectedInRange && !rhs.isNeglectedInRange }
            let l = lhs.daysSinceLastWear ?? -1
            let r = rhs.daysSinceLastWear ?? -1
            return l > r
        }
        return items
    }

    /// Computes streaks: daily wear streak, brand streaks, and no-repeat streak.
    public func streaks(calendar: Calendar = .current) async throws -> StreaksResult {
        let entries = try await repository.allWearEntries()
        guard !entries.isEmpty else {
            return StreaksResult(currentDailyStreak: 0, currentNoRepeatStreakDistinctWatches: 0, currentBrandStreaks: [:])
        }

        // Group by day and by brand per day
        var daysToWatchIds: [Date: Set<UUID>] = [:]
        var watchIdToBrand: [UUID: String] = [:]
        let watches = try await repository.fetchAll()
        for w in watches { watchIdToBrand[w.id] = w.manufacturer }

        for e in entries {
            let d = calendar.startOfDay(for: e.date)
            var set = daysToWatchIds[d, default: []]
            set.insert(e.watchId)
            daysToWatchIds[d] = set
        }

        let today = calendar.startOfDay(for: Date())
        // Daily streak: consecutive days from today with any wear
        var daily = 0
        var cursor = today
        while daysToWatchIds.keys.contains(cursor) {
            daily += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }

        // No-repeat streak: longest consecutive sequence ending today with different watches each day
        var noRepeat = 0
        var used: Set<UUID> = []
        cursor = today
        while let todaySet = daysToWatchIds[cursor] {
            // Can pick any watch not used before; if none, break
            if let pick = todaySet.first(where: { !used.contains($0) }) {
                used.insert(pick)
                noRepeat += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = prev
            } else {
                break
            }
        }

        // Brand streaks: per brand consecutive days ending today
        var brandStreaks: [String: Int] = [:]
        cursor = today
        while true {
            guard let set = daysToWatchIds[cursor] else { break }
            let brandsToday = Set(set.compactMap { watchIdToBrand[$0] })
            // Increment streaks for brands present; stop when no brands present (break all)
            if brandsToday.isEmpty { break }
            for b in brandsToday { brandStreaks[b, default: 0] += 1 }
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }

        return StreaksResult(
            currentDailyStreak: daily,
            currentNoRepeatStreakDistinctWatches: noRepeat,
            currentBrandStreaks: brandStreaks
        )
    }

    public func weekdayWeekendBreakdown(start: Date?, end: Date?, calendar: Calendar = .current) async throws -> WeekdayWeekendBreakdown {
        let agg = try await aggregateWear(start: start, end: end, calendar: calendar)
        var counts: [Int: Int] = [:]
        for (day, count) in agg.byDay {
            let wd = calendar.component(.weekday, from: day)
            counts[wd, default: 0] += count
        }
        let weekdaySet: Set<Int> = [2,3,4,5,6] // Mon..Fri in many calendars where 1=Sun
        let weekendSet: Set<Int> = [1,7]
        let weekdayTotal = counts.filter { weekdaySet.contains($0.key) }.map { $0.value }.reduce(0, +)
        let weekendTotal = counts.filter { weekendSet.contains($0.key) }.map { $0.value }.reduce(0, +)
        return WeekdayWeekendBreakdown(countsByWeekday: counts, weekdayTotal: weekdayTotal, weekendTotal: weekendTotal)
    }

    public func topEvents(calendar: Calendar = .current) async throws -> [TopEventItem] {
        var items: [TopEventItem] = []
        // Longest streak (global)
        if let streak = try? await repository.currentStreak() {
            items.append(TopEventItem(title: "Current daily streak", detail: "\(streak) days", date: Date()))
        }
        // Most-worn month
        if let wear = try? await aggregateWear(start: nil, end: nil, calendar: calendar) {
            let monthly = wear.byMonth
            if let (m, c) = monthly.max(by: { $0.value < $1.value }) {
                items.append(TopEventItem(title: "Most-worn month", detail: "\(c) wear days", date: m))
            }
        }
        // First wear
        if let firstWear = try? await repository.firstWearDate() {
            items.append(TopEventItem(title: "First wear", detail: "Milestone", date: firstWear))
        }
        // New brand unlocked (latest date a new brand first appears)
        if let watches = try? await repository.fetchAll() {
            let byBrandDates = Dictionary(grouping: watches, by: { $0.manufacturer }).mapValues { arr in
                arr.map { $0.createdAt }.min() ?? Date()
            }
            if let (brand, date) = byBrandDates.max(by: { $0.value < $1.value }) {
                items.append(TopEventItem(title: "Newest brand added", detail: brand, date: date))
            }
        }
        // Highest value watch (by ownership estimate)
        if let watches = try? await repository.fetchAll() {
            if let w = watches.max(by: { ( $0.ownership.currentEstimatedValueAmount ?? 0) < ( $1.ownership.currentEstimatedValueAmount ?? 0) }) {
                items.append(TopEventItem(title: "Highest estimated value", detail: "\(w.manufacturer) \(w.modelName)", date: nil))
            }
        }
        return Array(items.prefix(5))
    }
}


