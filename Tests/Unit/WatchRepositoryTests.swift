import XCTest
@testable import CrownAndBarrel

final class WatchRepositoryTests: XCTestCase {
    /// Creates a repository backed by an in-memory Core Data stack so tests are
    /// fast, isolated, and do not touch persistent storage on disk.
    func makeRepo() -> WatchRepositoryCoreData {
        WatchRepositoryCoreData(stack: CoreDataStack(inMemory: true))
    }

    func testUpsertAndFetchAll() async throws {
        // What: Insert one watch and verify that a subsequent fetch returns it.
        // Why: Provides a smoke test for the basic CRUD path.
        // How: Uses the repository abstraction rather than Core Data directly.
        let repo = makeRepo()
        let watch = Watch(manufacturer: "TestBrand")
        try await repo.upsert(watch)
        let all = try await repo.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.manufacturer, "TestBrand")
    }

    func testSearchByManufacturer() async throws {
        // What: Ensure case-insensitive substring search by manufacturer works.
        // Why: Confirms user-facing search behavior matches expectations.
        let repo = makeRepo()
        try await repo.upsert(Watch(manufacturer: "Omega"))
        try await repo.upsert(Watch(manufacturer: "Rolex"))
        let filtered = try await repo.search(filter: WatchFilter(searchText: "ome", sortOption: .manufacturerAZ))
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.manufacturer, "Omega")
    }

    func testWearUniqueness() async throws {
        // What: Verify that incrementing wear twice on the same day throws.
        // Why: Business rule to prevent duplicate wear entries per day.
        let repo = makeRepo()
        let watch = Watch(manufacturer: "Test")
        try await repo.upsert(watch)
        try await repo.incrementWear(for: watch.id, on: Date())
        await XCTAssertThrowsErrorAsync(try await repo.incrementWear(for: watch.id, on: Date()))
    }

    func testFetchByIdReturnsInsertedWatch() async throws {
        let repo = makeRepo()
        let watch = Watch(manufacturer: "FetchByIdBrand")
        try await repo.upsert(watch)
        let fetched = try await repo.fetchById(watch.id)
        XCTAssertEqual(fetched?.id, watch.id)
        XCTAssertEqual(fetched?.manufacturer, "FetchByIdBrand")
    }

    func testDeleteRemovesWatch() async throws {
        let repo = makeRepo()
        let watch = Watch(manufacturer: "DeleteBrand")
        try await repo.upsert(watch)
        try await repo.delete(watch.id)
        let fetched = try await repo.fetchById(watch.id)
        XCTAssertNil(fetched)
    }

    func testWearEntriesUpToExcludesFutureAndSorts() async throws {
        let repo = makeRepo()
        var watch = Watch(manufacturer: "Dates")
        try await repo.upsert(watch)
        let cal = Calendar.current
        let today = Date()
        let past = cal.date(byAdding: .day, value: -10, to: today)!
        let future = cal.date(byAdding: .day, value: 1, to: today)!
        try await repo.incrementWear(for: watch.id, on: past)
        try await repo.incrementWear(for: watch.id, on: today)
        // attempt to insert a future entry should be reflected in repo if allowed, but our query must exclude it
        try await repo.incrementWear(for: watch.id, on: future)
        let entries = try await repo.wearEntriesUpTo(watchId: watch.id, through: today)
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(Calendar.current.startOfDay(for: entries.last!.date), Calendar.current.startOfDay(for: today))
    }

    func testExistsWearEntryHonorsCalendarDay() async throws {
        let repo = makeRepo()
        let watch = Watch(manufacturer: "Exists")
        try await repo.upsert(watch)
        // Mark worn today
        try await repo.incrementWear(for: watch.id, on: Date())
        // Today should be true
        let existsToday = try await repo.existsWearEntry(watchId: watch.id, date: Date())
        XCTAssertTrue(existsToday)
        // Future should be false
        let future = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let existsFuture = try await repo.existsWearEntry(watchId: watch.id, date: future)
        XCTAssertFalse(existsFuture)
    }
}

extension XCTestCase {
    /// Helper for asserting async throwing code does throw.
    func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure () async throws -> T, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) async {
        do { _ = try await expression(); XCTFail("Expected error, but got success", file: file, line: line) }
        catch { XCTAssertTrue(true) }
    }
}


