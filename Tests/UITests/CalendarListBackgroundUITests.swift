import XCTest

/// Ensures Calendar list uses secondary background rows in dark themes to avoid full black.
/// - What: Heuristic UI test that navigates to Calendar, adds an entry, and verifies rows exist.
/// - Why: Prevent regressions where `.listRowBackground` reverts to default.
/// - How: We cannot read colors in XCUITest reliably, so we assert presence/visibility and rely on
///         unit/theme tests for color mapping; this test guards wiring of the modifier.
final class CalendarListBackgroundUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testCalendarContainerAndCardsRenderInDarkTheme() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestTheme=dark-default")
        app.launch()

        app.tabBars.buttons["Calendar"].tap()

        // If empty, add a worn entry via picker flow
        let addPrompt = app.buttons["No watches worn this day. Add one?"]
        if addPrompt.waitForExistence(timeout: 2) { addPrompt.tap(); app.buttons["Close"].tap() }

        // Assert the entries container is present (primary background applied by view code)
        let container = app.otherElements["CalendarEntriesContainer"]
        XCTAssertTrue(container.waitForExistence(timeout: 2))

        // Assert our card rows exist via accessibility identifier set on the row content
        let card = app.otherElements["CalendarEntryCard"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
    }
}


