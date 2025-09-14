import XCTest

/// UI tests to ensure accent color is applied to key UI affordances across themes.
/// - What: Verifies presence/visibility of accent-tinted elements rather than exact RGBA values
///          (XCUITest cannot reliably read SwiftUI Color values).
/// - Why: Prevent regressions where titles or icons lose accent styling.
/// - How: Heuristics: principal titles exist, gear icon exists as a button, add button exists and is hittable.
final class AccentColorUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testAccentAppliedToKeyElements() throws {
        let app = XCUIApplication()
        app.launch()

        // Collection tab – Add button should exist and be hittable (accent-filled circle with plus)
        let addButton = app.buttons["Add watch"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        XCTAssertTrue(addButton.isHittable)

        // Settings gear should exist in the nav bar (toolbar trailing item)
        let gear = app.navigationBars.buttons["gearshape"]
        XCTAssertTrue(gear.exists || app.buttons["gearshape"].exists)

        // Stats tab title should be present (accent styled principal text)
        app.tabBars.buttons["Stats"].tap()
        let statsTitle = app.navigationBars.staticTexts["Stats"]
        XCTAssertTrue(statsTitle.waitForExistence(timeout: 3))

        // Calendar tab title should be present as accent text
        app.tabBars.buttons["Calendar"].tap()
        let calendarTitle = app.navigationBars.staticTexts["Calendar"]
        XCTAssertTrue(calendarTitle.waitForExistence(timeout: 3))
    }
}


