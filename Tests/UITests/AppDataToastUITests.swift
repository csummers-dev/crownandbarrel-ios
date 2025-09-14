import XCTest

final class AppDataToastUITests: XCTestCase {
    func testSampleDataToastAppears() {
        let app = XCUIApplication()
        app.launchArguments += ["--uiTestOpenAppData"]
        app.launch()

        // Trigger sample data load (only in Debug builds); skip if absent
        let loadButton = app.buttons["Load sample data"].firstMatch
        if loadButton.waitForExistence(timeout: 5) {
            loadButton.tap()
            // Assert the toast text appears briefly
            let toast = app.staticTexts["Sample data loaded"].firstMatch
            XCTAssertTrue(toast.waitForExistence(timeout: 8))
        }
    }
}


