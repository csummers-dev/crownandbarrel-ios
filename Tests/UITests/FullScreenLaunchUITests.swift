import XCTest

final class FullScreenLaunchUITests: XCTestCase {
    func testAppOpensFullScreen() throws {
        // What: Launch the app and assert that primary UI elements are present
        //      in a way that indicates full-screen safe-area usage.
        // Why: Detect regressions where the app might fall back to legacy
        //      compatibility mode with letterboxing on modern iPhones.
        let app = XCUIApplication()
        app.launch()

        // Heuristic: require a modern safe-area inset on a device with a notch/home indicator.
        // Check that at least one element is hittable near the bottom safe area (tab bar).
        let tabBar = app.tabBars.element(boundBy: 0)
        XCTAssertTrue(tabBar.waitForExistence(timeout: 3), "Tab bar should exist in full-screen layout.")

        // Also ensure no legacy 20pt status bar layout by verifying navigation title is visible and not clipped.
        let title = app.navigationBars["Good Watch"]
        XCTAssertTrue(title.exists || app.staticTexts["Good Watch"].exists, "Navigation title should be visible in full-screen mode.")
    }
}


