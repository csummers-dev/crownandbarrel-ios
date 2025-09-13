import SwiftUI

/// Centralized color tokens for consistent theming across the app.
/// - What: Provides semantic colors (backgrounds, text, separator, accent) mapped to system-aware values.
/// - Why: Keeps views device/theme agnostic and simplifies future palette changes.
/// - How: Expose static properties, not raw values, so call sites stay readable and maintainable.

public enum AppColors {
    private static var theme: AppTheme { ThemeAccess.currentTheme() }

    @inline(__always)
    private static func resolve(_ keyPath: KeyPath<AppThemeColors, String>) -> Color {
        // What: Resolve a color token from the current theme by key path.
        // Why: Ensures views always read the latest selected theme without caching mismatches.
        // How: Read the theme on each access; SwiftUI computes lazily so cost is negligible.
        let current = ThemeAccess.currentTheme()
        let value = current.colors[keyPath: keyPath]
        return Color(themeString: value) ?? Color.clear
    }

    public static var accent: Color { resolve(\.accent) }
    // Primary background maps to the theme's primary background color.
    public static var background: Color { resolve(\.background) }
    public static var secondaryBackground: Color { resolve(\.secondaryBackground) }
    public static var tertiaryBackground: Color { resolve(\.tertiaryBackground) }
    public static var separator: Color { resolve(\.separator) }
    public static var textPrimary: Color { resolve(\.textPrimary) }
    public static var textSecondary: Color { resolve(\.textSecondary) }
    public static var tabBarHairline: Color { resolve(\.tabBarHairline) }

    public static var chartPalette: [Color] {
        theme.colors.chartPalette.compactMap { Color(themeString: $0) }
    }

    // Legacy brand tokens for call sites; map to current theme
    public static var brandGold: Color { accent }
    public static let brandSilver = Color(red: 0.75, green: 0.75, blue: 0.75)
    public static let brandWhite = Color.white
}


