import XCTest

final class DetailWornTodayUITests: XCTestCase {
    func testWornTodayButtonExists() throws {
        let app = XCUIApplication()
        app.launch()
        let collectionButton = app.tabBars.buttons["Collection"]
        if collectionButton.waitForExistence(timeout: 3) { collectionButton.tap() }
        // Seed a watch to reduce flakiness
        if app.buttons["Add watch"].firstMatch.waitForExistence(timeout: 3) {
            app.buttons["Add watch"].firstMatch.tap()
            XCTAssertTrue(app.navigationBars["Add Watch"].waitForExistence(timeout: 5))
            let manufacturer = app.textFields["manufacturerField"].firstMatch
            XCTAssertTrue(manufacturer.waitForExistence(timeout: 3))
            manufacturer.tap(); manufacturer.typeText("SeedBrand")
            app.buttons["Save"].tap()
        }
        // Wait for collection to render an item (grid or list)
        let deadline = Date().addingTimeInterval(10)
        var tappedIntoDetail = false
        while Date() < deadline && !tappedIntoDetail {
            // Prefer known grid cell identifier prefix if present
            let gridCells = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "GridCellManufacturer-")).firstMatch
            if gridCells.exists { gridCells.tap(); tappedIntoDetail = true; break }
            // Fallback: tap the first cell (list mode)
            let firstCell = app.cells.firstMatch
            if firstCell.exists { firstCell.tap(); tappedIntoDetail = true; break }
            // Fallback: tap a generic button that isn't the Add watch FAB
            let genericButton = app.buttons.firstMatch
            if genericButton.exists && genericButton.label != "Add watch" { genericButton.tap(); tappedIntoDetail = true; break }
            // Pull-to-refresh to trigger data reload
            app.swipeDown()
        }
        XCTAssertTrue(tappedIntoDetail, "Failed to open a watch detail from collection")
        // Confirm detail screen loaded
        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 10))
        // Check for either the CTA button or the text-only indicator; prefer DEBUG identifiers
        let cta = app.buttons["WornTodayCTA"].firstMatch
        let label = app.staticTexts["WornTodayLabel"].firstMatch
        let found = cta.waitForExistence(timeout: 8) || label.waitForExistence(timeout: 8) || app.buttons["Mark as worn today"].waitForExistence(timeout: 8) || app.staticTexts["Worn today"].waitForExistence(timeout: 8)
        XCTAssertTrue(found)
    }
}


