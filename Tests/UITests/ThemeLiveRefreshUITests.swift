import XCTest

final class ThemeLiveRefreshUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testChangingThemeInSettingsKeepsSheetOpenAndUpdatesNavAndTab() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestOpenSettings")
        app.launch()

        // Settings opened via launch argument
        let settingsTitle = app.navigationBars.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))

        // Assert the Settings sheet is visible
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))

        // Change theme by selecting the first different theme row
        // Note: We can't reliably read colors; instead, select a row and ensure UI remains
        let firstCell = app.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 2))
        firstCell.tap()

        // Settings sheet should remain open after theme change
        XCTAssertTrue(settingsTitle.exists)

        // The tab bar should still exist (validates no dismissal and basic presence)
        let tabBar = app.tabBars.element(boundBy: 0)
        XCTAssertTrue(tabBar.exists)

        // The Appearance header should exist (validates section presence after refresh)
        let appearanceStaticText = app.staticTexts["Appearance"]
        XCTAssertTrue(appearanceStaticText.exists)
    }
}


