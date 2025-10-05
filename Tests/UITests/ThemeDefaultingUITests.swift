import XCTest

final class ThemeDefaultingUITests: XCTestCase {
    func testInitialThemeMatchesSystemWhenNoSavedPreference() {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTS_DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["UI_TESTS_FIXED_DATE"] = "2024-01-15T12:00:00Z"
        // Reset any persisted theme and expose system style via test hook
        app.launchArguments += ["--uiTestResetTheme", "--uiTestExposeThemeInfo"]
        app.launch()
        // Prefer reading from the exposed label for determinism in Simulator runs
        let info = app.staticTexts["UITestThemeInfo"]
        XCTAssertTrue(info.waitForExistence(timeout: 3))
        let value = info.label
        // Parse format: system:<light|dark>;theme:<id>
        let parts = value.split(separator: ";")
        let systemPart = parts.first { $0.hasPrefix("system:") }?.split(separator: ":").last.map(String.init) ?? "light"
        let themePart = parts.first { $0.hasPrefix("theme:") }?.split(separator: ":").last.map(String.init) ?? ""
        if systemPart == "dark" {
            XCTAssertEqual(themePart, "dark-default")
        } else {
            XCTAssertEqual(themePart, "light-default")
        }
    }

    func testInitialThemeForcedLight() {
        let suiteName = "UITestDefaults"
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTS_DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["UI_TESTS_FIXED_DATE"] = "2024-01-15T12:00:00Z"
        app.launchEnvironment["UITestDefaultsSuite"] = suiteName
        app.launchArguments += ["--uiTestResetTheme", "--uiTestExposeThemeInfo", "--uiTestForceSystemStyle=light"]
        app.launch()
        let info = app.staticTexts["UITestThemeInfo"]
        XCTAssertTrue(info.waitForExistence(timeout: 3))
        let value = info.label
        let system = value.split(separator: ";").first { $0.hasPrefix("system:") }?.split(separator: ":").last.map(String.init) ?? ""
        let theme = value.split(separator: ";").first { $0.hasPrefix("theme:") }?.split(separator: ":").last.map(String.init) ?? ""
        XCTAssertEqual(system, "light")
        XCTAssertEqual(theme, "light-default")
    }

    func testInitialThemeForcedDark() {
        let suiteName = "UITestDefaults"
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTS_DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["UI_TESTS_FIXED_DATE"] = "2024-01-15T12:00:00Z"
        app.launchEnvironment["UITestDefaultsSuite"] = suiteName
        app.launchArguments += ["--uiTestResetTheme", "--uiTestExposeThemeInfo", "--uiTestForceSystemStyle=dark"]
        app.launch()
        let info = app.staticTexts["UITestThemeInfo"]
        XCTAssertTrue(info.waitForExistence(timeout: 3))
        let value = info.label
        let system = value.split(separator: ";").first { $0.hasPrefix("system:") }?.split(separator: ":").last.map(String.init) ?? ""
        let theme = value.split(separator: ";").first { $0.hasPrefix("theme:") }?.split(separator: ":").last.map(String.init) ?? ""
        XCTAssertEqual(system, "dark")
        XCTAssertEqual(theme, "dark-default")
    }
}


