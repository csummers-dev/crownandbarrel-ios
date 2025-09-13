import XCTest

final class AddWatchFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddWatchFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap Add button (FAB)
        app.buttons["Add watch"].firstMatch.tap()

        // Wait for the Add Watch sheet to appear
        XCTAssertTrue(app.navigationBars["Add Watch"].waitForExistence(timeout: 5))

        // Enter manufacturer and save (locate inside the form's table)
        let manufacturer = app.textFields["manufacturerField"].firstMatch
        XCTAssertTrue(manufacturer.waitForExistence(timeout: 5))
        manufacturer.tap()
        manufacturer.typeText("TestBrand")

        app.buttons["Save"].tap()
    }
}


