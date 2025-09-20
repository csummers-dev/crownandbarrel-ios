//
//  AppIconManager.swift
//  CrownAndBarrel
//
//  App Icon Management System
//  Provides centralized management of app icons, theme switching, and validation
//  for future user-selectable icon themes and dynamic icon updates.
//

import UIKit
import SwiftUI

/// Manager class for app icon operations and theme management
/// Handles icon validation, theme switching, and provides utilities for future
/// user-selectable icon themes and dynamic icon updates
@MainActor
class AppIconManager: ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared instance for app-wide icon management
    static let shared = AppIconManager()
    
    // MARK: - Properties
    
    /// Current app icon theme
    @Published var currentTheme: AppIconTheme = .light
    
    /// Available icon themes for future user selection
    @Published var availableThemes: [AppIconTheme] = [.light, .dark]
    
    /// Whether the device supports alternate app icons (iOS 10.3+)
    private var supportsAlternateIcons: Bool {
        return UIApplication.shared.supportsAlternateIcons
    }
    
    // MARK: - Initialization
    
    /// Private initializer for singleton pattern
    private init() {
        // Initialize with current system appearance
        updateThemeFromSystemAppearance()
        
        // Observe system appearance changes
        setupSystemAppearanceObserver()
    }
    
    // MARK: - Public Methods
    
    /// Updates the app icon theme based on current system appearance
    /// Called automatically when system appearance changes
    func updateThemeFromSystemAppearance() {
        let currentTraitCollection = UITraitCollection.current
        let userInterfaceStyle = currentTraitCollection.userInterfaceStyle
        
        switch userInterfaceStyle {
        case .dark:
            currentTheme = .dark
        case .light, .unspecified:
            currentTheme = .light
        @unknown default:
            currentTheme = .light
        }
        
        // Log theme change for debugging
        print("AppIconManager: Updated theme to \(currentTheme.displayName)")
    }
    
    /// Sets a specific icon theme (for future user selection feature)
    /// - Parameter theme: The theme to set
    /// - Returns: Success status of the operation
    @discardableResult
    func setIconTheme(_ theme: AppIconTheme) -> Bool {
        // For now, we only support system-based theme switching
        // Future implementation will support user-selected themes
        
        guard supportsAlternateIcons else {
            print("AppIconManager: Device does not support alternate app icons")
            return false
        }
        
        // Update current theme
        currentTheme = theme
        
        // Future implementation: Set alternate app icon based on theme
        // This will be implemented when user-selectable icons are added
        
        print("AppIconManager: Set icon theme to \(theme.displayName)")
        return true
    }
    
    /// Validates that all required icon files exist
    /// - Returns: Validation result with missing files if any
    func validateIconAssets() -> IconValidationResult {
        var missingFiles: [String] = []
        let invalidSizes: [String] = []
        
        // Check all required icon sizes
        for iconSize in AppIconSize.allCases {
            // Validate light mode icon
            let lightFilename = iconSize.lightFilename
            if !validateIconFile(lightFilename, expectedSize: iconSize.pixelSize) {
                missingFiles.append(lightFilename)
            }
            
            // Validate dark mode icon (except for marketing icon)
            if iconSize != .marketing {
                let darkFilename = iconSize.darkFilename
                if !validateIconFile(darkFilename, expectedSize: iconSize.pixelSize) {
                    missingFiles.append(darkFilename)
                }
            }
        }
        
        // Create validation result
        let isValid = missingFiles.isEmpty && invalidSizes.isEmpty
        
        return IconValidationResult(
            isValid: isValid,
            missingFiles: missingFiles,
            invalidSizes: invalidSizes
        )
    }
    
    /// Gets information about a specific icon size
    /// - Parameter size: The icon size to get info for
    /// - Returns: Icon information including dimensions and filename
    func getIconInfo(for size: AppIconSize) -> IconInfo {
        return IconInfo(
            size: size,
            lightFilename: size.lightFilename,
            darkFilename: size.darkFilename,
            pixelDimensions: size.pixelSize,
            pointDimensions: size.pointSize,
            scaleFactor: size.scale
        )
    }
    
    /// Gets all available icon information
    /// - Returns: Array of icon information for all sizes
    func getAllIconInfo() -> [IconInfo] {
        return AppIconSize.allCases.map { getIconInfo(for: $0) }
    }
    
    // MARK: - Private Methods
    
    /// Validates a single icon file
    /// - Parameters:
    ///   - filename: The filename to validate
    ///   - expectedSize: The expected pixel dimensions
    /// - Returns: Whether the file exists and has correct dimensions
    private func validateIconFile(_ filename: String, expectedSize: CGSize) -> Bool {
        // Check if file exists in bundle
        guard let imagePath = Bundle.main.path(forResource: filename.replacingOccurrences(of: ".png", with: ""), ofType: "png"),
              let image = UIImage(contentsOfFile: imagePath) else {
            return false
        }
        
        // Check dimensions
        let actualSize = image.size
        let expectedWidth = Int(expectedSize.width)
        let expectedHeight = Int(expectedSize.height)
        let actualWidth = Int(actualSize.width)
        let actualHeight = Int(actualSize.height)
        
        return actualWidth == expectedWidth && actualHeight == expectedHeight
    }
    
    /// Sets up observer for system appearance changes
    private func setupSystemAppearanceObserver() {
        // Note: System appearance changes are handled automatically by iOS
        // This method is reserved for future manual theme switching
        // when user-selectable themes are implemented
    }
}

// MARK: - Supporting Types

/// Result of icon validation operation
struct IconValidationResult {
    /// Whether all icons are valid
    let isValid: Bool
    
    /// List of missing icon files
    let missingFiles: [String]
    
    /// List of icons with invalid sizes
    let invalidSizes: [String]
    
    /// Human-readable description of validation result
    var description: String {
        if isValid {
            return "All app icons are valid"
        } else {
            var issues: [String] = []
            
            if !missingFiles.isEmpty {
                issues.append("Missing files: \(missingFiles.joined(separator: ", "))")
            }
            
            if !invalidSizes.isEmpty {
                issues.append("Invalid sizes: \(invalidSizes.joined(separator: ", "))")
            }
            
            return "Icon validation failed: \(issues.joined(separator: "; "))"
        }
    }
}

/// Information about a specific app icon
struct IconInfo {
    /// The icon size enum
    let size: AppIconSize
    
    /// Light mode filename
    let lightFilename: String
    
    /// Dark mode filename
    let darkFilename: String
    
    /// Pixel dimensions
    let pixelDimensions: CGSize
    
    /// Point dimensions
    let pointDimensions: CGSize
    
    /// Scale factor
    let scaleFactor: Int
    
    /// Human-readable description
    var description: String {
        return "\(size.rawValue): \(Int(pixelDimensions.width))x\(Int(pixelDimensions.height))px @\(scaleFactor)x"
    }
}

// MARK: - Extensions

extension AppIconManager {
    
    /// Debug method to print all icon information
    func printIconInfo() {
        print("=== App Icon Information ===")
        print("Current Theme: \(currentTheme.displayName)")
        print("Supports Alternate Icons: \(supportsAlternateIcons)")
        print("Available Themes: \(availableThemes.map { $0.displayName }.joined(separator: ", "))")
        print("")
        
        print("Icon Sizes:")
        for iconInfo in getAllIconInfo() {
            print("  - \(iconInfo.description)")
            print("    Light: \(iconInfo.lightFilename)")
            print("    Dark: \(iconInfo.darkFilename)")
        }
        
        print("")
        print("Validation Result:")
        let validation = validateIconAssets()
        print("  \(validation.description)")
    }
}

// MARK: - SwiftUI Integration

extension AppIconManager {
    
    /// SwiftUI view modifier for observing icon theme changes
    struct IconThemeModifier: ViewModifier {
        @StateObject private var iconManager = AppIconManager.shared
        
        func body(content: Content) -> some View {
            content
                .onReceive(iconManager.$currentTheme) { theme in
                    // Handle theme changes in SwiftUI views
                    // This can be used to update UI elements based on icon theme
                    print("SwiftUI: Icon theme changed to \(theme.displayName)")
                }
        }
    }
}

// MARK: - View Extension

extension View {
    
    /// Applies icon theme observation to a view
    /// - Returns: View with icon theme observation
    func observeIconTheme() -> some View {
        modifier(AppIconManager.IconThemeModifier())
    }
}
