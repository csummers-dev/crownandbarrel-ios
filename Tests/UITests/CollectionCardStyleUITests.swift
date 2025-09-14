import XCTest

final class CollectionCardStyleUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCollectionListHasCardStyleRows() throws {
        let app = XCUIApplication()
        app.launch()

        // Ensure we're on Collection tab
        let collectionTab = app.tabBars.buttons["Collection"]
        if collectionTab.waitForExistence(timeout: 2) { collectionTab.tap() }

        // Switch to list mode if needed (segmented control with list icon)
        let listToggle = app.segmentedControls.buttons["list.bullet"]
        if listToggle.exists { listToggle.tap() }

        // If no cells exist, add one quickly
        if !app.cells.firstMatch.exists {
            app.buttons["Add watch"].tap()
            let manufacturer = app.textFields["Manufacturer"]
            XCTAssertTrue(manufacturer.waitForExistence(timeout: 2))
            manufacturer.tap()
            manufacturer.typeText("UITestCardRow")
            app.buttons["Save"].tap()
        }

        // Assert card container exists by accessibility identifier across common element types
        let cardOther = app.otherElements["CollectionCard"]
        let cardCell = app.cells["CollectionCard"]
        let cardButton = app.buttons["CollectionCard"]

        let found = cardOther.waitForExistence(timeout: 2) ||
                    cardCell.waitForExistence(timeout: 2) ||
                    cardButton.waitForExistence(timeout: 2)
        XCTAssertTrue(found)
    }
}


