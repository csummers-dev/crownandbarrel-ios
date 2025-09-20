//
//  AppIconSize.swift
//  CrownAndBarrel
//
//  App Icon Size Management
//  Provides centralized management of app icon sizes and naming conventions
//  for flexible future development and theme-based icon support.
//

import Foundation

/// Enum defining all required app icon sizes for iOS applications
/// Provides centralized management of icon dimensions and file naming
/// for consistent icon generation and asset management
///
/// Naming Convention:
/// - Light mode: {IconName}.png (e.g., Icon-20@2x.png, AppIcon-1024.png)
/// - Dark mode: {IconName}-dark.png (e.g., Icon-20@2x-dark.png, AppIcon-1024-dark.png)
enum AppIconSize: String, CaseIterable {
    
    // MARK: - iPhone App Icon Sizes
    
    /// 20x20 point size, 2x scale (40x40 pixels)
    case icon20x2x = "Icon-20@2x"
    
    /// 20x20 point size, 3x scale (60x60 pixels)
    case icon20x3x = "Icon-20@3x"
    
    /// 29x29 point size, 2x scale (58x58 pixels)
    case icon29x2x = "Icon-29@2x"
    
    /// 29x29 point size, 3x scale (87x87 pixels)
    case icon29x3x = "Icon-29@3x"
    
    /// 40x40 point size, 2x scale (80x80 pixels)
    case icon40x2x = "Icon-40@2x"
    
    /// 40x40 point size, 3x scale (120x120 pixels)
    case icon40x3x = "Icon-40@3x"
    
    /// 60x60 point size, 2x scale (120x120 pixels)
    case icon60x2x = "Icon-60@2x"
    
    /// 60x60 point size, 3x scale (180x180 pixels)
    case icon60x3x = "Icon-60@3x"
    
    /// iOS Marketing icon (1024x1024 pixels)
    /// Dark mode variant: AppIcon-1024-dark.png
    case marketing = "AppIcon-1024"
    
    // MARK: - Computed Properties
    
    /// The actual pixel dimensions for each icon size
    var pixelSize: CGSize {
        switch self {
        case .icon20x2x:
            return CGSize(width: 40, height: 40)
        case .icon20x3x:
            return CGSize(width: 60, height: 60)
        case .icon29x2x:
            return CGSize(width: 58, height: 58)
        case .icon29x3x:
            return CGSize(width: 87, height: 87)
        case .icon40x2x:
            return CGSize(width: 80, height: 80)
        case .icon40x3x:
            return CGSize(width: 120, height: 120)
        case .icon60x2x:
            return CGSize(width: 120, height: 120)
        case .icon60x3x:
            return CGSize(width: 180, height: 180)
        case .marketing:
            return CGSize(width: 1024, height: 1024)
        }
    }
    
    /// The logical point size for each icon
    var pointSize: CGSize {
        switch self {
        case .icon20x2x, .icon20x3x:
            return CGSize(width: 20, height: 20)
        case .icon29x2x, .icon29x3x:
            return CGSize(width: 29, height: 29)
        case .icon40x2x, .icon40x3x:
            return CGSize(width: 40, height: 40)
        case .icon60x2x, .icon60x3x:
            return CGSize(width: 60, height: 60)
        case .marketing:
            return CGSize(width: 1024, height: 1024)
        }
    }
    
    /// The scale factor for each icon size
    var scale: Int {
        switch self {
        case .icon20x2x, .icon29x2x, .icon40x2x, .icon60x2x:
            return 2
        case .icon20x3x, .icon29x3x, .icon40x3x, .icon60x3x:
            return 3
        case .marketing:
            return 1
        }
    }
    
    // MARK: - File Naming
    
    /// Generates the filename for a specific icon size and theme
    /// - Parameter theme: The theme variant (light/dark)
    /// - Returns: The complete filename including extension
    func filename(for theme: AppIconTheme) -> String {
        switch theme {
        case .light:
            return "\(rawValue).png"
        case .dark:
            return "\(rawValue)-dark.png"
        }
    }
    
    /// Generates the filename for the light theme (default)
    var lightFilename: String {
        return filename(for: .light)
    }
    
    /// Generates the filename for the dark theme
    var darkFilename: String {
        return filename(for: .dark)
    }
}

/// Enum defining available app icon themes
/// Supports light and dark mode variants for iOS 13+ compatibility
enum AppIconTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    
    /// Human-readable display name for the theme
    var displayName: String {
        switch self {
        case .light:
            return "Light Mode"
        case .dark:
            return "Dark Mode"
        }
    }
}

// MARK: - Extensions

extension AppIconSize {
    
    /// All iPhone-specific icon sizes (excludes marketing)
    static var iPhoneIcons: [AppIconSize] {
        return allCases.filter { $0 != .marketing }
    }
    
    /// All marketing icons
    static var marketingIcons: [AppIconSize] {
        return [.marketing]
    }
    
    /// Provides a description of the icon size for debugging
    var description: String {
        return "\(rawValue) (\(Int(pixelSize.width))x\(Int(pixelSize.height))px)"
    }
}

// MARK: - Validation

extension AppIconSize {
    
    /// Validates that the icon size meets Apple's requirements
    var isValidForAppStore: Bool {
        // All our defined sizes are valid for App Store submission
        return true
    }
    
    /// Checks if this size is required for iPhone apps
    var isRequiredForiPhone: Bool {
        return AppIconSize.iPhoneIcons.contains(self)
    }
}
