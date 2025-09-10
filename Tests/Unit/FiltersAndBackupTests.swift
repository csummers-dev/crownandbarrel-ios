import XCTest
@testable import GoodWatch

final class FiltersAndBackupTests: XCTestCase {
    /// Creates a repository backed by an in-memory Core Data stack
    /// for deterministic, side-effect-free tests.
    func makeRepo() -> WatchRepositoryCoreData { WatchRepositoryCoreData(stack: CoreDataStack(inMemory: true)) }

    func testSortingManufacturerAZ() async throws {
        // What: Verify A→Z sort by manufacturer.
        // Why: Ensures sorting UI yields expected ordering for users.
        let repo = makeRepo()
        try await repo.upsert(Watch(manufacturer: "Rolex"))
        try await repo.upsert(Watch(manufacturer: "Omega"))
        let result = try await repo.search(filter: WatchFilter(searchText: "", sortOption: .manufacturerAZ))
        XCTAssertEqual(result.map { $0.manufacturer }, ["Omega", "Rolex"])
    }

    func testSortingMostWorn() async throws {
        // What: Verify sort by most worn surfaces the highest wear count first.
        // Why: Validates aggregation and ordering logic for stats surfaces.
        let repo = makeRepo()
        let w1 = Watch(manufacturer: "A"); let w2 = Watch(manufacturer: "B")
        try await repo.upsert(w1); try await repo.upsert(w2)
        try await repo.incrementWear(for: w2.id, on: Date())
        let result = try await repo.search(filter: WatchFilter(searchText: "", sortOption: .mostWorn))
        XCTAssertEqual(result.first?.manufacturer, "B")
    }

    func testBackupExportImportRoundtrip() async throws {
        // What: Export data then import into a fresh stack and compare.
        // Why: Catches schema/codec regressions in the backup pipeline.
        let stack = CoreDataStack(inMemory: true)
        let repo = WatchRepositoryCoreData(stack: stack)
        let backup = BackupRepositoryFile(stack: stack)

        try await repo.upsert(Watch(manufacturer: "ExportMe"))
        let url = try await backup.exportBackup()

        // New stack to import
        let stack2 = CoreDataStack(inMemory: true)
        let backup2 = BackupRepositoryFile(stack: stack2)
        try await backup2.importBackup(from: url, replace: true)
        let repo2 = WatchRepositoryCoreData(stack: stack2)
        let all = try await repo2.fetchAll()
        XCTAssertEqual(all.first?.manufacturer, "ExportMe")
    }

    func testImportInvalidBackupThrows() async throws {
        // What: Attempt import from a non-existent file path.
        // Why: Ensure we surface a clear error instead of silent failure.
        let stack = CoreDataStack(inMemory: true)
        let backup = BackupRepositoryFile(stack: stack)
        let invalidURL = URL(fileURLWithPath: "/tmp/not-a-backup.goodwatch")
        await XCTAssertThrowsErrorAsync(try await backup.importBackup(from: invalidURL, replace: true))
    }
}


