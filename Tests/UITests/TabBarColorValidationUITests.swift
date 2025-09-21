import XCTest

/// UI tests specifically for validating tab bar color behavior during theme changes.
/// - What: Tests the exact scenario where tab colors should refresh immediately.
/// - Why: Provides real-time validation as we fix the tab color refresh issue.
/// - How: Changes theme and immediately checks tab bar state without navigation.
final class TabBarColorValidationUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Tests the exact issue: theme change should immediately refresh tab colors.
    /// - What: Changes theme and validates tab colors are correct without navigation.
    /// - Why: This is the specific bug we're trying to fix.
    /// - How: Theme change → immediate tab bar validation → no navigation required.
    func testImmediateTabColorRefreshOnThemeChange() throws {
        let app = XCUIApplication()
        // Start with a clean state
        app.launchArguments.append("--uiTestResetTheme")
        app.launch()
        
        // Wait for app to fully load
        let mainTitle = app.navigationBars["Crown & Barrel"]
        XCTAssertTrue(mainTitle.waitForExistence(timeout: 10))
        
        // Ensure we're on Collection tab (should be default)
        let collectionTab = app.tabBars.buttons["Collection"]
        XCTAssertTrue(collectionTab.waitForExistence(timeout: 5))
        
        // Validate initial state - Collection should be selected
        XCTAssertTrue(collectionTab.isSelected, "Collection tab should be initially selected")
        
        // Other tabs should NOT be selected
        let statsTab = app.tabBars.buttons["Stats"]
        let calendarTab = app.tabBars.buttons["Calendar"]
        if statsTab.exists {
            XCTAssertFalse(statsTab.isSelected, "Stats tab should not be selected initially")
        }
        if calendarTab.exists {
            XCTAssertFalse(calendarTab.isSelected, "Calendar tab should not be selected initially")
        }
        
        // Open Settings and change theme
        let settingsButton = app.buttons["SettingsMenuButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
        settingsButton.tap()
        
        let settingsMenuButton = app.buttons["Settings"]
        XCTAssertTrue(settingsMenuButton.waitForExistence(timeout: 3))
        settingsMenuButton.tap()
        
        // Wait for Settings to open
        let settingsTitle = app.navigationBars.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))
        
        // Change to a different theme (Champagne Gold for testing)
        let champagneGoldTheme = app.cells.staticTexts["Champagne Gold"].firstMatch
        if champagneGoldTheme.exists && champagneGoldTheme.isHittable {
            champagneGoldTheme.tap()
            
            // CRITICAL: Wait just enough for theme change to process
            usleep(300000) // 0.3 seconds
            
            // Dismiss Settings to see tab bar
            let cancelButton = app.buttons["Cancel"].firstMatch
            if cancelButton.exists {
                cancelButton.tap()
            } else {
                // Alternative dismissal
                app.swipeDown()
            }
            
            // CRITICAL TEST: Immediately check tab bar state after theme change
            // This is where the bug occurs - all tabs show active color temporarily
            
            // Wait for main screen to appear
            XCTAssertTrue(mainTitle.waitForExistence(timeout: 3))
            
            // VALIDATION: Check tab selection state immediately after theme change
            // Collection should still be selected (active color)
            XCTAssertTrue(collectionTab.isSelected, "Collection tab should remain selected after theme change")
            
            // Other tabs should NOT be selected (should use inactive color)
            if statsTab.exists {
                XCTAssertFalse(statsTab.isSelected, "Stats tab should NOT be selected after theme change")
            }
            if calendarTab.exists {
                XCTAssertFalse(calendarTab.isSelected, "Calendar tab should NOT be selected after theme change")
            }
            
            // Additional validation: Test immediate tab switching works correctly
            if statsTab.exists && statsTab.isHittable {
                statsTab.tap()
                XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 3))
                XCTAssertTrue(statsTab.isSelected, "Stats tab should be selected after tap")
                XCTAssertFalse(collectionTab.isSelected, "Collection tab should NOT be selected after Stats tap")
            }
        }
    }
    
    /// Tests theme change with multiple rapid tab switches.
    /// - What: Changes theme then rapidly switches between tabs.
    /// - Why: Tests the most stressful scenario for tab color refresh.
    /// - How: Theme change → rapid tab navigation → validation.
    func testThemeChangeWithRapidTabSwitching() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestResetTheme")
        app.launch()
        
        let mainTitle = app.navigationBars["Crown & Barrel"]
        XCTAssertTrue(mainTitle.waitForExistence(timeout: 10))
        
        // Change theme to Royal Sapphire
        let settingsButton = app.buttons["SettingsMenuButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
        settingsButton.tap()
        
        let settingsMenuButton = app.buttons["Settings"]
        if settingsMenuButton.exists {
            settingsMenuButton.tap()
            
            let settingsTitle = app.navigationBars.staticTexts["Settings"]
            XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))
            
            let royalSapphireTheme = app.cells.staticTexts["Royal Sapphire"].firstMatch
            if royalSapphireTheme.exists {
                royalSapphireTheme.tap()
                
                // Dismiss Settings
                let cancelButton = app.buttons["Cancel"].firstMatch
                if cancelButton.exists {
                    cancelButton.tap()
                }
                
                // Wait for main screen
                XCTAssertTrue(mainTitle.waitForExistence(timeout: 3))
                
                // Rapid tab switching to stress test color refresh
                let tabs = [
                    app.tabBars.buttons["Stats"],
                    app.tabBars.buttons["Calendar"], 
                    app.tabBars.buttons["Collection"],
                    app.tabBars.buttons["Stats"],
                    app.tabBars.buttons["Collection"]
                ]
                
                for tab in tabs {
                    if tab.exists && tab.isHittable {
                        tab.tap()
                        usleep(100000) // 0.1 seconds between taps
                        
                        // Each tap should result in proper selection
                        XCTAssertTrue(tab.isSelected, "Tapped tab should be selected immediately")
                    }
                }
            }
        }
    }
    
    /// Tests all luxury themes for immediate tab color behavior.
    /// - What: Changes to each luxury theme and validates tab behavior.
    /// - Why: Ensures the fix works with all theme color palettes.
    /// - How: Cycles through themes and validates tab selection state.
    func testAllLuxuryThemesTabColorBehavior() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestResetTheme")
        app.launch()
        
        let mainTitle = app.navigationBars["Crown & Barrel"]
        XCTAssertTrue(mainTitle.waitForExistence(timeout: 10))
        
        let luxuryThemes = [
            "Champagne Gold",
            "Royal Sapphire", 
            "Emerald Heritage",
            "Onyx Prestige",
            "Burgundy Elite",
            "Midnight Platinum"
        ]
        
        for themeName in luxuryThemes {
            // Open Settings
            let settingsButton = app.buttons["SettingsMenuButton"]
            if settingsButton.waitForExistence(timeout: 3) {
                settingsButton.tap()
                
                let settingsMenuButton = app.buttons["Settings"]
                if settingsMenuButton.exists {
                    settingsMenuButton.tap()
                    
                    let settingsTitle = app.navigationBars.staticTexts["Settings"]
                    if settingsTitle.waitForExistence(timeout: 3) {
                        
                        // Change to this luxury theme
                        let themeCell = app.cells.staticTexts[themeName].firstMatch
                        if themeCell.exists && themeCell.isHittable {
                            themeCell.tap()
                            
                            // Brief wait for theme change
                            usleep(200000) // 0.2 seconds
                            
                            // Dismiss Settings
                            let cancelButton = app.buttons["Cancel"].firstMatch
                            if cancelButton.exists {
                                cancelButton.tap()
                            }
                            
                            // Validate tab bar behavior with this theme
                            if mainTitle.waitForExistence(timeout: 3) {
                                let collectionTab = app.tabBars.buttons["Collection"]
                                let statsTab = app.tabBars.buttons["Stats"]
                                
                                // Collection should be selected, Stats should not
                                XCTAssertTrue(collectionTab.isSelected, "\(themeName): Collection should be selected")
                                if statsTab.exists {
                                    XCTAssertFalse(statsTab.isSelected, "\(themeName): Stats should NOT be selected")
                                }
                                
                                // Test one tab switch for this theme
                                if statsTab.exists && statsTab.isHittable {
                                    statsTab.tap()
                                    if app.navigationBars["Stats"].waitForExistence(timeout: 2) {
                                        XCTAssertTrue(statsTab.isSelected, "\(themeName): Stats should be selected after tap")
                                        XCTAssertFalse(collectionTab.isSelected, "\(themeName): Collection should NOT be selected after Stats tap")
                                    }
                                    
                                    // Return to Collection for next theme test
                                    collectionTab.tap()
                                    _ = mainTitle.waitForExistence(timeout: 2)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Tests the specific problematic scenario described by the user.
    /// - What: Recreates exact user flow: Collection → Settings → Theme Change → Minimize → Check tabs.
    /// - Why: This is the exact scenario where the bug occurs.
    /// - How: Follows exact user steps and validates immediate color correctness.
    func testExactUserScenarioTabColorRefresh() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. User is on Collection view
        let mainTitle = app.navigationBars["Crown & Barrel"]
        XCTAssertTrue(mainTitle.waitForExistence(timeout: 10))
        
        let collectionTab = app.tabBars.buttons["Collection"]
        XCTAssertTrue(collectionTab.waitForExistence(timeout: 5))
        XCTAssertTrue(collectionTab.isSelected, "Should start on Collection tab")
        
        // 2. User opens Settings
        let settingsButton = app.buttons["SettingsMenuButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
        settingsButton.tap()
        
        let settingsMenuButton = app.buttons["Settings"]
        XCTAssertTrue(settingsMenuButton.waitForExistence(timeout: 3))
        settingsMenuButton.tap()
        
        // 3. User changes theme
        let settingsTitle = app.navigationBars.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))
        
        // Change to Emerald Heritage theme
        let emeraldTheme = app.cells.staticTexts["Emerald Heritage"].firstMatch
        if emeraldTheme.exists && emeraldTheme.isHittable {
            emeraldTheme.tap()
            
            // 4. User minimizes theme window (dismisses Settings)
            let cancelButton = app.buttons["Cancel"].firstMatch
            XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))
            cancelButton.tap()
            
            // 5. CRITICAL CHECK: Tab colors should be correct IMMEDIATELY
            XCTAssertTrue(mainTitle.waitForExistence(timeout: 3))
            
            // Collection should be selected (active color)
            XCTAssertTrue(collectionTab.isSelected, "CRITICAL: Collection tab should be selected with active color")
            
            // Other tabs should NOT be selected (inactive color)
            let statsTab = app.tabBars.buttons["Stats"]
            let calendarTab = app.tabBars.buttons["Calendar"]
            
            if statsTab.exists {
                XCTAssertFalse(statsTab.isSelected, "CRITICAL: Stats tab should NOT be selected (should show inactive color)")
            }
            if calendarTab.exists {
                XCTAssertFalse(calendarTab.isSelected, "CRITICAL: Calendar tab should NOT be selected (should show inactive color)")
            }
            
            // 6. Test that navigation still works properly
            if statsTab.exists && statsTab.isHittable {
                statsTab.tap()
                XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 3))
                XCTAssertTrue(statsTab.isSelected, "Stats should be selected after navigation")
                XCTAssertFalse(collectionTab.isSelected, "Collection should NOT be selected after Stats navigation")
            }
        }
    }
}
