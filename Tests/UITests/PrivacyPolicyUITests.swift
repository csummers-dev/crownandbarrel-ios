import XCTest

final class PrivacyPolicyUITests: XCTestCase {
    func testPrivacyPolicyOpensAndDisplaysContent() {
        let app = XCUIApplication()
        app.launchArguments += ["--uiTestOpenPrivacy"]
        app.launch()

        // Assert the sheet opens with the correct title
        let navBar = app.navigationBars["Privacy Policy"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5), "Privacy Policy navigation bar should be visible")

        // Assert that a web view is present (content loaded)
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "Privacy Policy web view should be present")
    }
}


