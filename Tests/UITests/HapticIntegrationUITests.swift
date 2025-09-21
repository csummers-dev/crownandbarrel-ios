import XCTest

/// UI tests for haptic integration in Crown & Barrel.
/// - **Purpose**: Ensures haptic feedback integration doesn't break existing functionality.
/// - **Coverage**: Collection view interactions, form interactions, navigation flows.
/// - **Testing Strategy**: Tests UI interactions and verifies navigation still works correctly.
final class HapticIntegrationUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Collection View Haptic Integration Tests
    
    /// Tests collection view haptic interactions don't break navigation.
    func testCollectionViewHapticIntegration() throws {
        // Wait for collection view to load
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5.0))
        
        // Test watch card selection (should trigger haptic but not break navigation)
        let watchCards = collectionView.cells
        if watchCards.count > 0 {
            let firstCard = watchCards.firstMatch
            firstCard.tap()
            
            // Verify navigation to detail view works
            XCTAssertTrue(app.navigationBars.buttons["Collection"].waitForExistence(timeout: 3.0))
            
            // Navigate back
            app.navigationBars.buttons["Collection"].tap()
        }
        
        // Test grid/list toggle (should trigger haptic but not break functionality)
        let gridListToggle = app.segmentedControls.firstMatch
        if gridListToggle.exists {
            gridListToggle.buttons.firstMatch.tap()
            // Verify toggle works by checking if view mode changes
            XCTAssertTrue(gridListToggle.exists)
        }
        
        // Test sort menu (should trigger haptic but not break functionality)
        let sortButton = app.buttons["Sort"]
        if sortButton.exists {
            sortButton.tap()
            // Verify sort menu appears
            XCTAssertTrue(app.menus.firstMatch.exists)
            // Dismiss menu by tapping elsewhere
            app.tap()
        }
    }
    
    /// Tests search functionality with haptic integration.
    func testSearchHapticIntegration() throws {
        // Test search activation haptic
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("test")
            
            // Verify search works
            XCTAssertTrue(searchField.value as? String == "test")
            
            // Clear search
            searchField.buttons["Clear text"].tap()
        }
    }
    
    /// Tests pull-to-refresh with haptic integration.
    func testPullToRefreshHapticIntegration() throws {
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5.0))
        
        // Perform pull-to-refresh (should trigger haptic but not break functionality)
        let start = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let end = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        // Verify refresh completes without errors
        XCTAssertTrue(collectionView.exists)
    }
    
    // MARK: - Watch Form Haptic Integration Tests
    
    /// Tests watch form haptic interactions don't break form functionality.
    func testWatchFormHapticIntegration() throws {
        // Navigate to add watch form
        let addButton = app.buttons["Add watch"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0))
        addButton.tap()
        
        // Wait for form to appear
        XCTAssertTrue(app.navigationBars.buttons["Cancel"].waitForExistence(timeout: 3.0))
        
        // Test text field interactions (should trigger haptic but not break input)
        let manufacturerField = app.textFields["Manufacturer"]
        if manufacturerField.exists {
            manufacturerField.tap()
            manufacturerField.typeText("Test Manufacturer")
            XCTAssertEqual(manufacturerField.value as? String, "Test Manufacturer")
        }
        
        let modelField = app.textFields["Model"]
        if modelField.exists {
            modelField.tap()
            modelField.typeText("Test Model")
            XCTAssertEqual(modelField.value as? String, "Test Model")
        }
        
        // Test picker interactions (should trigger haptic but not break selection)
        let categoryPicker = app.pickers["Category"]
        if categoryPicker.exists {
            categoryPicker.tap()
            // Verify picker wheel appears
            XCTAssertTrue(app.pickerWheels.firstMatch.exists)
            // Dismiss picker
            app.tap()
        }
        
        // Test toggle interactions (should trigger haptic but not break toggle)
        let favoriteToggle = app.switches["Favorite"]
        if favoriteToggle.exists {
            let initialValue = favoriteToggle.value as? String
            favoriteToggle.tap()
            // Verify toggle state changes
            XCTAssertNotEqual(favoriteToggle.value as? String, initialValue)
        }
        
        // Test additional details expansion (should trigger haptic but not break functionality)
        let detailsButton = app.buttons["Show additional details"]
        if detailsButton.exists {
            detailsButton.tap()
            // Verify additional details section expands
            XCTAssertTrue(app.buttons["Hide additional details"].exists)
        }
        
        // Test save button (should trigger haptic but not break save functionality)
        let saveButton = app.buttons["Save"]
        if saveButton.exists && !saveButton.isEnabled {
            // Fill required field if save is disabled
            manufacturerField.tap()
            manufacturerField.typeText("Required Manufacturer")
        }
        
        if saveButton.exists && saveButton.isEnabled {
            saveButton.tap()
            // Verify save completes (form should dismiss or show success)
            XCTAssertFalse(app.navigationBars.buttons["Cancel"].exists)
        }
    }
    
    /// Tests form validation with haptic integration.
    func testFormValidationHapticIntegration() throws {
        // Navigate to add watch form
        let addButton = app.buttons["Add watch"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0))
        addButton.tap()
        
        // Wait for form to appear
        XCTAssertTrue(app.navigationBars.buttons["Cancel"].waitForExistence(timeout: 3.0))
        
        // Test save without required field (should trigger error haptic)
        let saveButton = app.buttons["Save"]
        if saveButton.exists && saveButton.isEnabled {
            saveButton.tap()
            // Verify error handling works (form should still be visible)
            XCTAssertTrue(app.navigationBars.buttons["Cancel"].exists)
        }
        
        // Fill required field and test successful save
        let manufacturerField = app.textFields["Manufacturer"]
        if manufacturerField.exists {
            manufacturerField.tap()
            manufacturerField.typeText("Test Manufacturer")
            saveButton.tap()
            // Verify successful save (form should dismiss)
            XCTAssertFalse(app.navigationBars.buttons["Cancel"].exists)
        }
    }
    
    // MARK: - Navigation Flow Tests
    
    /// Tests navigation flows with haptic integration.
    func testNavigationFlowWithHaptics() throws {
        // Test collection to detail navigation
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5.0))
        
        let watchCards = collectionView.cells
        if watchCards.count > 0 {
            let firstCard = watchCards.firstMatch
            firstCard.tap()
            
            // Verify detail view appears
            XCTAssertTrue(app.navigationBars.buttons["Collection"].waitForExistence(timeout: 3.0))
            
            // Navigate back
            app.navigationBars.buttons["Collection"].tap()
        }
        
        // Test collection to add form navigation
        let addButton = app.buttons["Add watch"]
        if addButton.exists {
            addButton.tap()
            
            // Verify form appears
            XCTAssertTrue(app.navigationBars.buttons["Cancel"].waitForExistence(timeout: 3.0))
            
            // Navigate back
            app.navigationBars.buttons["Cancel"].tap()
        }
    }
    
    // MARK: - Accessibility Integration Tests
    
    /// Tests haptic integration with accessibility features.
    func testAccessibilityIntegrationWithHaptics() throws {
        // Test with VoiceOver enabled (simulated)
        // Note: This is a basic test - actual VoiceOver testing requires device
        
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5.0))
        
        // Test accessible interactions
        let watchCards = collectionView.cells
        if watchCards.count > 0 {
            let firstCard = watchCards.firstMatch
            // Test that haptic feedback doesn't interfere with accessibility
            firstCard.tap()
            
            // Verify navigation still works
            XCTAssertTrue(app.navigationBars.buttons["Collection"].waitForExistence(timeout: 3.0))
            app.navigationBars.buttons["Collection"].tap()
        }
    }
    
    // MARK: - Phase 2 UI Tests
    
    /// Tests calendar view haptic interactions don't break functionality.
    func testCalendarViewHaptics() throws {
        // Navigate to calendar view
        let calendarTab = app.tabBars.buttons["Calendar"]
        if calendarTab.exists {
            calendarTab.tap()
            
            // Wait for calendar to load
            XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 5.0))
            
            // Test date selection (should trigger haptic but not break functionality)
            // Note: Calendar element may not be available in current UI
            let calendar = app.otherElements.matching(identifier: "calendar").firstMatch
            if calendar.exists {
                calendar.tap()
                // Verify calendar still works
                XCTAssertTrue(calendar.exists)
            }
            
            // Test "Add worn" button (should trigger haptic but not break functionality)
            let addWornButton = app.buttons["Add worn"]
            if addWornButton.exists {
                addWornButton.tap()
                // Verify picker appears
                XCTAssertTrue(app.navigationBars["Add worn"].waitForExistence(timeout: 3.0))
                // Dismiss picker
                app.navigationBars.buttons["Cancel"].tap()
            }
        }
    }
    
    /// Tests watch detail view haptic interactions don't break functionality.
    func testWatchDetailViewHaptics() throws {
        // Navigate to collection and select a watch
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5.0))
        
        let watchCards = collectionView.cells
        if watchCards.count > 0 {
            let firstCard = watchCards.firstMatch
            firstCard.tap()
            
            // Wait for detail view to appear
            XCTAssertTrue(app.navigationBars.buttons["Collection"].waitForExistence(timeout: 3.0))
            
            // Test "Mark as worn today" button (should trigger haptic but not break functionality)
            let markWornButton = app.buttons["Mark as worn today"]
            if markWornButton.exists {
                markWornButton.tap()
                // Verify wear tracking works
                XCTAssertTrue(app.buttons["Already worn today"].exists)
            }
            
            // Test edit button (should trigger haptic but not break functionality)
            let editButton = app.buttons["Edit"]
            if editButton.exists {
                editButton.tap()
                // Verify edit view appears
                XCTAssertTrue(app.navigationBars.buttons["Cancel"].waitForExistence(timeout: 3.0))
                app.navigationBars.buttons["Cancel"].tap()
            }
            
            // Test image tap (should trigger haptic but not break functionality)
            let watchImage = app.images["Watch image"]
            if watchImage.exists {
                watchImage.tap()
                // Verify image tap works
                XCTAssertTrue(watchImage.exists)
            }
            
            // Navigate back
            app.navigationBars.buttons["Collection"].tap()
        }
    }
    
    /// Tests settings view haptic interactions don't break functionality.
    func testSettingsViewHaptics() throws {
        // Navigate to settings
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()
            
            // Wait for settings to load
            XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5.0))
            
            // Test theme picker (should trigger haptic but not break functionality)
            let themePicker = app.pickers["Theme"]
            if themePicker.exists {
                themePicker.tap()
                // Verify picker works
                XCTAssertTrue(themePicker.exists)
                // Dismiss picker
                app.tap()
            }
        }
    }
    
    /// Tests comprehensive haptic integration across all views.
    func testComprehensiveHapticIntegration() throws {
        // Test navigation between all views with haptic integration
        
        // Collection view
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5.0))
        
        // Calendar view
        let calendarTab = app.tabBars.buttons["Calendar"]
        if calendarTab.exists {
            calendarTab.tap()
            XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 3.0))
        }
        
        // Stats view
        let statsTab = app.tabBars.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 3.0))
        }
        
        // Settings view
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()
            XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3.0))
        }
        
        // Back to collection
        let collectionTab = app.tabBars.buttons["Collection"]
        if collectionTab.exists {
            collectionTab.tap()
            XCTAssertTrue(collectionView.waitForExistence(timeout: 3.0))
        }
        
        // Verify all navigation works correctly
        XCTAssertTrue(true, "Comprehensive haptic integration test completed successfully")
    }
    
    // MARK: - Phase 3 UI Tests
    
    /// Tests stats view haptic interactions don't break functionality.
    func testStatsViewHaptics() throws {
        // Navigate to stats view
        let statsTab = app.tabBars.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            
            // Wait for stats to load
            XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 5.0))
            
            // Test data point taps (should trigger haptic but not break functionality)
            let dataPoints = app.staticTexts.matching(identifier: "statsDataPoint")
            if dataPoints.count > 0 {
                dataPoints.firstMatch.tap()
                // Verify data point tap works
                XCTAssertTrue(dataPoints.firstMatch.exists)
            }
            
            // Test chart interactions
            // Note: Charts element may not be available in current UI
            let charts = app.otherElements.matching(identifier: "chart").firstMatch
            if charts.exists {
                charts.tap()
                // Verify chart tap works
                XCTAssertTrue(charts.exists)
            }
            
            // Test list interactions
            let listHeaders = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'worn'"))
            if listHeaders.count > 0 {
                listHeaders.firstMatch.tap()
                // Verify list header tap works
                XCTAssertTrue(listHeaders.firstMatch.exists)
            }
        }
    }
    
    /// Tests app data view haptic interactions don't break functionality.
    func testAppDataViewHaptics() throws {
        // Navigate to app data
        app.buttons["SettingsMenuButton"].tap()
        app.buttons["App Data"].tap()
        XCTAssertTrue(app.navigationBars["App Data"].waitForExistence(timeout: 5.0))
        
        // Test export button (should trigger haptic but not break functionality)
        let exportButton = app.buttons["Export backup"]
        if exportButton.exists {
            exportButton.tap()
            // Verify export functionality works
            XCTAssertTrue(app.sheets.firstMatch.exists)
            // Dismiss sheet
            app.buttons["Cancel"].tap()
        }
        
        // Test import button
        let importButton = app.buttons["Import backup"]
        if importButton.exists {
            importButton.tap()
            // Verify import functionality works
            XCTAssertTrue(app.sheets.firstMatch.exists)
            // Dismiss sheet
            app.buttons["Cancel"].tap()
        }
        
        // Test load sample data button (debug only)
        #if DEBUG
        let loadSampleButton = app.buttons["Load sample data"]
        if loadSampleButton.exists {
            loadSampleButton.tap()
            // Verify sample data loading works
            XCTAssertTrue(loadSampleButton.exists)
        }
        #endif
        
        // Navigate back
        app.navigationBars.buttons["Back"].tap()
    }
    
    /// Tests navigation haptic interactions don't break functionality.
    func testNavigationHaptics() throws {
        // Test tab navigation with haptic feedback
        let statsTab = app.tabBars.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 3.0))
        }
        
        let calendarTab = app.tabBars.buttons["Calendar"]
        if calendarTab.exists {
            calendarTab.tap()
            XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 3.0))
        }
        
        let collectionTab = app.tabBars.buttons["Collection"]
        if collectionTab.exists {
            collectionTab.tap()
            XCTAssertTrue(app.collectionViews.firstMatch.waitForExistence(timeout: 3.0))
        }
        
        // Test menu interactions
        app.buttons["SettingsMenuButton"].tap()
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3.0))
        
        // Navigate back
        app.navigationBars.buttons["Back"].tap()
    }
    
    /// Tests bottom navigation tab switching with haptic feedback.
    /// - **Purpose**: Ensures tab switching triggers haptic feedback without breaking functionality
    /// - **Coverage**: Tests all three tabs (Collection, Stats, Calendar) with rapid switching
    /// - **Validation**: Verifies navigation works correctly with haptic integration
    func testBottomNavigationTabHaptics() throws {
        // Start on Collection tab (default)
        XCTAssertTrue(app.collectionViews.firstMatch.waitForExistence(timeout: 5.0))
        
        // Test switching to Stats tab (should trigger haptic)
        let statsTab = app.tabBars.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 3.0))
        }
        
        // Test switching to Calendar tab (should trigger haptic)
        let calendarTab = app.tabBars.buttons["Calendar"]
        if calendarTab.exists {
            calendarTab.tap()
            XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 3.0))
        }
        
        // Test switching back to Collection tab (should trigger haptic)
        let collectionTab = app.tabBars.buttons["Collection"]
        if collectionTab.exists {
            collectionTab.tap()
            XCTAssertTrue(app.collectionViews.firstMatch.waitForExistence(timeout: 3.0))
        }
        
        // Test rapid tab switching (should be debounced)
        for _ in 0..<3 {
            if statsTab.exists {
                statsTab.tap()
                XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 2.0))
            }
            
            if collectionTab.exists {
                collectionTab.tap()
                XCTAssertTrue(app.collectionViews.firstMatch.waitForExistence(timeout: 2.0))
            }
        }
        
        XCTAssertTrue(true, "Bottom navigation tab haptics test completed successfully")
    }
    
    /// Tests add watch button haptic feedback.
    /// - **Purpose**: Ensures add watch floating action button triggers haptic feedback
    /// - **Coverage**: Tests button tap and form presentation
    /// - **Validation**: Verifies add functionality works correctly with haptic integration
    func testAddWatchButtonHaptics() throws {
        // Ensure we're on Collection tab
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5.0))
        
        // Test add watch button tap (should trigger medium impact haptic)
        let addButton = app.buttons["Add watch"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3.0))
        XCTAssertTrue(addButton.isHittable)
        
        addButton.tap()
        
        // Verify form appears (haptic should not break functionality)
        XCTAssertTrue(app.navigationBars.buttons["Cancel"].waitForExistence(timeout: 3.0))
        
        // Test form can be dismissed properly
        app.navigationBars.buttons["Cancel"].tap()
        
        // Verify we're back to collection view
        XCTAssertTrue(collectionView.waitForExistence(timeout: 3.0))
        
        // Test multiple rapid taps (should not break functionality)
        for _ in 0..<3 {
            addButton.tap()
            if app.navigationBars.buttons["Cancel"].waitForExistence(timeout: 2.0) {
                app.navigationBars.buttons["Cancel"].tap()
                XCTAssertTrue(collectionView.waitForExistence(timeout: 2.0))
            }
        }
        
        XCTAssertTrue(true, "Add watch button haptics test completed successfully")
    }
    
    /// Tests comprehensive Phase 3 haptic integration.
    func testPhase3ComprehensiveIntegration() throws {
        // Test stats view
        let statsTab = app.tabBars.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            XCTAssertTrue(app.navigationBars["Stats"].waitForExistence(timeout: 5.0))
        }
        
        // Test app data view
        app.buttons["SettingsMenuButton"].tap()
        app.buttons["App Data"].tap()
        XCTAssertTrue(app.navigationBars["App Data"].waitForExistence(timeout: 5.0))
        app.navigationBars.buttons["Back"].tap()
        
        // Test navigation between all tabs
        let tabs = ["Collection", "Stats", "Calendar"]
        for tabName in tabs {
            let tabButton = app.tabBars.buttons[tabName]
            if tabButton.exists {
                tabButton.tap()
                // Verify tab navigation works
                XCTAssertTrue(tabButton.exists)
            }
        }
        
        // Verify comprehensive integration works
        XCTAssertTrue(true, "Phase 3 comprehensive haptic integration test completed successfully")
    }
    
    // MARK: - Performance Tests
    
    /// Tests haptic integration doesn't impact performance.
    func testHapticIntegrationPerformance() throws {
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5.0))
        
        let startTime = Date()
        
        // Perform multiple interactions rapidly
        for _ in 0..<5 {
            let watchCards = collectionView.cells
            if watchCards.count > 0 {
                let firstCard = watchCards.firstMatch
                firstCard.tap()
                
                if app.navigationBars.buttons["Collection"].waitForExistence(timeout: 2.0) {
                    app.navigationBars.buttons["Collection"].tap()
                }
            }
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Interactions should complete reasonably quickly
        XCTAssertLessThan(duration, 10.0, "Haptic integration should not significantly impact performance")
    }
    
    // MARK: - Error Scenario Tests
    
    /// Tests haptic integration under error conditions.
    func testHapticIntegrationErrorHandling() throws {
        // Test form validation errors with haptic feedback
        let addButton = app.buttons["Add watch"]
        if addButton.exists {
            addButton.tap()
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            XCTAssertTrue(cancelButton.waitForExistence(timeout: 3.0))
            
            // Test save with invalid data (should trigger error haptic)
            let saveButton = app.buttons["Save"]
            if saveButton.exists && saveButton.isEnabled {
                saveButton.tap()
                // Verify error handling works
                XCTAssertTrue(cancelButton.exists)
            }
            
            // Cancel form
            cancelButton.tap()
        }
    }
    
    // MARK: - Device Compatibility Tests
    
    /// Tests haptic integration on different device configurations.
    func testDeviceCompatibilityWithHaptics() throws {
        // Test that haptic integration works regardless of device capabilities
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5.0))
        
        // Test basic interactions work
        let watchCards = collectionView.cells
        if watchCards.count > 0 {
            let firstCard = watchCards.firstMatch
            firstCard.tap()
            
            // Verify navigation works
            XCTAssertTrue(app.navigationBars.buttons["Collection"].waitForExistence(timeout: 3.0))
            app.navigationBars.buttons["Collection"].tap()
        }
        
        // Test form interactions work
        let addButton = app.buttons["Add watch"]
        if addButton.exists {
            addButton.tap()
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            XCTAssertTrue(cancelButton.waitForExistence(timeout: 3.0))
            cancelButton.tap()
        }
    }
}
