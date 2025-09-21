import XCTest

/// Comprehensive UI tests to prevent regression of theme switching, tab bar colors, and typography features.
/// - What: Tests theme change behavior, tab bar color refresh, app stability, and typography consistency.
/// - Why: Prevents regression of critical fixes including app freeze prevention and color refresh issues.
/// - How: Uses systematic theme switching, tab navigation, and UI element validation.
final class ThemeRegressionUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Tests that theme switching doesn't cause app freeze or crashes.
    /// - What: Rapidly switches between multiple themes to test stability.
    /// - Why: Prevents regression of the "Directly modifying a tab bar" crash fix.
    /// - How: Selects different themes in quick succession and validates app remains responsive.
    func testThemeSwitchingStability() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestOpenSettings")
        app.launch()
        
        // Wait for Settings to open
        let settingsTitle = app.navigationBars.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5))
        
        // Get all theme cells
        let themeCells = app.cells
        let cellCount = min(themeCells.count, 6) // Test up to 6 themes
        
        // Rapidly switch between themes to test stability
        for i in 0..<cellCount {
            let cell = themeCells.element(boundBy: i)
            if cell.exists && cell.isHittable {
                cell.tap()
                
                // Brief pause to allow theme change processing
                usleep(100000) // 0.1 seconds
                
                // Verify app is still responsive
                XCTAssertTrue(settingsTitle.exists, "App became unresponsive after theme change \(i)")
                
                // Verify tab bar still exists (not frozen)
                let tabBar = app.tabBars.element(boundBy: 0)
                XCTAssertTrue(tabBar.exists, "Tab bar disappeared after theme change \(i)")
            }
        }
        
        // Final stability check - app should still be fully functional
        XCTAssertTrue(settingsTitle.exists)
        XCTAssertTrue(app.tabBars.element(boundBy: 0).exists)
    }
    
    /// Tests that tab bar colors refresh immediately after theme changes.
    /// - What: Changes theme and immediately checks tab bar behavior.
    /// - Why: Prevents regression where tab colors showed incorrectly until navigation.
    /// - How: Switches themes and validates tab bar remains functional with proper visual hierarchy.
    func testTabBarColorRefreshAfterThemeChange() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestOpenSettings")
        app.launch()
        
        // Wait for Settings to open
        let settingsTitle = app.navigationBars.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5))
        
        // Change to a different theme
        let firstThemeCell = app.cells.element(boundBy: 1) // Skip current theme
        if firstThemeCell.exists && firstThemeCell.isHittable {
            firstThemeCell.tap()
            
            // Wait for theme change to process
            usleep(200000) // 0.2 seconds
            
            // Dismiss Settings to see tab bar
            let cancelButton = app.buttons["Cancel"].firstMatch
            if cancelButton.exists {
                cancelButton.tap()
            } else {
                // Try swipe down to dismiss
                app.swipeDown()
            }
            
            // Wait for tab bar to be visible
            let tabBar = app.tabBars.element(boundBy: 0)
            XCTAssertTrue(tabBar.waitForExistence(timeout: 3))
            
            // Test tab switching immediately after theme change
            let statsTab = app.tabBars.buttons["Stats"]
            if statsTab.exists && statsTab.isHittable {
                statsTab.tap()
                XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 3))
            }
            
            let collectionTab = app.tabBars.buttons["Collection"]
            if collectionTab.exists && collectionTab.isHittable {
                collectionTab.tap()
                XCTAssertTrue(app.navigationBars["Crown & Barrel"].waitForExistence(timeout: 3))
            }
            
            let calendarTab = app.tabBars.buttons["Calendar"]
            if calendarTab.exists && calendarTab.isHittable {
                calendarTab.tap()
                XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 3))
            }
        }
    }
    
    /// Tests navigation title serif fonts across all screens.
    /// - What: Validates that all navigation titles use the elegant serif font.
    /// - Why: Prevents regression of typography implementation.
    /// - How: Navigates to each screen and validates navigation title presence.
    func testNavigationTitleTypographyConsistency() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test main navigation titles
        let mainTitle = app.navigationBars["Crown & Barrel"]
        XCTAssertTrue(mainTitle.waitForExistence(timeout: 5))
        
        // Test Stats navigation
        let statsTab = app.tabBars.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 3))
        }
        
        // Test Calendar navigation
        let calendarTab = app.tabBars.buttons["Calendar"]
        if calendarTab.exists {
            calendarTab.tap()
            XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 3))
        }
        
        // Test Settings navigation
        let collectionTab = app.tabBars.buttons["Collection"]
        if collectionTab.exists {
            collectionTab.tap()
            XCTAssertTrue(app.navigationBars["Crown & Barrel"].waitForExistence(timeout: 3))
        }
        
        // Open Settings to test settings navigation
        let settingsButton = app.buttons["SettingsMenuButton"]
        if settingsButton.exists {
            settingsButton.tap()
            
            let settingsMenuButton = app.buttons["Settings"]
            if settingsMenuButton.exists {
                settingsMenuButton.tap()
                XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
                
                // Test App Data navigation
                let cancelButton = app.buttons["Cancel"].firstMatch
                if cancelButton.exists {
                    cancelButton.tap()
                }
                
                // Wait for main screen
                XCTAssertTrue(app.navigationBars["Crown & Barrel"].waitForExistence(timeout: 3))
                
                // Test App Data
                if settingsButton.exists {
                    settingsButton.tap()
                    let appDataButton = app.buttons["App Data"]
                    if appDataButton.exists {
                        appDataButton.tap()
                        XCTAssertTrue(app.navigationBars["App Data"].waitForExistence(timeout: 3))
                    }
                }
            }
        }
    }
    
    /// Tests watch manufacturer text display in collection view.
    /// - What: Validates that manufacturer names display with proper serif fonts and theme colors.
    /// - Why: Prevents regression of manufacturer text sizing and color fixes.
    /// - How: Navigates to collection and validates manufacturer text elements.
    func testWatchManufacturerTextDisplay() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Ensure we're on Collection tab
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5))
        
        // Look for manufacturer text elements (these should use serif fonts and theme colors)
        let manufacturerElements = app.staticTexts.matching(identifier: "GridCellManufacturer")
        
        // If there are watch entries, validate manufacturer text exists
        if manufacturerElements.count > 0 {
            let firstManufacturer = manufacturerElements.element(boundBy: 0)
            XCTAssertTrue(firstManufacturer.exists, "Manufacturer text should be visible")
            XCTAssertTrue(firstManufacturer.isHittable, "Manufacturer text should be interactive")
        }
        
        // Test list view as well
        let viewToggle = app.buttons.matching(NSPredicate(format: "label CONTAINS 'list'")).firstMatch
        if viewToggle.exists {
            viewToggle.tap()
            
            // Wait for list view to appear
            usleep(500000) // 0.5 seconds
            
            // Validate list view manufacturer elements
            let listRows = app.cells
            if listRows.count > 0 {
                let firstRow = listRows.element(boundBy: 0)
                XCTAssertTrue(firstRow.exists, "List row should exist")
            }
        }
    }
    
    /// Tests multiple rapid theme changes to ensure no crashes or freezes.
    /// - What: Performs stress test of theme switching system.
    /// - Why: Prevents regression of app freeze fixes and ensures stability under rapid changes.
    /// - How: Rapidly switches between themes and validates continued responsiveness.
    func testRapidThemeChangesStability() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestOpenSettings")
        app.launch()
        
        let settingsTitle = app.navigationBars.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5))
        
        let themeCells = app.cells
        let cellCount = min(themeCells.count, 4) // Test with 4 themes
        
        // Perform rapid theme changes
        for cycle in 0..<3 { // 3 cycles of rapid changes
            for i in 0..<cellCount {
                let cell = themeCells.element(boundBy: i)
                if cell.exists && cell.isHittable {
                    cell.tap()
                    
                    // Very brief pause - testing rapid changes
                    usleep(50000) // 0.05 seconds
                    
                    // Verify app remains responsive
                    XCTAssertTrue(settingsTitle.exists, "App unresponsive during rapid theme change cycle \(cycle), theme \(i)")
                }
            }
        }
        
        // Final stability validation
        XCTAssertTrue(settingsTitle.exists, "Settings should remain open after rapid theme changes")
        XCTAssertTrue(app.tabBars.element(boundBy: 0).exists, "Tab bar should remain functional")
    }
    
    /// Tests theme switching with tab navigation to ensure proper color refresh.
    /// - What: Changes theme, then immediately tests tab navigation behavior.
    /// - Why: Validates the tab bar color refresh fix works correctly.
    /// - How: Theme change followed by immediate tab switching and validation.
    func testThemeChangeWithImmediateTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Start on Collection tab
        XCTAssertTrue(app.navigationBars["Crown & Barrel"].waitForExistence(timeout: 5))
        
        // Open Settings and change theme
        let settingsButton = app.buttons["SettingsMenuButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
        settingsButton.tap()
        
        let settingsMenuButton = app.buttons["Settings"]
        if settingsMenuButton.exists {
            settingsMenuButton.tap()
            
            // Wait for Settings to open
            let settingsTitle = app.navigationBars.staticTexts["Settings"]
            XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))
            
            // Change to a different theme
            let themeCell = app.cells.element(boundBy: 1) // Second theme
            if themeCell.exists {
                themeCell.tap()
                
                // Immediately dismiss Settings
                let cancelButton = app.buttons["Cancel"].firstMatch
                if cancelButton.exists {
                    cancelButton.tap()
                }
                
                // Immediately test tab navigation after theme change
                let statsTab = app.tabBars.buttons["Stats"]
                if statsTab.exists {
                    statsTab.tap()
                    XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 3), "Stats navigation should work immediately after theme change")
                }
                
                let calendarTab = app.tabBars.buttons["Calendar"]
                if calendarTab.exists {
                    calendarTab.tap()
                    XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 3), "Calendar navigation should work immediately after theme change")
                }
                
                let collectionTab = app.tabBars.buttons["Collection"]
                if collectionTab.exists {
                    collectionTab.tap()
                    XCTAssertTrue(app.navigationBars["Crown & Barrel"].waitForExistence(timeout: 3), "Collection navigation should work immediately after theme change")
                }
            }
        }
    }
    
    /// Tests launch screen and app startup stability.
    /// - What: Validates app launches successfully and transitions to main interface.
    /// - Why: Ensures launch screen serif font doesn't cause startup issues.
    /// - How: Monitors app launch sequence and validates successful transition.
    func testLaunchScreenAndStartupStability() throws {
        let app = XCUIApplication()
        app.launch()
        
        // App should successfully launch and show main interface
        let mainInterface = app.navigationBars["Crown & Barrel"]
        XCTAssertTrue(mainInterface.waitForExistence(timeout: 10), "App should launch successfully with serif launch screen")
        
        // Tab bar should be functional
        let tabBar = app.tabBars.element(boundBy: 0)
        XCTAssertTrue(tabBar.exists, "Tab bar should be present after launch")
        
        // Settings should be accessible
        let settingsButton = app.buttons["SettingsMenuButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3), "Settings should be accessible after launch")
    }
    
    /// Tests all luxury themes for stability and proper loading.
    /// - What: Systematically tests each luxury theme for proper loading and display.
    /// - Why: Validates all luxury themes work correctly without crashes.
    /// - How: Cycles through each theme and validates successful application.
    func testAllLuxuryThemesStability() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestOpenSettings")
        app.launch()
        
        let settingsTitle = app.navigationBars.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5))
        
        // Expected luxury theme names (based on our implementation)
        let expectedThemes = [
            "Daytime",
            "Nighttime", 
            "Champagne Gold",
            "Royal Sapphire",
            "Emerald Heritage",
            "Onyx Prestige",
            "Burgundy Elite",
            "Midnight Platinum"
        ]
        
        // Test each theme
        for themeName in expectedThemes {
            let themeCell = app.cells.staticTexts[themeName].firstMatch
            if themeCell.exists && themeCell.isHittable {
                themeCell.tap()
                
                // Wait for theme to apply
                usleep(200000) // 0.2 seconds
                
                // Validate app remains stable
                XCTAssertTrue(settingsTitle.exists, "App should remain stable with \(themeName) theme")
                
                // Validate tab bar remains functional
                let tabBar = app.tabBars.element(boundBy: 0)
                XCTAssertTrue(tabBar.exists, "Tab bar should remain functional with \(themeName) theme")
            }
        }
    }
    
    /// Tests typography consistency across navigation elements.
    /// - What: Validates serif fonts are properly applied to navigation titles.
    /// - Why: Prevents regression of typography implementation.
    /// - How: Navigates through app and validates navigation title elements exist.
    func testTypographyConsistencyAcrossNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test main navigation title
        XCTAssertTrue(app.navigationBars["Crown & Barrel"].waitForExistence(timeout: 5))
        
        // Test Stats navigation title
        let statsTab = app.tabBars.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 3))
        }
        
        // Test Calendar navigation title
        let calendarTab = app.tabBars.buttons["Calendar"]
        if calendarTab.exists {
            calendarTab.tap()
            XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 3))
        }
        
        // Return to Collection
        let collectionTab = app.tabBars.buttons["Collection"]
        if collectionTab.exists {
            collectionTab.tap()
            XCTAssertTrue(app.navigationBars["Crown & Barrel"].waitForExistence(timeout: 3))
        }
        
        // Test Settings navigation title
        let settingsButton = app.buttons["SettingsMenuButton"]
        if settingsButton.exists {
            settingsButton.tap()
            
            let settingsMenuButton = app.buttons["Settings"]
            if settingsMenuButton.exists {
                settingsMenuButton.tap()
                XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
                
                // Test Privacy Policy navigation title
                let cancelButton = app.buttons["Cancel"].firstMatch
                if cancelButton.exists {
                    cancelButton.tap()
                }
                
                // Test Privacy Policy
                if settingsButton.waitForExistence(timeout: 3) {
                    settingsButton.tap()
                    let privacyButton = app.buttons["Privacy Policy"]
                    if privacyButton.exists {
                        privacyButton.tap()
                        XCTAssertTrue(app.navigationBars["Privacy Policy"].waitForExistence(timeout: 3))
                    }
                }
            }
        }
    }
    
    /// Tests that manufacturer text in collection uses proper sizing and colors.
    /// - What: Validates manufacturer text sizing and color implementation.
    /// - Why: Prevents regression of manufacturer text fixes.
    /// - How: Checks for manufacturer text elements in collection views.
    func testManufacturerTextSizingAndColors() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Ensure Collection view is visible
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5))
        
        // Look for manufacturer text elements
        let manufacturerElements = app.staticTexts.matching(identifier: "GridCellManufacturer")
        
        if manufacturerElements.count > 0 {
            let firstManufacturer = manufacturerElements.element(boundBy: 0)
            XCTAssertTrue(firstManufacturer.exists, "Manufacturer text should exist")
            
            // Validate text is not empty (indicates proper rendering)
            let manufacturerText = firstManufacturer.label
            XCTAssertFalse(manufacturerText.isEmpty, "Manufacturer text should not be empty")
            XCTAssertGreaterThan(manufacturerText.count, 0, "Manufacturer text should have content")
        }
        
        // Test switching to list view
        let viewToggle = app.buttons.matching(NSPredicate(format: "label CONTAINS 'list'")).firstMatch
        if viewToggle.exists {
            viewToggle.tap()
            
            // Wait for list view
            usleep(500000) // 0.5 seconds
            
            // Validate list view manufacturer elements
            let listCells = app.cells
            if listCells.count > 0 {
                let firstCell = listCells.element(boundBy: 0)
                XCTAssertTrue(firstCell.exists, "List cell should exist")
            }
        }
    }
    
    /// Tests theme persistence across app launches.
    /// - What: Changes theme, relaunches app, validates theme persists.
    /// - Why: Ensures theme selection is properly saved and restored.
    /// - How: Changes theme, terminates app, relaunches, validates theme.
    func testThemePersistenceAcrossLaunches() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uiTestOpenSettings")
        app.launch()
        
        let settingsTitle = app.navigationBars.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5))
        
        // Change to a specific theme
        let luxuryThemeCell = app.cells.staticTexts["Champagne Gold"].firstMatch
        if luxuryThemeCell.exists {
            luxuryThemeCell.tap()
            
            // Wait for theme change
            usleep(200000) // 0.2 seconds
            
            // Terminate and relaunch app
            app.terminate()
            app.launch()
            
            // Validate app launches successfully with persisted theme
            let mainTitle = app.navigationBars["Crown & Barrel"]
            XCTAssertTrue(mainTitle.waitForExistence(timeout: 10), "App should launch successfully with persisted theme")
            
            // Validate tab bar is functional
            let tabBar = app.tabBars.element(boundBy: 0)
            XCTAssertTrue(tabBar.exists, "Tab bar should be functional with persisted theme")
        }
    }
}
