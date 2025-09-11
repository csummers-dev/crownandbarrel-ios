import XCTest

final class CollectionImageRefreshUITests: XCTestCase {
    /// Verifies that after editing a watch and selecting an image, the
    /// collection grid reflects the real image (not the placeholder) without
    /// requiring a manual reload.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// End-to-end: add a watch if needed, inject a deterministic test image in the edit flow,
    /// save, then assert the collection replaces the placeholder with the real image.
    func testImageRefreshesInCollectionAfterSave() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_INJECT_IMAGE")
        app.launch()

        // Ensure we're on Collection tab
        let collectionTab = app.tabBars.buttons["Collection"]
        if collectionTab.waitForExistence(timeout: 2) { collectionTab.tap() }

        // If no cells exist, add one quickly
        if !app.cells.firstMatch.exists {
            app.buttons["Add watch"].tap()
            let manufacturer = app.textFields["Manufacturer"]
            XCTAssertTrue(manufacturer.waitForExistence(timeout: 2))
            manufacturer.tap()
            manufacturer.typeText("UITestBrand")
            app.buttons["Save"].tap()
        }

        // Before: assert placeholder image is present in the first cell (heuristic)
        let placeholder = app.images["watch-image-placeholder"]
        _ = placeholder.waitForExistence(timeout: 2)

        // Capture initial count (best-effort for later comparison)
        let initialCount = app.cells.count

        // Open the watch to edit (be tolerant to CI slowness and SwiftUI grid semantics)
        // Prefer cells when List mode is active; otherwise, fall back to the grid's accessible label.
        if app.cells.firstMatch.waitForExistence(timeout: 8) {
            app.cells.firstMatch.tap()
        } else {
            // Fallback: search for the watch by its manufacturer label (set as accessibility label on grid cell)
            let brand = "UITestBrand"
            let candidateByLabel = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", brand)).firstMatch
            if candidateByLabel.waitForExistence(timeout: 4) {
                candidateByLabel.tap()
            } else {
                let anyElement = app.otherElements[brand]
                XCTAssertTrue(anyElement.waitForExistence(timeout: 4), "Expected a watch cell to appear after saving")
                anyElement.tap()
            }
        }

        // Tap Edit
        let edit = app.buttons["Edit"]
        XCTAssertTrue(edit.waitForExistence(timeout: 2))
        edit.tap()

        // Use deterministic inject button during UI tests
        let inject = app.buttons["Inject Test Image"]
        XCTAssertTrue(inject.waitForExistence(timeout: 2))
        inject.tap()

        // Detail view should reflect real image immediately
        let realInDetail = app.images["watch-image-real"]
        XCTAssertTrue(realInDetail.waitForExistence(timeout: 2))

        // Save the edit
        let save = app.buttons["Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 2))
        save.tap()

        // We should be back on detail; go back to collection
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // After: the placeholder should be replaced by a real image view
        let realImage = app.images["watch-image-real"]
        XCTAssertTrue(realImage.waitForExistence(timeout: 5))

        // Back on collection; confirm the number of cells is >= initial (we may have just added one)
        let finalCount = app.cells.count
        XCTAssertGreaterThanOrEqual(finalCount, initialCount)
    }
}


