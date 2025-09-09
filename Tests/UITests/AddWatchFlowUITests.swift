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

        // Enter manufacturer and save
        let manufacturer = app.textFields["Manufacturer"]
        XCTAssertTrue(manufacturer.waitForExistence(timeout: 2))
        manufacturer.tap()
        manufacturer.typeText("TestBrand")

        app.buttons["Save"].tap()
    }
}


