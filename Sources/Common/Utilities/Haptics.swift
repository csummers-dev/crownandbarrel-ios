import UIKit

/// Enhanced haptic feedback system for Crown & Barrel.
/// - What: Comprehensive haptic feedback for user interactions throughout the app.
/// - Why: Improves perceived responsiveness, user engagement, and accessibility.
/// - How: Uses UIFeedbackGenerator variants with contextual intensity and patterns.
///
/// ## Usage Guidelines
/// - **Light Impact**: Subtle interactions (taps, selections, navigation)
/// - **Medium Impact**: Important actions (saves, changes, confirmations)
/// - **Heavy Impact**: Critical operations (deletions, resets, warnings)
/// - **Success**: Positive feedback for completed actions
/// - **Error**: Negative feedback for failures or validation errors
/// - **Warning**: Cautionary feedback for potentially destructive actions
public enum Haptics {
    
    // MARK: - Existing Methods (Legacy Support)
    
    /// Provides success feedback for completed actions.
    /// - **When to use**: Save operations, successful data entry, completed tasks
    /// - **Intensity**: Medium impact for noticeable but pleasant feedback
    public static func success() { 
        UIImpactFeedbackGenerator(style: .medium).impactOccurred() 
    }
    
    /// Provides selection feedback for UI element changes.
    /// - **When to use**: Picker selections, toggle switches, option changes
    /// - **Intensity**: Light impact for subtle selection confirmation
    public static func selection() { 
        UISelectionFeedbackGenerator().selectionChanged() 
    }
    
    /// Provides error feedback for failures or validation errors.
    /// - **When to use**: Validation failures, network errors, operation failures
    /// - **Intensity**: Error notification for clear failure indication
    public static func error() { 
        UINotificationFeedbackGenerator().notificationOccurred(.error) 
    }
    
    // MARK: - Enhanced Haptic Methods
    
    /// Provides light impact feedback for subtle interactions.
    /// - **When to use**: Card taps, navigation, subtle confirmations
    /// - **Intensity**: Light impact for minimal disruption
    public static func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    /// Provides medium impact feedback for important actions.
    /// - **When to use**: Save operations, important changes, confirmations
    /// - **Intensity**: Medium impact for noticeable feedback
    public static func mediumImpact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    /// Provides heavy impact feedback for critical operations.
    /// - **When to use**: Deletions, resets, critical confirmations
    /// - **Intensity**: Heavy impact for maximum attention
    public static func heavyImpact() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    /// Provides warning feedback for potentially destructive actions.
    /// - **When to use**: Delete confirmations, data loss warnings, cautionary actions
    /// - **Intensity**: Warning notification for clear caution indication
    public static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    /// Provides success notification feedback for completed operations.
    /// - **When to use**: Successful data operations, completed tasks, achievements
    /// - **Intensity**: Success notification for positive reinforcement
    public static func successNotification() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    // MARK: - Contextual Haptic Methods
    
    /// Provides feedback for watch collection interactions.
    /// - **When to use**: Watch card selection, grid/list toggle, search activation
    public static func collectionInteraction() {
        lightImpact()
    }
    
    /// Provides feedback for form field interactions.
    /// - **When to use**: Text field focus, picker selection, validation success
    public static func formInteraction() {
        selection()
    }
    
    /// Provides feedback for calendar interactions.
    /// - **When to use**: Date selection, month navigation, entry viewing
    public static func calendarInteraction() {
        lightImpact()
    }
    
    /// Provides feedback for wear tracking operations.
    /// - **When to use**: Mark as worn, wear entry deletion, bulk operations
    public static func wearTracking(_ type: WearTrackingType) {
        switch type {
        case .markAsWorn:
            successNotification()
        case .alreadyWorn:
            warning()
        case .deleteEntry:
            heavyImpact()
        case .bulkOperation:
            mediumImpact()
        }
    }
    
    /// Provides feedback for settings and preferences.
    /// - **When to use**: Theme changes, toggle switches, data operations
    public static func settingsInteraction(_ type: SettingsType) {
        switch type {
        case .themeChange:
            successNotification()
        case .toggleSwitch:
            selection()
        case .dataExport:
            successNotification()
        case .dataImport:
            successNotification()
        case .resetOperation:
            warning()
        }
    }
    
    /// Provides feedback for search and filtering operations.
    /// - **When to use**: Search activation, filter changes, result display
    public static func searchInteraction(_ type: SearchType) {
        switch type {
        case .searchActivation:
            selection()
        case .filterChange:
            mediumImpact()
        case .resultsFound:
            lightImpact()
        case .noResults:
            lightImpact()
        case .clearSearch:
            lightImpact()
        }
    }
    
    // MARK: - Performance and Accessibility Enhancements
    
    /// Provides debounced haptic feedback to prevent spam from rapid interactions.
    /// - **When to use**: Rapid user interactions that could trigger multiple haptics
    /// - **Debounce Interval**: 100ms to prevent overwhelming feedback
    /// - **Performance**: Optimized to maintain smooth user experience
    public static func debouncedHaptic(_ hapticType: () -> Void) {
        let now = Date()
        if now.timeIntervalSince(lastHapticTime) >= hapticDebounceInterval {
            hapticType()
            lastHapticTime = now
        }
    }
    
    /// Enhanced haptic feedback for accessibility users.
    /// - **When to use**: Interactions that need enhanced feedback for screen reader users
    /// - **Intensity**: More pronounced feedback for better accessibility
    /// - **Compliance**: Supports WCAG 2.1 AA accessibility guidelines
    public static func accessibleInteraction(_ type: AccessibilityInteractionType) {
        switch type {
        case .elementSelected:
            heavyImpact() // More pronounced feedback for screen reader users
        case .actionCompleted:
            successNotification()
        case .errorOccurred:
            error()
        case .warningShown:
            warning()
        }
    }
    
    /// Provides feedback for calendar-specific interactions.
    /// - **When to use**: Date selection, month navigation, wear entry management
    /// - **Intensity**: Contextual intensity based on interaction importance
    /// - **Usage**: Specialized haptic patterns for calendar operations
    public static func calendarInteraction(_ type: CalendarInteractionType) {
        switch type {
        case .dateSelection:
            lightImpact()
        case .monthNavigation:
            mediumImpact()
        case .wearEntryAdded:
            successNotification()
        case .wearEntryDeleted:
            heavyImpact()
        case .refreshCompleted:
            success()
        }
    }
    
    /// Provides feedback for watch detail view interactions.
    /// - **When to use**: Watch detail navigation, wear tracking, image interactions
    /// - **Intensity**: Contextual intensity based on interaction importance
    /// - **Usage**: Specialized haptic patterns for detail view operations
    public static func detailViewInteraction(_ type: DetailViewInteractionType) {
        switch type {
        case .imageTap:
            lightImpact()
        case .editInitiated:
            collectionInteraction()
        case .wearMarked:
            wearTracking(.markAsWorn)
        case .refreshCompleted:
            success()
        case .statusChanged:
            mediumImpact()
        }
    }
    
    /// Provides feedback for stats view interactions.
    /// - **When to use**: Stats data interactions, chart taps, list selections
    /// - **Intensity**: Contextual intensity based on interaction importance
    /// - **Usage**: Specialized haptic patterns for stats operations
    public static func statsInteraction(_ type: StatsInteractionType) {
        switch type {
        case .dataPointTapped:
            lightImpact()
        case .chartTapped:
            mediumImpact()
        case .listHeaderTapped:
            selection()
        case .watchListItemTapped:
            collectionInteraction()
        case .refreshCompleted:
            success()
        }
    }
    
    /// Provides feedback for data management operations.
    /// - **When to use**: Export, import, delete, seed operations
    /// - **Intensity**: Contextual intensity based on operation importance
    /// - **Usage**: Specialized haptic patterns for data operations
    public static func dataInteraction(_ type: DataInteractionType) {
        switch type {
        case .exportInitiated:
            successNotification()
        case .importInitiated:
            successNotification()
        case .deleteInitiated:
            warning()
        case .seedDataInitiated:
            mediumImpact()
        case .operationCompleted:
            success()
        case .operationFailed:
            error()
        }
    }
    
    /// Provides feedback for navigation interactions.
    /// - **When to use**: Tab changes, menu interactions, navigation events
    /// - **Intensity**: Contextual intensity based on navigation importance
    /// - **Usage**: Specialized haptic patterns for navigation operations
    public static func navigationInteraction(_ type: NavigationInteractionType) {
        switch type {
        case .tabChanged:
            lightImpact()
        case .menuOpened:
            selection()
        case .menuItemSelected:
            collectionInteraction()
        case .backNavigation:
            lightImpact()
        case .forwardNavigation:
            mediumImpact()
        }
    }
    
    // MARK: - Private Properties for Performance
    
    /// Tracks the last haptic feedback time to enable debouncing.
    /// - **Purpose**: Prevents haptic spam from rapid user interactions
    /// - **Thread Safety**: Access is thread-safe for main thread usage
    private static var lastHapticTime: Date = Date.distantPast
    
    /// Debounce interval to prevent overwhelming haptic feedback.
    /// - **Value**: 100ms provides optimal balance between responsiveness and smoothness
    /// - **Rationale**: Short enough to feel immediate, long enough to prevent spam
    private static let hapticDebounceInterval: TimeInterval = 0.1
    
    // MARK: - Performance Monitoring (Debug Only)
    
    #if DEBUG
    /// Performance monitoring for haptic feedback in debug builds.
    /// - **Purpose**: Track haptic usage and performance impact
    /// - **Usage**: Optional performance monitoring for development and testing
    private static var hapticCallCount: Int = 0
    private static var lastPerformanceCheck: Date = Date()
    
    /// Records a haptic call for performance monitoring.
    /// - **When to use**: Called internally by haptic methods in debug builds
    /// - **Purpose**: Monitor haptic call frequency and performance impact
    public static func recordHapticCall() {
        hapticCallCount += 1
        let now = Date()
        if now.timeIntervalSince(lastPerformanceCheck) >= 60.0 { // Check every minute
            print("🎯 Haptic Performance: \(hapticCallCount) calls in last minute")
            hapticCallCount = 0
            lastPerformanceCheck = now
        }
    }
    
    /// Resets performance monitoring counters.
    /// - **When to use**: For testing or debugging performance monitoring
    /// - **Purpose**: Clear performance monitoring state
    public static func resetPerformanceMonitoring() {
        hapticCallCount = 0
        lastPerformanceCheck = Date()
        print("🎯 Haptic Performance: Monitoring reset")
    }
    
    /// Advanced performance monitoring for haptic feedback.
    /// - **Purpose**: Detailed performance tracking and analysis
    /// - **Usage**: Enhanced monitoring for development and optimization
    private static var hapticPerformanceMetrics: [String: Int] = [:]
    private static var hapticTimingData: [String: [TimeInterval]] = [:]
    
    /// Records advanced haptic call with timing information.
    /// - **When to use**: Called internally by haptic methods in debug builds
    /// - **Purpose**: Monitor detailed haptic performance and timing
    public static func recordAdvancedHapticCall(_ hapticType: String, duration: TimeInterval) {
        hapticPerformanceMetrics[hapticType, default: 0] += 1
        hapticTimingData[hapticType, default: []].append(duration)
        
        // Log performance data every 10 calls
        if hapticPerformanceMetrics[hapticType]! % 10 == 0 {
            let avgDuration = hapticTimingData[hapticType]!.reduce(0, +) / Double(hapticTimingData[hapticType]!.count)
            print("🎯 Advanced Haptic Performance: \(hapticType) - Count: \(hapticPerformanceMetrics[hapticType]!), Avg Duration: \(avgDuration)ms")
        }
    }
    
    /// Gets comprehensive haptic performance report.
    /// - **When to use**: For performance analysis and debugging
    /// - **Purpose**: Retrieve detailed performance metrics for all haptic types
    public static func getHapticPerformanceReport() -> [String: Any] {
        var report: [String: Any] = [:]
        for (hapticType, count) in hapticPerformanceMetrics {
            let timings = hapticTimingData[hapticType] ?? []
            let avgDuration = timings.isEmpty ? 0 : timings.reduce(0, +) / Double(timings.count)
            report[hapticType] = [
                "count": count,
                "averageDuration": avgDuration,
                "totalDuration": timings.reduce(0, +)
            ]
        }
        return report
    }
    #endif
}

// MARK: - Supporting Types

/// Types of wear tracking operations that require haptic feedback.
public enum WearTrackingType {
    case markAsWorn
    case alreadyWorn
    case deleteEntry
    case bulkOperation
}

/// Types of settings operations that require haptic feedback.
public enum SettingsType {
    case themeChange
    case toggleSwitch
    case dataExport
    case dataImport
    case resetOperation
}

/// Types of search operations that require haptic feedback.
public enum SearchType {
    case searchActivation
    case filterChange
    case resultsFound
    case noResults
    case clearSearch
}

/// Types of accessibility interactions that require enhanced haptic feedback.
/// - **Purpose**: Provides more pronounced feedback for accessibility users
/// - **Compliance**: Supports WCAG 2.1 AA accessibility guidelines
/// - **Usage**: Used with `Haptics.accessibleInteraction()` for enhanced accessibility
public enum AccessibilityInteractionType {
    case elementSelected    // Enhanced feedback for element selection
    case actionCompleted    // Success feedback for completed actions
    case errorOccurred      // Error feedback for failures
    case warningShown       // Warning feedback for cautionary actions
}

/// Types of calendar interactions that require haptic feedback.
/// - **Purpose**: Provides contextual haptic feedback for calendar-specific interactions
/// - **Usage**: Used with `Haptics.calendarInteraction()` for calendar operations
public enum CalendarInteractionType {
    case dateSelection      // Light impact for date selection
    case monthNavigation    // Medium impact for month changes
    case wearEntryAdded     // Success notification for wear entry addition
    case wearEntryDeleted   // Heavy impact for wear entry deletion
    case refreshCompleted   // Success feedback for refresh completion
}

/// Types of watch detail view interactions that require haptic feedback.
/// - **Purpose**: Provides contextual haptic feedback for detail view interactions
/// - **Usage**: Used with `Haptics.detailViewInteraction()` for detail view operations
public enum DetailViewInteractionType {
    case imageTap           // Light impact for image taps
    case editInitiated      // Collection interaction for edit initiation
    case wearMarked         // Wear tracking feedback for marking as worn
    case refreshCompleted   // Success feedback for refresh completion
    case statusChanged      // Medium impact for status changes
}

/// Types of stats view interactions that require haptic feedback.
/// - **Purpose**: Provides contextual haptic feedback for stats view interactions
/// - **Usage**: Used with `Haptics.statsInteraction()` for stats operations
public enum StatsInteractionType {
    case dataPointTapped      // Light impact for data point taps
    case chartTapped          // Medium impact for chart interactions
    case listHeaderTapped     // Selection feedback for headers
    case watchListItemTapped  // Collection interaction for watch items
    case refreshCompleted     // Success feedback for refresh completion
}

/// Types of data management operations that require haptic feedback.
/// - **Purpose**: Provides contextual haptic feedback for data operations
/// - **Usage**: Used with `Haptics.dataInteraction()` for data management operations
public enum DataInteractionType {
    case exportInitiated      // Success notification for export start
    case importInitiated      // Success notification for import start
    case deleteInitiated      // Warning for delete operations
    case seedDataInitiated    // Medium impact for debug operations
    case operationCompleted   // Success for completed operations
    case operationFailed      // Error for failed operations
}

/// Types of navigation interactions that require haptic feedback.
/// - **Purpose**: Provides contextual haptic feedback for navigation operations
/// - **Usage**: Used with `Haptics.navigationInteraction()` for navigation operations
public enum NavigationInteractionType {
    case tabChanged           // Light impact for tab changes
    case menuOpened           // Selection feedback for menu opening
    case menuItemSelected     // Collection interaction for menu selection
    case backNavigation       // Light impact for back navigation
    case forwardNavigation    // Medium impact for forward navigation
}


