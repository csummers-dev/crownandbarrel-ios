import XCTest

/// UI tests for the Stats screen title presentation.
/// - What: Ensures the title has no dropdown/chevron indicator by removing toolbarTitleMenu.
/// - Why: User requirement for a clean, static title without an affordance.
/// - How: Navigates to the Stats tab and asserts the principal title exists; heuristically
///         ensure no button with chevron label is near the title.
final class StatsTitleUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testStatsTitleHasNoChevronMenu() throws {
        let app = XCUIApplication()
        app.launch()

        // Go to Stats tab
        let statsTab = app.tabBars.buttons["Stats"]
        XCTAssertTrue(statsTab.waitForExistence(timeout: 3))
        statsTab.tap()

        // Expect the static title text "Stats" to exist.
        let title = app.navigationBars.staticTexts["Stats"]
        XCTAssertTrue(title.waitForExistence(timeout: 3))

        // Heuristic: ensure there is no button near the title with a chevron-down system label.
        // SwiftUI often exposes the title menu as a button with label "chevron.down" when present.
        let chevronDown = app.buttons.matching(identifier: "chevron.down").firstMatch
        XCTAssertFalse(chevronDown.exists)
    }
}


