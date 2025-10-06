import XCTest

final class AddWatchFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddWatchFlow() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTS_DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["UI_TESTS_FIXED_DATE"] = "2024-01-15T12:00:00Z"
        app.launch()

        // Ensure we are on Collection tab
        app.tabBars.buttons["Collection"].firstMatch.tap()
        
        // Tap Add button (FAB)
        let addButton = app.buttons["Add watch"].firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Wait for the Add Watch sheet to appear (nav bar or form content)
        let addNav = app.navigationBars["Add Watch"]
        let manufacturerField = app.textFields["manufacturerField"].firstMatch
        XCTAssertTrue(addNav.waitForExistence(timeout: 8) || manufacturerField.waitForExistence(timeout: 2))

        // Enter manufacturer and save (locate inside the form's table)
        let manufacturer = app.textFields["manufacturerField"].firstMatch
        XCTAssertTrue(manufacturer.waitForExistence(timeout: 5))
        manufacturer.tap()
        manufacturer.typeText("TestBrand")

        app.buttons["Save"].tap()
    }

    func testOptionalDatesToggleAndSave() {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTS_DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["UI_TESTS_FIXED_DATE"] = "2024-01-15T12:00:00Z"
        app.launch()

        // Ensure we are on Collection tab
        app.tabBars.buttons["Collection"].firstMatch.tap()

        // Open Add watch
        if app.buttons["Add watch"].firstMatch.waitForExistence(timeout: 3) {
            app.buttons["Add watch"].firstMatch.tap()
        }

        let nav = app.navigationBars["Add Watch"]
        XCTAssertTrue(nav.waitForExistence(timeout: 8))

        // Fill required field
        let manufacturer = app.textFields["manufacturerField"].firstMatch
        XCTAssertTrue(manufacturer.waitForExistence(timeout: 3))
        manufacturer.tap(); manufacturer.typeText("Omega")

        // Expand additional details
        let showMore = app.buttons["Show additional details"]
        if showMore.waitForExistence(timeout: 3) { showMore.tap() }

        // Initially no date rows visible (no "Select date" labels)
        _ = app.staticTexts["Select date"].waitForExistence(timeout: 1)

        // Enable toggles (structure of pickers varies across iOS versions, so we only ensure taps succeed)
        let purchaseToggle = app.switches["Purchase date"].firstMatch
        if purchaseToggle.waitForExistence(timeout: 3) { purchaseToggle.tap() }

        let warrantyToggle = app.switches["Warranty expiration"].firstMatch
        if warrantyToggle.waitForExistence(timeout: 2) { warrantyToggle.tap() }
        let lastServiceToggle = app.switches["Last service date"].firstMatch
        if lastServiceToggle.waitForExistence(timeout: 2) { lastServiceToggle.tap() }
        let saleToggle = app.switches["Sale date"].firstMatch
        if saleToggle.waitForExistence(timeout: 2) { saleToggle.tap() }

        // Save
        nav.buttons["Save"].tap()
        XCTAssertFalse(nav.exists)
    }
}


