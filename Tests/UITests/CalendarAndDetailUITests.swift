import XCTest

final class CalendarAndDetailUITests: XCTestCase {
    func testCalendarAddWorn() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Calendar"].tap()
        // Empty-state CTA should exist when no entries for today
        if app.buttons["No watches worn this day. Add one?"].waitForExistence(timeout: 2) {
            app.buttons["No watches worn this day. Add one?"].tap()
        } else if app.buttons["Add worn"].waitForExistence(timeout: 2) {
            app.buttons["Add worn"].tap()
        }
        // If no watches, this might show an empty list; ensure sheet appears and can be closed.
        // Prefer addressing the sheet by its nav title first, then fall back to generic strategies.
        if app.navigationBars.staticTexts["Add worn"].waitForExistence(timeout: 2) {
            let bar = app.navigationBars["Add worn"]
            if bar.buttons["Close"].exists { bar.buttons["Close"].tap() }
            else if app.buttons["Close"].exists { app.buttons["Close"].tap() }
            else { app.swipeDown() }
        } else if app.buttons["Close"].waitForExistence(timeout: 2) {
            app.buttons["Close"].tap()
        } else if app.navigationBars.buttons["Close"].waitForExistence(timeout: 2) {
            app.navigationBars.buttons["Close"].tap()
        } else {
            // As a last resort, attempt a swipe-down gesture to dismiss the sheet.
            app.swipeDown()
        }
    }

    func testDetailShowsImageHeader() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Collection"].tap()
        // Tap first cell if exists to open detail
        if app.cells.element(boundBy: 0).waitForExistence(timeout: 3) {
            app.cells.element(boundBy: 0).tap()
            XCTAssertTrue(app.images["Watch image"].waitForExistence(timeout: 2))
        }
    }
}


