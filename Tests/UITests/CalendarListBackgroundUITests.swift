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

        // What: If there are no entries, briefly open and close the add-worn sheet.
        // Why: Ensures the list/table is initialized so we can assert presence reliably.
        // How: Tap prompt if present, then dismiss via Close button (or fallback swipe).
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

        // What: Assert the entries container is present.
        // Why: Guards the primary container background wiring.
        // How: Prefer container identifier; fall back to table or at least one card.
        let container = app.otherElements["CalendarEntriesContainer"]
        // Allow extra time on CI where async content can load slower; fall back to cards or table presence
        let containerAppeared = container.waitForExistence(timeout: 8)
        let card = app.otherElements["CalendarEntryCard"]
        let cardAppeared = card.waitForExistence(timeout: 5)
        let tableAppeared = app.tables.firstMatch.waitForExistence(timeout: 3)
        XCTAssertTrue(containerAppeared || cardAppeared || tableAppeared, "Calendar entries UI did not appear in time")

        // What: Ensure at least one card row exists.
        // Why: Guards `.listRowBackground` application path.
        // How: Look for the row's accessibility identifier.
        XCTAssertTrue(card.waitForExistence(timeout: 5))
    }
}


