import XCTest

final class CalendarAndDetailUITests: XCTestCase {
    func testCalendarAddWorn() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Calendar"].tap()
        app.navigationBars.buttons["Add worn"].tap()
        // If no watches, this might show an empty list; at least ensure sheet appears and can be closed
        app.navigationBars.buttons["Close"].tap()
    }
}


