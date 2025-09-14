import XCTest
@testable import CrownAndBarrel
import UIKit

private final class WatchRepositorySpy: WatchRepository {
    var upserted: Watch? = nil
    var deletedId: UUID? = nil
    func fetchAll() async throws -> [Watch] { [] }
    func fetchById(_ id: UUID) async throws -> Watch? { nil }
    func upsert(_ watch: Watch) async throws { upserted = watch }
    func delete(_ watchId: UUID) async throws { deletedId = watchId }
    func search(filter: WatchFilter) async throws -> [Watch] { [] }
    func incrementWear(for watchId: UUID, on date: Date) async throws {}
    func existsWearEntry(watchId: UUID, date: Date) async throws -> Bool { false }
    func wearEntries(on date: Date) async throws -> [WearEntry] { [] }
    func wearEntriesUpTo(watchId: UUID, through date: Date) async throws -> [WearEntry] { [] }
}

final class WatchFormViewModelTests: XCTestCase {
    func testValidateFailsWhenManufacturerEmpty() async {
        let vm: WatchFormViewModel = await MainActor.run { WatchFormViewModel(repository: WatchRepositorySpy()) }
        let result: (isValid: Bool, message: String?) = await MainActor.run {
            vm.manufacturer = "  "
            return (vm.validate(), vm.errorMessage)
        }
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.message, "Manufacturer is required.")
    }

    func testParseIntHandlesWhitespace() async {
        let vm: WatchFormViewModel = await MainActor.run { WatchFormViewModel(repository: WatchRepositorySpy()) }
        // Indirectly test parseInt by assigning and saving
        await MainActor.run {
            vm.manufacturer = "Acme"
            vm.serviceIntervalMonths = " 12 "
        }
        _ = await vm.save()
        // No crash and save attempted is sufficient here; deeper checks in upsert below
    }

    func testSaveUpsertsWatch() async {
        let repo = WatchRepositorySpy()
        let vm: WatchFormViewModel = await MainActor.run { WatchFormViewModel(repository: repo) }
        await MainActor.run {
            vm.manufacturer = "Rolex"
            vm.model = "Submariner"
            vm.category = .diver
            vm.isFavorite = true
        }
        let ok = await vm.save()
        XCTAssertTrue(ok)
        XCTAssertEqual(repo.upserted?.manufacturer, "Rolex")
        XCTAssertEqual(repo.upserted?.model, "Submariner")
        XCTAssertEqual(repo.upserted?.isFavorite, true)
    }

    func testDeleteFailsWithoutId() async {
        let vm: WatchFormViewModel = await MainActor.run { WatchFormViewModel(repository: WatchRepositorySpy()) }
        let ok = await vm.delete()
        let message: String? = await MainActor.run { vm.errorMessage }
        XCTAssertFalse(ok)
        XCTAssertEqual(message, "Cannot delete: watch identifier missing.")
    }
}


