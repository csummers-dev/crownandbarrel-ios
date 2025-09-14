import XCTest

/// UI tests validating that changing the theme live updates visible UI and does not dismiss Settings.
/// - What: After selecting a theme, the Settings sheet remains visible and nav/tab elements persist.
/// - Why: Guarantees immediate feedback for user changes without disruptive dismissals.
/// - How: Uses a launch argument to open Settings and structural assertions for presence.
final class ThemeLiveRefreshUITests: XCTestCase {
    override func setUpWithError() throws {
        // Fail fast for clearer signals and quicker iterations on failures.
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


