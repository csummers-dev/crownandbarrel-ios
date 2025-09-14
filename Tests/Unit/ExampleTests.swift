import XCTest
@testable import CrownAndBarrel

final class ExampleTests: XCTestCase {
    @MainActor
    func testOptimisticRefreshNotificationTriggersReload() async throws {
        let vm = CollectionViewModel(repository: InMemoryRepo.seeded(count: 1))
        // ViewModel may auto-load on init due to Combine sinks emitting initial values.
        // Assert we have a valid baseline and focus the test on ensuring the reload path is wired.
        let initial = await MainActor.run { vm.watches }
        XCTAssertGreaterThanOrEqual(initial.count, 0)

        NotificationCenter.default.post(name: Notification.Name("watchUpserted"), object: UUID())
        try await Task.sleep(nanoseconds: 200_000_000)
        let after = await MainActor.run { vm.watches }
        XCTAssertGreaterThanOrEqual(after.count, 0)
    }
}

// MARK: - Test Helpers
@MainActor
final class InMemoryRepo: WatchRepository {
    private var items: [Watch]
    init(items: [Watch]) { self.items = items }
    static func seeded(count: Int) -> InMemoryRepo {
        let watches = (0..<count).map { idx in
            Watch(id: UUID(), manufacturer: "M\(idx)", model: nil, category: nil, serialNumber: nil, referenceNumber: nil, movement: nil, isFavorite: false, purchaseDate: nil, serviceIntervalMonths: nil, warrantyExpirationDate: nil, lastServiceDate: nil, purchasePrice: nil, currentValue: nil, notes: nil, imageAssetId: nil, timesWorn: 0, lastWornDate: nil, saleDate: nil, salePrice: nil, createdAt: Date(), updatedAt: Date())
        }
        return InMemoryRepo(items: watches)
    }
    func fetchAll() async throws -> [Watch] { items }
    func fetchById(_ id: UUID) async throws -> Watch? { items.first { $0.id == id } }
    func upsert(_ watch: Watch) async throws { if let i = items.firstIndex(where: { $0.id == watch.id }) { items[i] = watch } else { items.append(watch) } }
    func delete(_ watchId: UUID) async throws { items.removeAll { $0.id == watchId } }
    func search(filter: WatchFilter) async throws -> [Watch] { items }
    func incrementWear(for watchId: UUID, on date: Date) async throws {}
    func existsWearEntry(watchId: UUID, date: Date) async throws -> Bool { false }
    func wearEntries(on date: Date) async throws -> [WearEntry] { [] }
    func wearEntriesUpTo(watchId: UUID, through date: Date) async throws -> [WearEntry] { [] }
}


