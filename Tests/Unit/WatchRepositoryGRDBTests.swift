@testable import CrownAndBarrel
import XCTest

final class WatchRepositoryGRDBTests: XCTestCase {
    func testCreateFetchDelete() throws {
        let repo = WatchRepositoryGRDB()
        var w = WatchV2(manufacturer: "TestBrand", modelName: "Model X")
        w.ownership.dateAcquired = Date(timeIntervalSince1970: 1_700_000_000)
        try repo.create(w)

        let fetched = try repo.fetch(id: w.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.manufacturer, "TestBrand")

        // List with filters
        var filters = WatchFilters()
        filters.manufacturer = "TestBrand"
        filters.purchaseDateStart = Date(timeIntervalSince1970: 1_600_000_000)
        let list = try repo.list(sortedBy: .manufacturerLineModel, filters: filters)
        XCTAssertTrue(list.contains(where: { $0.id == w.id }))

        // Cleanup
        try repo.delete(id: w.id)
        XCTAssertNil(try repo.fetch(id: w.id))
    }
}
