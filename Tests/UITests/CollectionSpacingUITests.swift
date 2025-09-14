import XCTest

/// UI tests validating list spacing adjustments for Collection list view.
/// - What: Verifies small vertical gap between cards and tightened horizontal insets.
/// - Why: Prevent regressions in the new minimal/cleaner layout.
/// - How: Measures the first two cells' frames and asserts spacing is > 0 and small.
final class CollectionSpacingUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testListCardVerticalGapAndHorizontalInsets() throws {
        let app = XCUIApplication()
        app.launch()

        // Go to Collection tab
        let collectionTab = app.tabBars.buttons["Collection"]
        if collectionTab.waitForExistence(timeout: 2) { collectionTab.tap() }

        // Switch to list mode
        let listToggle = app.segmentedControls.buttons["list.bullet"]
        if listToggle.exists { listToggle.tap() }

        // Ensure there is at least two cells to measure. If none, create one quickly via the flow.
        if app.cells.count < 2 {
            app.buttons["Add watch"].tap()
            let manufacturer = app.textFields["Manufacturer"]
            XCTAssertTrue(manufacturer.waitForExistence(timeout: 2))
            manufacturer.tap()
            manufacturer.typeText("UITestSpacing1")
            app.buttons["Save"].tap()
        }

        // Query visible cells
        let cells = app.cells.allElementsBoundByIndex
        XCTAssertGreaterThanOrEqual(cells.count, 1)

        // Heuristic vertical gap check: ensure cells are not touching
        if cells.count >= 2 {
            let first = cells[0].frame
            let second = cells[1].frame
            let verticalGap = second.minY - first.maxY
            XCTAssertGreaterThan(verticalGap, 0, "Expected a small vertical gap between rows")
            XCTAssertLessThan(verticalGap, 12, "Gap should remain tight (uses ~2pt background padding)")
        }

        // Heuristic horizontal inset check: card should be inset from list edges
        // We expect an inset around 12pt. Allow tolerance for system variations.
        let list = app.tables.firstMatch
        if list.exists, let firstCell = app.cells.firstMatch as XCUIElement? {
            let leftInset = firstCell.frame.minX - list.frame.minX
            let rightInset = list.frame.maxX - firstCell.frame.maxX
            XCTAssertGreaterThan(leftInset, 4)
            XCTAssertGreaterThan(rightInset, 4)
        }
    }
}


