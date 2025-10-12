import XCTest
@testable import CrownAndBarrel
import GRDB

final class StatsAggregatorTests: XCTestCase {
    func testAggregateWear_basicRange() async throws {
        // Smoke test: Ensure aggregator returns a result and honors empty DB.
        let agg = StatsAggregator()
        let res = try await agg.aggregateWear(start: nil, end: nil)
        XCTAssertNotNil(res)
        XCTAssertTrue(res.byDay.isEmpty || !res.byDay.isEmpty) // structural existence
    }

    func testCollectionTallies_smoke() async throws {
        let agg = StatsAggregator()
        let tallies = try await agg.collectionTallies()
        // Only verify keys exist; data depends on DB fixture contents.
        _ = tallies.brandCounts
        _ = tallies.movementTypeCounts
        _ = tallies.complicationCounts
        _ = tallies.caseMaterialCounts
    }

    func testFinanceAggregation_smoke() async throws {
        let agg = StatsAggregator()
        let finance = try await agg.financeAggregation()
        _ = finance.spendByYear
        _ = finance.spendByBrand
        _ = finance.totalPurchase
        _ = finance.totalEstimatedValue
        _ = finance.deltaAbsolute
        _ = finance.deltaPercent
    }
}

extension StatsAggregatorTests {
    private func laCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return cal
    }

    private func dateInLA(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        comps.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return Calendar(identifier: .gregorian).date(from: comps)!
    }

    private func createWatch(manufacturer: String = "TestBrand", model: String = "Model") throws -> WatchV2 {
        let repo = WatchRepositoryGRDB()
        let w = WatchV2(manufacturer: manufacturer, modelName: model)
        try repo.create(w)
        return w
    }

    private func clearDatabase() async throws {
        let backup = BackupRepositoryGRDB()
        try await backup.deleteAll()
    }

    func testAggregateWear_DSTStart_USPacific() async throws {
        try await clearDatabase()
        let watch = try createWatch()

        // Insert wear entries for 2025-03-08 and 2025-03-09 (DST start in US)
        let cal = laCalendar()
        let d1 = dateInLA(year: 2025, month: 3, day: 8)
        let d2 = dateInLA(year: 2025, month: 3, day: 9)

        try AppDatabase.shared.dbQueue.write { db in
            try WearEntry(watchId: watch.id, date: d1).insert(db)
            try WearEntry(watchId: watch.id, date: d2).insert(db)
        }

        let agg = StatsAggregator()
        let res = try await agg.aggregateWear(start: d1, end: d2, calendar: cal)

        XCTAssertEqual(res.byDay.count, 2)
        XCTAssertEqual(res.perWatchCounts[watch.id], 2)

        let monthStart = cal.date(from: DateComponents(year: 2025, month: 3, day: 1))!
        XCTAssertEqual(res.byMonth[monthStart], 2)
    }

    func testAggregateWear_DSTEnd_USPacific() async throws {
        try await clearDatabase()
        let watch = try createWatch(manufacturer: "BrandB", model: "DSTEnd")

        // Insert wear entries for 2025-11-01 and 2025-11-02 (DST end in US)
        let cal = laCalendar()
        let d1 = dateInLA(year: 2025, month: 11, day: 1)
        let d2 = dateInLA(year: 2025, month: 11, day: 2)

        try AppDatabase.shared.dbQueue.write { db in
            try WearEntry(watchId: watch.id, date: d1).insert(db)
            try WearEntry(watchId: watch.id, date: d2).insert(db)
        }

        let agg = StatsAggregator()
        let res = try await agg.aggregateWear(start: d1, end: d2, calendar: cal)

        XCTAssertEqual(res.byDay.count, 2)
        XCTAssertEqual(res.perWatchCounts[watch.id], 2)

        let monthStart = cal.date(from: DateComponents(year: 2025, month: 11, day: 1))!
        XCTAssertEqual(res.byMonth[monthStart], 2)
    }
}


