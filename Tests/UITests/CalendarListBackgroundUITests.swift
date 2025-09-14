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
        if addPrompt.waitForExistence(timeout: 2) {
            addPrompt.tap()
            // Dismiss the sheet robustly across OS variations
            if app.buttons["Close"].waitForExistence(timeout: 2) {
                app.buttons["Close"].tap()
            } else if app.navigationBars.buttons["Close"].waitForExistence(timeout: 2) {
                app.navigationBars.buttons["Close"].tap()
            } else {
                app.swipeDown()
            }
        }

        // Assert the entries container is present (primary background applied by view code)
        let container = app.otherElements["CalendarEntriesContainer"]
        // Allow extra time on CI where async content can load slower; fall back to cards or table presence
        let containerAppeared = container.waitForExistence(timeout: 8)
        let card = app.otherElements["CalendarEntryCard"]
        let cardAppeared = card.waitForExistence(timeout: 5)
        let tableAppeared = app.tables.firstMatch.waitForExistence(timeout: 3)
        XCTAssertTrue(containerAppeared || cardAppeared || tableAppeared, "Calendar entries UI did not appear in time")

        // Assert our card rows exist via accessibility identifier set on the row content
        let card = app.otherElements["CalendarEntryCard"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
    }
}


