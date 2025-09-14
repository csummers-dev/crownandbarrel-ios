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
        app.launchArguments.append("--uiTestOpenSettings")
        app.launch()

        // Settings should already be open via launch argument
        XCTAssertTrue(app.navigationBars.staticTexts["Settings"].waitForExistence(timeout: 3))

        // Settings title visible
        XCTAssertTrue(app.navigationBars.staticTexts["Settings"].waitForExistence(timeout: 3))

        // Custom header row present (allow short wait on CI)
        XCTAssertTrue(app.otherElements["SettingsAppearanceHeaderRow"].waitForExistence(timeout: 2))

        // Inline picker should render at least one theme cell (not collapsed)
        // Heuristic: Look for a known theme name cell under the list
        XCTAssertTrue(app.staticTexts["Daytime"].waitForExistence(timeout: 3))
    }

    func testSheetRemainsOpenAfterThemeChange() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestOpenSettings")
        app.launch()

        // Settings opened via launch argument
        XCTAssertTrue(app.navigationBars.staticTexts["Settings"].waitForExistence(timeout: 3))

        // Change the theme by tapping a visible cell (fallback to first cell if theme name varies)
        if app.staticTexts["Daytime"].waitForExistence(timeout: 3) {
            app.staticTexts["Daytime"].tap()
        } else {
            let firstCell = app.cells.element(boundBy: 0)
            XCTAssertTrue(firstCell.waitForExistence(timeout: 2))
            firstCell.tap()
        }

        // The sheet should remain visible after theme change
        XCTAssertTrue(app.navigationBars.staticTexts["Settings"].exists)
    }
}


