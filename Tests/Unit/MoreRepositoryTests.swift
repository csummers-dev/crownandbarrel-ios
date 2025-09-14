import XCTest
@testable import CrownAndBarrel

final class MoreRepositoryTests: XCTestCase {
    /// Creates a repository backed by an in-memory Core Data stack for speed
    /// and isolation between tests.
    func makeRepo() -> WatchRepositoryCoreData { WatchRepositoryCoreData(stack: CoreDataStack(inMemory: true)) }

    func testExistsWearEntryAfterIncrement() async throws {
        // What: After incrementing wear for today, the existence check returns true.
        // Why: Guarantees calendar and detail screens can reflect current state.
        let repo = makeRepo()
        let watch = Watch(manufacturer: "WearTest")
        try await repo.upsert(watch)
        try await repo.incrementWear(for: watch.id, on: Date())
        let exists = try await repo.existsWearEntry(watchId: watch.id, date: Date())
        XCTAssertTrue(exists)
    }

    func testSortByLastWornDate() async throws {
        // What: Sorting by last worn should put the recently worn watch on top.
        // Why: Aligns sorting behavior with user expectations for recency.
        let repo = makeRepo()
        let w1 = Watch(manufacturer: "One")
        let w2 = Watch(manufacturer: "Two")
        try await repo.upsert(w1)
        try await repo.upsert(w2)
        try await repo.incrementWear(for: w2.id, on: Date())
        let result = try await repo.search(filter: WatchFilter(sortOption: .lastWornDate))
        XCTAssertEqual(result.first?.manufacturer, "Two")
    }

    func testImportWithReplaceFalseThrows() async throws {
        // What: Ensure replace=false is rejected to enforce replace-only policy.
        // Why: Prevents accidental merges which are not supported by design.
        let stack = CoreDataStack(inMemory: true)
        let backup = BackupRepositoryFile(stack: stack)
        // Create an empty temp file to simulate a backup
        let temp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".crownandbarrel")
        FileManager.default.createFile(atPath: temp.path, contents: Data())
        await XCTAssertThrowsErrorAsync(try await backup.importBackup(from: temp, replace: false))
    }
}


