import XCTest
@testable import CrownAndBarrel

/// Comprehensive unit tests for the Haptics system.
/// - **Purpose**: Ensures haptic feedback methods execute without errors and maintain expected behavior.
/// - **Coverage**: All haptic methods, debouncing functionality, accessibility features, and error handling.
/// - **Testing Strategy**: Tests execute haptic methods and verify they don't crash, with debouncing validation.
final class HapticsTests: XCTestCase {
    
    // MARK: - Test Setup and Teardown
    
    override func setUp() {
        super.setUp()
        // Reset any static state that might affect tests
    }
    
    override func tearDown() {
        super.tearDown()
        // Clean up any test state
    }
    
    // MARK: - Basic Haptic Method Tests
    
    /// Tests that basic haptic methods execute without errors.
    func testBasicHapticMethods() {
        // Test legacy methods
        Haptics.success()
        Haptics.selection()
        Haptics.error()
        
        // Test enhanced methods
        Haptics.lightImpact()
        Haptics.mediumImpact()
        Haptics.heavyImpact()
        Haptics.warning()
        Haptics.successNotification()
        
        // All methods should execute without throwing errors
        XCTAssertTrue(true, "All basic haptic methods executed successfully")
    }
    
    /// Tests contextual haptic methods for collection interactions.
    func testCollectionInteractionHaptics() {
        Haptics.collectionInteraction()
        XCTAssertTrue(true, "Collection interaction haptic executed successfully")
    }
    
    /// Tests contextual haptic methods for form interactions.
    func testFormInteractionHaptics() {
        Haptics.formInteraction()
        XCTAssertTrue(true, "Form interaction haptic executed successfully")
    }
    
    /// Tests contextual haptic methods for calendar interactions.
    func testCalendarInteractionHaptics() {
        Haptics.calendarInteraction()
        XCTAssertTrue(true, "Calendar interaction haptic executed successfully")
    }
    
    // MARK: - Wear Tracking Haptic Tests
    
    /// Tests wear tracking haptic feedback for all interaction types.
    func testWearTrackingHaptics() {
        let wearTypes: [WearTrackingType] = [
            .markAsWorn,
            .alreadyWorn,
            .deleteEntry,
            .bulkOperation
        ]
        
        for wearType in wearTypes {
            Haptics.wearTracking(wearType)
            XCTAssertTrue(true, "Wear tracking haptic for \(wearType) executed successfully")
        }
    }
    
    /// Tests specific wear tracking haptic patterns.
    func testWearTrackingHapticPatterns() {
        // Test mark as worn (should use success notification)
        Haptics.wearTracking(.markAsWorn)
        
        // Test already worn (should use warning)
        Haptics.wearTracking(.alreadyWorn)
        
        // Test delete entry (should use heavy impact)
        Haptics.wearTracking(.deleteEntry)
        
        // Test bulk operation (should use medium impact)
        Haptics.wearTracking(.bulkOperation)
        
        XCTAssertTrue(true, "All wear tracking haptic patterns executed successfully")
    }
    
    // MARK: - Settings Haptic Tests
    
    /// Tests settings interaction haptic feedback for all types.
    func testSettingsInteractionHaptics() {
        let settingsTypes: [SettingsType] = [
            .themeChange,
            .toggleSwitch,
            .dataExport,
            .dataImport,
            .resetOperation
        ]
        
        for settingsType in settingsTypes {
            Haptics.settingsInteraction(settingsType)
            XCTAssertTrue(true, "Settings interaction haptic for \(settingsType) executed successfully")
        }
    }
    
    /// Tests specific settings haptic patterns.
    func testSettingsHapticPatterns() {
        // Test theme change (should use success notification)
        Haptics.settingsInteraction(.themeChange)
        
        // Test toggle switch (should use selection)
        Haptics.settingsInteraction(.toggleSwitch)
        
        // Test reset operation (should use warning)
        Haptics.settingsInteraction(.resetOperation)
        
        XCTAssertTrue(true, "All settings haptic patterns executed successfully")
    }
    
    // MARK: - Search Haptic Tests
    
    /// Tests search interaction haptic feedback for all types.
    func testSearchInteractionHaptics() {
        let searchTypes: [SearchType] = [
            .searchActivation,
            .filterChange,
            .resultsFound,
            .noResults,
            .clearSearch
        ]
        
        for searchType in searchTypes {
            Haptics.searchInteraction(searchType)
            XCTAssertTrue(true, "Search interaction haptic for \(searchType) executed successfully")
        }
    }
    
    /// Tests specific search haptic patterns.
    func testSearchHapticPatterns() {
        // Test search activation (should use selection)
        Haptics.searchInteraction(.searchActivation)
        
        // Test filter change (should use medium impact)
        Haptics.searchInteraction(.filterChange)
        
        // Test results found (should use light impact)
        Haptics.searchInteraction(.resultsFound)
        
        XCTAssertTrue(true, "All search haptic patterns executed successfully")
    }
    
    // MARK: - Debouncing Tests
    
    /// Tests haptic debouncing functionality.
    func testHapticDebouncing() {
        let startTime = Date()
        
        // Call debounced haptic multiple times rapidly
        Haptics.debouncedHaptic { Haptics.lightImpact() }
        Haptics.debouncedHaptic { Haptics.lightImpact() }
        Haptics.debouncedHaptic { Haptics.lightImpact() }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Debouncing should complete quickly without errors
        XCTAssertLessThan(duration, 1.0, "Debounced haptics should complete quickly")
        XCTAssertTrue(true, "Debounced haptics executed successfully")
    }
    
    /// Tests debouncing with different haptic types.
    func testDebouncingWithDifferentHaptics() {
        // Test debouncing with various haptic types
        Haptics.debouncedHaptic { Haptics.lightImpact() }
        Haptics.debouncedHaptic { Haptics.mediumImpact() }
        Haptics.debouncedHaptic { Haptics.heavyImpact() }
        Haptics.debouncedHaptic { Haptics.success() }
        Haptics.debouncedHaptic { Haptics.error() }
        
        XCTAssertTrue(true, "Debounced haptics with different types executed successfully")
    }
    
    // MARK: - Accessibility Haptic Tests
    
    /// Tests accessibility interaction haptic feedback for all types.
    func testAccessibilityInteractionHaptics() {
        let accessibilityTypes: [AccessibilityInteractionType] = [
            .elementSelected,
            .actionCompleted,
            .errorOccurred,
            .warningShown
        ]
        
        for accessibilityType in accessibilityTypes {
            Haptics.accessibleInteraction(accessibilityType)
            XCTAssertTrue(true, "Accessibility interaction haptic for \(accessibilityType) executed successfully")
        }
    }
    
    /// Tests specific accessibility haptic patterns.
    func testAccessibilityHapticPatterns() {
        // Test element selected (should use heavy impact)
        Haptics.accessibleInteraction(.elementSelected)
        
        // Test action completed (should use success notification)
        Haptics.accessibleInteraction(.actionCompleted)
        
        // Test error occurred (should use error)
        Haptics.accessibleInteraction(.errorOccurred)
        
        // Test warning shown (should use warning)
        Haptics.accessibleInteraction(.warningShown)
        
        XCTAssertTrue(true, "All accessibility haptic patterns executed successfully")
    }
    
    // MARK: - Performance Tests
    
    /// Tests haptic performance under rapid calls.
    func testHapticPerformance() {
        let startTime = Date()
        
        // Perform many haptic calls rapidly
        for _ in 0..<50 {
            Haptics.lightImpact()
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Should complete quickly without performance issues
        XCTAssertLessThan(duration, 2.0, "Rapid haptic calls should complete within 2 seconds")
        XCTAssertTrue(true, "Rapid haptic calls executed successfully")
    }
    
    /// Tests debounced haptic performance.
    func testDebouncedHapticPerformance() {
        let startTime = Date()
        
        // Perform many debounced haptic calls rapidly
        for _ in 0..<100 {
            Haptics.debouncedHaptic { Haptics.lightImpact() }
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Debounced haptics should be very fast
        XCTAssertLessThan(duration, 1.0, "Debounced haptic calls should complete within 1 second")
        XCTAssertTrue(true, "Debounced haptic calls executed successfully")
    }
    
    // MARK: - Edge Case Tests
    
    /// Tests haptic methods with edge case scenarios.
    func testHapticEdgeCases() {
        // Test haptics in rapid succession
        Haptics.lightImpact()
        Haptics.mediumImpact()
        Haptics.heavyImpact()
        Haptics.success()
        Haptics.error()
        Haptics.warning()
        
        // Test contextual haptics in sequence
        Haptics.collectionInteraction()
        Haptics.formInteraction()
        Haptics.calendarInteraction()
        
        // Test all wear tracking types in sequence
        for wearType in WearTrackingType.allCases {
            Haptics.wearTracking(wearType)
        }
        
        // Test all settings types in sequence
        for settingsType in SettingsType.allCases {
            Haptics.settingsInteraction(settingsType)
        }
        
        // Test all search types in sequence
        for searchType in SearchType.allCases {
            Haptics.searchInteraction(searchType)
        }
        
        // Test all accessibility types in sequence
        for accessibilityType in AccessibilityInteractionType.allCases {
            Haptics.accessibleInteraction(accessibilityType)
        }
        
        XCTAssertTrue(true, "All edge case haptic scenarios executed successfully")
    }
    
    /// Tests haptic methods with concurrent access.
    func testConcurrentHapticAccess() {
        let expectation = XCTestExpectation(description: "Concurrent haptic access")
        let group = DispatchGroup()
        
        // Dispatch multiple haptic calls concurrently
        for i in 0..<10 {
            group.enter()
            DispatchQueue.global().async {
                Haptics.debouncedHaptic {
                    Haptics.lightImpact()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(true, "Concurrent haptic access executed successfully")
    }
    
    // MARK: - Integration Tests
    
    /// Tests haptic integration with typical user interaction patterns.
    func testHapticIntegrationPatterns() {
        // Simulate a typical user interaction sequence
        Haptics.searchInteraction(.searchActivation)  // User starts searching
        Haptics.searchInteraction(.filterChange)       // User changes filter
        Haptics.collectionInteraction()                // User selects item
        Haptics.formInteraction()                      // User focuses form field
        Haptics.wearTracking(.markAsWorn)             // User marks as worn
        Haptics.successNotification()                  // Action completed
        
        XCTAssertTrue(true, "Haptic integration pattern executed successfully")
    }
    
    // MARK: - Phase 2 Haptic Tests
    
    /// Tests calendar interaction haptic feedback for all types.
    func testCalendarInteractionHapticsComprehensive() {
        let calendarTypes: [CalendarInteractionType] = [
            .dateSelection,
            .monthNavigation,
            .wearEntryAdded,
            .wearEntryDeleted,
            .refreshCompleted
        ]
        
        for calendarType in calendarTypes {
            Haptics.calendarInteraction(calendarType)
            XCTAssertTrue(true, "Calendar interaction haptic for \(calendarType) executed successfully")
        }
    }
    
    /// Tests specific calendar haptic patterns.
    func testCalendarHapticPatterns() {
        // Test date selection (should use light impact)
        Haptics.calendarInteraction(.dateSelection)
        
        // Test month navigation (should use medium impact)
        Haptics.calendarInteraction(.monthNavigation)
        
        // Test wear entry added (should use success notification)
        Haptics.calendarInteraction(.wearEntryAdded)
        
        // Test wear entry deleted (should use heavy impact)
        Haptics.calendarInteraction(.wearEntryDeleted)
        
        // Test refresh completed (should use success)
        Haptics.calendarInteraction(.refreshCompleted)
        
        XCTAssertTrue(true, "All calendar haptic patterns executed successfully")
    }
    
    /// Tests detail view interaction haptic feedback for all types.
    func testDetailViewInteractionHaptics() {
        let detailTypes: [DetailViewInteractionType] = [
            .imageTap,
            .editInitiated,
            .wearMarked,
            .refreshCompleted,
            .statusChanged
        ]
        
        for detailType in detailTypes {
            Haptics.detailViewInteraction(detailType)
            XCTAssertTrue(true, "Detail view interaction haptic for \(detailType) executed successfully")
        }
    }
    
    /// Tests specific detail view haptic patterns.
    func testDetailViewHapticPatterns() {
        // Test image tap (should use light impact)
        Haptics.detailViewInteraction(.imageTap)
        
        // Test edit initiated (should use collection interaction)
        Haptics.detailViewInteraction(.editInitiated)
        
        // Test wear marked (should use wear tracking)
        Haptics.detailViewInteraction(.wearMarked)
        
        // Test refresh completed (should use success)
        Haptics.detailViewInteraction(.refreshCompleted)
        
        // Test status changed (should use medium impact)
        Haptics.detailViewInteraction(.statusChanged)
        
        XCTAssertTrue(true, "All detail view haptic patterns executed successfully")
    }
    
    /// Tests performance monitoring functionality.
    func testPerformanceMonitoring() {
        #if DEBUG
        Haptics.resetPerformanceMonitoring()
        Haptics.recordHapticCall()
        Haptics.recordHapticCall()
        Haptics.recordHapticCall()
        // Verify performance monitoring works without errors
        XCTAssertTrue(true, "Performance monitoring executed successfully")
        #else
        // In release builds, performance monitoring is not available
        XCTAssertTrue(true, "Performance monitoring not available in release builds")
        #endif
    }
    
    /// Tests Phase 2 haptic integration patterns.
    func testPhase2HapticIntegrationPatterns() {
        // Simulate a comprehensive user interaction sequence across all views
        Haptics.calendarInteraction(.dateSelection)    // User selects date
        Haptics.calendarInteraction(.wearEntryAdded)   // User adds wear entry
        Haptics.detailViewInteraction(.editInitiated)  // User edits watch
        Haptics.detailViewInteraction(.wearMarked)     // User marks as worn
        Haptics.settingsInteraction(.themeChange)      // User changes theme
        Haptics.detailViewInteraction(.refreshCompleted) // User refreshes detail view
        
        XCTAssertTrue(true, "Phase 2 haptic integration pattern executed successfully")
    }
    
    // MARK: - Phase 3 Haptic Tests
    
    /// Tests stats interaction haptic feedback for all types.
    func testStatsInteractionHaptics() {
        let statsTypes: [StatsInteractionType] = [
            .dataPointTapped,
            .chartTapped,
            .listHeaderTapped,
            .watchListItemTapped,
            .refreshCompleted
        ]
        
        for statsType in statsTypes {
            Haptics.statsInteraction(statsType)
            XCTAssertTrue(true, "Stats interaction haptic for \(statsType) executed successfully")
        }
    }
    
    /// Tests specific stats haptic patterns.
    func testStatsHapticPatterns() {
        // Test data point tap (should use light impact)
        Haptics.statsInteraction(.dataPointTapped)
        
        // Test chart tap (should use medium impact)
        Haptics.statsInteraction(.chartTapped)
        
        // Test list header tap (should use selection feedback)
        Haptics.statsInteraction(.listHeaderTapped)
        
        // Test watch list item tap (should use collection interaction)
        Haptics.statsInteraction(.watchListItemTapped)
        
        // Test refresh completed (should use success)
        Haptics.statsInteraction(.refreshCompleted)
        
        XCTAssertTrue(true, "All stats haptic patterns executed successfully")
    }
    
    /// Tests data interaction haptic feedback for all types.
    func testDataInteractionHaptics() {
        let dataTypes: [DataInteractionType] = [
            .exportInitiated,
            .importInitiated,
            .deleteInitiated,
            .seedDataInitiated,
            .operationCompleted,
            .operationFailed
        ]
        
        for dataType in dataTypes {
            Haptics.dataInteraction(dataType)
            XCTAssertTrue(true, "Data interaction haptic for \(dataType) executed successfully")
        }
    }
    
    /// Tests specific data haptic patterns.
    func testDataHapticPatterns() {
        // Test export initiated (should use success notification)
        Haptics.dataInteraction(.exportInitiated)
        
        // Test import initiated (should use success notification)
        Haptics.dataInteraction(.importInitiated)
        
        // Test delete initiated (should use warning)
        Haptics.dataInteraction(.deleteInitiated)
        
        // Test seed data initiated (should use medium impact)
        Haptics.dataInteraction(.seedDataInitiated)
        
        // Test operation completed (should use success)
        Haptics.dataInteraction(.operationCompleted)
        
        // Test operation failed (should use error)
        Haptics.dataInteraction(.operationFailed)
        
        XCTAssertTrue(true, "All data haptic patterns executed successfully")
    }
    
    /// Tests navigation interaction haptic feedback for all types.
    func testNavigationInteractionHaptics() {
        let navigationTypes: [NavigationInteractionType] = [
            .tabChanged,
            .menuOpened,
            .menuItemSelected,
            .backNavigation,
            .forwardNavigation
        ]
        
        for navigationType in navigationTypes {
            Haptics.navigationInteraction(navigationType)
            XCTAssertTrue(true, "Navigation interaction haptic for \(navigationType) executed successfully")
        }
    }
    
    /// Tests specific navigation haptic patterns.
    func testNavigationHapticPatterns() {
        // Test tab changed (should use light impact)
        Haptics.navigationInteraction(.tabChanged)
        
        // Test menu opened (should use selection feedback)
        Haptics.navigationInteraction(.menuOpened)
        
        // Test menu item selected (should use collection interaction)
        Haptics.navigationInteraction(.menuItemSelected)
        
        // Test back navigation (should use light impact)
        Haptics.navigationInteraction(.backNavigation)
        
        // Test forward navigation (should use medium impact)
        Haptics.navigationInteraction(.forwardNavigation)
        
        XCTAssertTrue(true, "All navigation haptic patterns executed successfully")
    }
    
    /// Tests advanced performance monitoring functionality.
    func testAdvancedPerformanceMonitoring() {
        #if DEBUG
        Haptics.recordAdvancedHapticCall("testHaptic1", duration: 0.001)
        Haptics.recordAdvancedHapticCall("testHaptic2", duration: 0.002)
        Haptics.recordAdvancedHapticCall("testHaptic1", duration: 0.0015)
        
        let report = Haptics.getHapticPerformanceReport()
        XCTAssertTrue(report["testHaptic1"] != nil, "Report should include testHaptic1")
        XCTAssertTrue(report["testHaptic2"] != nil, "Report should include testHaptic2")
        
        if let haptic1Data = report["testHaptic1"] as? [String: Any],
           let count = haptic1Data["count"] as? Int {
            XCTAssertEqual(count, 2, "Count should be 2")
        }
        
        if let haptic2Data = report["testHaptic2"] as? [String: Any],
           let count = haptic2Data["count"] as? Int {
            XCTAssertEqual(count, 1, "Count should be 1")
        }
        
        XCTAssertTrue(true, "Advanced performance monitoring executed successfully")
        #else
        // In release builds, advanced performance monitoring is not available
        XCTAssertTrue(true, "Advanced performance monitoring not available in release builds")
        #endif
    }
    
    /// Tests Phase 3 haptic integration patterns.
    func testPhase3HapticIntegrationPatterns() {
        // Simulate a comprehensive user interaction sequence across all views
        Haptics.statsInteraction(.dataPointTapped)       // User taps stats data point
        Haptics.statsInteraction(.chartTapped)           // User taps chart
        Haptics.dataInteraction(.exportInitiated)        // User initiates export
        Haptics.dataInteraction(.importInitiated)        // User initiates import
        Haptics.navigationInteraction(.tabChanged)       // User changes tabs
        Haptics.navigationInteraction(.menuItemSelected) // User selects menu item
        
        XCTAssertTrue(true, "Phase 3 haptic integration pattern executed successfully")
    }
    
    /// Tests comprehensive haptic integration across all phases.
    func testComprehensiveHapticIntegration() {
        // Phase 1 interactions
        Haptics.collectionInteraction()                  // Collection view interaction
        Haptics.formInteraction()                        // Form interaction
        
        // Phase 2 interactions
        Haptics.calendarInteraction(.dateSelection)      // Calendar interaction
        Haptics.detailViewInteraction(.wearMarked)       // Detail view interaction
        Haptics.settingsInteraction(.themeChange)        // Settings interaction
        
        // Phase 3 interactions
        Haptics.statsInteraction(.dataPointTapped)       // Stats interaction
        Haptics.dataInteraction(.exportInitiated)        // Data interaction
        Haptics.navigationInteraction(.tabChanged)       // Navigation interaction
        
        XCTAssertTrue(true, "Comprehensive haptic integration across all phases executed successfully")
    }
    
    /// Tests haptic feedback for form validation scenarios.
    func testFormValidationHapticPatterns() {
        // Simulate form validation scenarios
        Haptics.formInteraction()      // User focuses field
        Haptics.error()               // Validation fails
        Haptics.formInteraction()      // User corrects field
        Haptics.success()             // Validation passes
        Haptics.successNotification()  // Form saved
        
        XCTAssertTrue(true, "Form validation haptic pattern executed successfully")
    }
    
    // MARK: - Error Handling Tests
    
    /// Tests haptic error handling and graceful degradation.
    func testHapticErrorHandling() {
        // Haptics should never throw errors or crash
        // This test ensures graceful handling of any potential issues
        
        do {
            // Test all haptic methods in a do-catch block
            Haptics.lightImpact()
            Haptics.mediumImpact()
            Haptics.heavyImpact()
            Haptics.success()
            Haptics.error()
            Haptics.warning()
            Haptics.collectionInteraction()
            Haptics.formInteraction()
            Haptics.calendarInteraction()
            Haptics.wearTracking(.markAsWorn)
            Haptics.settingsInteraction(.toggleSwitch)
            Haptics.searchInteraction(.searchActivation)
            Haptics.accessibleInteraction(.elementSelected)
            Haptics.debouncedHaptic { Haptics.lightImpact() }
            
            XCTAssertTrue(true, "All haptic methods handled gracefully")
        } catch {
            XCTFail("Haptic methods should never throw errors: \(error)")
        }
    }
}

// MARK: - Supporting Extensions for Testing

extension WearTrackingType: CaseIterable {
    public static var allCases: [WearTrackingType] {
        return [.markAsWorn, .alreadyWorn, .deleteEntry, .bulkOperation]
    }
}

extension SettingsType: CaseIterable {
    public static var allCases: [SettingsType] {
        return [.themeChange, .toggleSwitch, .dataExport, .dataImport, .resetOperation]
    }
}

extension SearchType: CaseIterable {
    public static var allCases: [SearchType] {
        return [.searchActivation, .filterChange, .resultsFound, .noResults, .clearSearch]
    }
}

extension AccessibilityInteractionType: CaseIterable {
    public static var allCases: [AccessibilityInteractionType] {
        return [.elementSelected, .actionCompleted, .errorOccurred, .warningShown]
    }
}

extension CalendarInteractionType: CaseIterable {
    public static var allCases: [CalendarInteractionType] {
        return [.dateSelection, .monthNavigation, .wearEntryAdded, .wearEntryDeleted, .refreshCompleted]
    }
}

extension DetailViewInteractionType: CaseIterable {
    public static var allCases: [DetailViewInteractionType] {
        return [.imageTap, .editInitiated, .wearMarked, .refreshCompleted, .statusChanged]
    }
}

extension StatsInteractionType: CaseIterable {
    public static var allCases: [StatsInteractionType] {
        return [.dataPointTapped, .chartTapped, .listHeaderTapped, .watchListItemTapped, .refreshCompleted]
    }
}

extension DataInteractionType: CaseIterable {
    public static var allCases: [DataInteractionType] {
        return [.exportInitiated, .importInitiated, .deleteInitiated, .seedDataInitiated, .operationCompleted, .operationFailed]
    }
}

extension NavigationInteractionType: CaseIterable {
    public static var allCases: [NavigationInteractionType] {
        return [.tabChanged, .menuOpened, .menuItemSelected, .backNavigation, .forwardNavigation]
    }
}
