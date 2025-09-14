import XCTest

/// UI tests validating the Settings Appearance header composition and behavior.
/// - What: Ensures the custom header row remains visible, the sheet stays open on theme change,
///         and the inline picker renders (non-collapsed) under the header.
/// - Why: Guards regressions around UIKit grouped header background and inline picker layout.
/// - How: Uses identifiers and structure checks instead of color assertions (XCUITest can't read colors).
final class SettingsAppearanceHeaderUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testHeaderRowExistsAndPickerNotCollapsed() throws {
        let app = XCUIApplication()
        app.launch()

        // Open Settings via menu button (stable identifier) then tap the Settings menu item
        let gearMenu = app.buttons["SettingsMenuButton"]
        XCTAssertTrue(gearMenu.waitForExistence(timeout: 3))
        gearMenu.tap()
        let settingsMenuItem = app.buttons["Settings"]
        XCTAssertTrue(settingsMenuItem.waitForExistence(timeout: 2))
        settingsMenuItem.tap()

        // Settings title visible
        XCTAssertTrue(app.navigationBars.staticTexts["Settings"].waitForExistence(timeout: 3))

        // Custom header row present
        XCTAssertTrue(app.otherElements["SettingsAppearanceHeaderRow"].exists)

        // Inline picker should render at least one theme cell (not collapsed)
        // Heuristic: Look for a known theme name cell under the list
        XCTAssertTrue(app.staticTexts["Daytime"].waitForExistence(timeout: 3))
    }

    func testSheetRemainsOpenAfterThemeChange() throws {
        let app = XCUIApplication()
        app.launch()

        // Open Settings via menu then tap the Settings menu item
        let gearMenu = app.buttons["SettingsMenuButton"]
        XCTAssertTrue(gearMenu.waitForExistence(timeout: 3))
        gearMenu.tap()
        let settingsMenuItem = app.buttons["Settings"]
        XCTAssertTrue(settingsMenuItem.waitForExistence(timeout: 2))
        settingsMenuItem.tap()

        // Change the theme by tapping a visible cell
        XCTAssertTrue(app.staticTexts["Daytime"].waitForExistence(timeout: 3))
        app.staticTexts["Daytime"].tap()

        // The sheet should remain visible after theme change
        XCTAssertTrue(app.navigationBars.staticTexts["Settings"].exists)
    }
}


