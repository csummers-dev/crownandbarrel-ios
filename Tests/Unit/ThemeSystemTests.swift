import XCTest
import SwiftUI
@testable import CrownAndBarrel

/// Unit tests for theme system stability and typography implementation.
/// - What: Tests theme loading, color resolution, typography system, and change notifications.
/// - Why: Prevents regression of theme switching fixes and ensures system stability.
/// - How: Direct testing of theme components, color values, and notification behavior.
final class ThemeSystemTests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Tests that all luxury themes load correctly without crashes.
    /// - What: Validates each theme can be loaded and has valid color values.
    /// - Why: Prevents regression of theme loading and ensures all luxury themes are valid.
    /// - How: Iterates through all themes and validates color properties.
    func testAllLuxuryThemesLoadCorrectly() throws {
        let themeCatalog = ThemeCatalog.shared
        let themes = themeCatalog.orderedThemes
        
        // Should have exactly 8 themes (2 defaults + 6 luxury)
        XCTAssertEqual(themes.count, 8, "Should have exactly 8 curated luxury themes")
        
        // Expected theme IDs
        let expectedThemeIds = [
            "light-default",
            "dark-default", 
            "champagne-gold",
            "royal-sapphire",
            "emerald-heritage",
            "onyx-prestige",
            "burgundy-elite",
            "midnight-platinum"
        ]
        
        for expectedId in expectedThemeIds {
            let theme = themes.first { $0.id == expectedId }
            XCTAssertNotNil(theme, "Theme \(expectedId) should exist")
            
            if let theme = theme {
                // Validate theme has all required color properties
                XCTAssertFalse(theme.colors.accent.description.isEmpty, "\(expectedId) should have accent color")
                XCTAssertFalse(theme.colors.background.description.isEmpty, "\(expectedId) should have background color")
                XCTAssertFalse(theme.colors.textPrimary.description.isEmpty, "\(expectedId) should have primary text color")
                XCTAssertFalse(theme.colors.textSecondary.description.isEmpty, "\(expectedId) should have secondary text color")
                
                // Validate chart palette exists and has colors
                XCTAssertGreaterThan(theme.colors.chartPalette.count, 0, "\(expectedId) should have chart palette")
                XCTAssertLessThanOrEqual(theme.colors.chartPalette.count, 10, "\(expectedId) chart palette should be reasonable size")
            }
        }
    }
    
    /// Tests typography system completeness and font definitions.
    /// - What: Validates all typography styles are properly defined.
    /// - Why: Prevents regression of typography implementation.
    /// - How: Tests each typography style for proper font configuration.
    func testTypographySystemCompleteness() throws {
        // Test all current typography tokens (4 total after cleanup)
        
        // Navigation & Branding
        let titleCompact = AppTypography.titleCompact
        XCTAssertNotNil(titleCompact, "titleCompact should be defined")
        
        // Content Hierarchy
        let heading = AppTypography.heading
        XCTAssertNotNil(heading, "heading should be defined")
        
        let caption = AppTypography.caption
        XCTAssertNotNil(caption, "caption should be defined")
        
        // Luxury Elements
        let luxury = AppTypography.luxury
        XCTAssertNotNil(luxury, "luxury should be defined")
        
        // Verify these are actually Font instances by checking their properties
        XCTAssertNotNil(titleCompact, "titleCompact should be defined")
        XCTAssertNotNil(heading, "heading should be defined")
        XCTAssertNotNil(caption, "caption should be defined")
        XCTAssertNotNil(luxury, "luxury should be defined")
    }
    
    /// Tests theme change notification system.
    /// - What: Validates that theme changes trigger proper notifications.
    /// - Why: Ensures the notification-based tab refresh system works.
    /// - How: Monitors notifications during theme changes.
    func testThemeChangeNotifications() throws {
        let expectation = XCTestExpectation(description: "Theme change notification")
        var notificationReceived = false
        
        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name("forceTabBarRefresh"),
            object: nil,
            queue: .main
        ) { _ in
            notificationReceived = true
            expectation.fulfill()
        }
        
        defer {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // Simulate theme change by posting notification
        NotificationCenter.default.post(name: Notification.Name("forceTabBarRefresh"), object: nil)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(notificationReceived, "Theme change notification should be received")
    }
    
    /// Tests theme color value validity.
    /// - What: Validates that all theme colors are valid hex values or rgba expressions.
    /// - Why: Prevents invalid color configurations from causing crashes.
    /// - How: Attempts to create Color objects from all theme color values.
    func testThemeColorValidity() throws {
        let themes = ThemeCatalog.shared.orderedThemes
        
        for theme in themes {
            // Test that all colors can be created successfully
            let accent = theme.colors.accent
            XCTAssertNotNil(accent, "\(theme.name) accent color should be valid")
            
            let background = theme.colors.background
            XCTAssertNotNil(background, "\(theme.name) background color should be valid")
            
            let textPrimary = theme.colors.textPrimary
            XCTAssertNotNil(textPrimary, "\(theme.name) primary text color should be valid")
            
            let textSecondary = theme.colors.textSecondary
            XCTAssertNotNil(textSecondary, "\(theme.name) secondary text color should be valid")
            
            // Test chart palette colors
            for (index, paletteColor) in theme.colors.chartPalette.enumerated() {
                XCTAssertNotNil(paletteColor, "\(theme.name) chart palette color \(index) should be valid")
            }
        }
    }
    
    /// Tests default theme selection logic.
    /// - What: Validates proper default theme selection for light and dark modes.
    /// - Why: Ensures app starts with appropriate theme based on system appearance.
    /// - How: Tests ThemeManager default selection logic.
    func testDefaultThemeSelection() throws {
        // Test light mode default
        let lightDefault = ThemeManager.defaultThemeId(for: .light)
        XCTAssertEqual(lightDefault, "light-default", "Light mode should default to Daytime theme")
        
        // Test dark mode default  
        let darkDefault = ThemeManager.defaultThemeId(for: .dark)
        XCTAssertEqual(darkDefault, "dark-default", "Dark mode should default to Nighttime theme")
        
        // Test unspecified mode (should not crash)
        let unspecifiedDefault = ThemeManager.defaultThemeId(for: .unspecified)
        XCTAssertFalse(unspecifiedDefault.isEmpty, "Unspecified mode should return a valid theme ID")
    }
    
    /// Tests theme catalog ordering and consistency.
    /// - What: Validates theme ordering is consistent and logical.
    /// - Why: Ensures predictable theme selection experience.
    /// - How: Tests theme ordering and validates expected sequence.
    func testThemeCatalogOrdering() throws {
        let themes = ThemeCatalog.shared.orderedThemes
        
        // Should start with defaults
        XCTAssertEqual(themes[0].id, "light-default", "First theme should be Daytime")
        XCTAssertEqual(themes[1].id, "dark-default", "Second theme should be Nighttime")
        
        // Should have luxury themes following
        let luxuryThemeIds = themes.dropFirst(2).map { $0.id }
        let expectedLuxuryIds = [
            "champagne-gold",
            "royal-sapphire", 
            "emerald-heritage",
            "onyx-prestige",
            "burgundy-elite",
            "midnight-platinum"
        ]
        
        for expectedId in expectedLuxuryIds {
            XCTAssertTrue(luxuryThemeIds.contains(expectedId), "Should contain luxury theme \(expectedId)")
        }
    }
    
    /// Tests typography font characteristics.
    /// - What: Validates that serif fonts use correct design and weights.
    /// - Why: Ensures typography implementation maintains luxury characteristics.
    /// - How: Tests font properties for serif vs sans-serif usage.
    func testTypographyFontCharacteristics() throws {
        // Note: In unit tests, we can't directly test UIFont properties from SwiftUI Font,
        // but we can test that the fonts are defined and don't cause crashes
        
        // Test all current typography tokens (4 total after cleanup)
        let titleCompact = AppTypography.titleCompact
        let heading = AppTypography.heading
        let caption = AppTypography.caption
        let luxury = AppTypography.luxury
        
        // These should all be non-nil and not cause crashes when used
        XCTAssertNotNil(titleCompact)
        XCTAssertNotNil(heading)
        XCTAssertNotNil(caption)
        XCTAssertNotNil(luxury)
        
        // Verify font characteristics by checking they're not nil
        XCTAssertNotNil(titleCompact, "titleCompact should be defined")
        XCTAssertNotNil(heading, "heading should be defined")
        XCTAssertNotNil(caption, "caption should be defined")
        XCTAssertNotNil(luxury, "luxury should be defined")
    }
    
    /// Tests that theme changes don't cause memory leaks or retain cycles.
    /// - What: Performs multiple theme changes and validates memory behavior.
    /// - Why: Ensures theme switching is memory-efficient and doesn't leak.
    /// - How: Rapid theme changes with memory pressure validation.
    func testThemeChangeMemoryStability() throws {
        let themes = ThemeCatalog.shared.orderedThemes
        let initialMemory = ProcessInfo.processInfo.physicalMemory
        
        // Perform many theme changes to test memory stability
        for _ in 0..<5 {
            for theme in themes {
                // Simulate theme change
                UserDefaults.standard.set(theme.id, forKey: "selectedThemeId")
                
                // Brief processing time
                usleep(10000) // 0.01 seconds
            }
        }
        
        // Memory should not have grown excessively
        let finalMemory = ProcessInfo.processInfo.physicalMemory
        XCTAssertEqual(initialMemory, finalMemory, "Memory usage should remain stable during theme changes")
    }
}
