import XCTest

final class StatsUITests: XCTestCase {
    func testStatsTabLoads() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Stats"].tap()
        XCTAssertTrue(app.staticTexts["Most worn"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Least worn"].exists)
    }
}


