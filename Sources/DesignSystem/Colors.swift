import SwiftUI

/// Centralized color tokens for consistent theming across the app.
/// - What: Provides semantic colors (backgrounds, text, separator, accent) mapped to system-aware values.
/// - Why: Keeps views device/theme agnostic and simplifies future palette changes.
/// - How: Expose static properties, not raw values, so call sites stay readable and maintainable.

public enum AppColors {
    /// Helper to resolve a color that differs in light vs. dark mode.
    private static func themed(light: Color, dark: Color) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    // MARK: - Semantic Colors
    // Light theme palette (hex): 363636, 242f40, cca43b, e5e5e5, ffffff
    // Mapping:
    // - background: ffffff
    // - secondary/tertiary background: e5e5e5
    // - textPrimary: 242f40
    // - textSecondary: 363636
    // - accent/brandGold: cca43b

    public static var accent: Color { themed(
        light: Color(red: 0.80, green: 0.64, blue: 0.23), // #cca43b
        dark: Color.accentColor
    ) }

    public static var background: Color { themed(
        light: .white, // #ffffff
        dark: Color(.systemBackground)
    ) }

    public static var secondaryBackground: Color { themed(
        light: Color(red: 0.90, green: 0.90, blue: 0.90), // #e5e5e5
        dark: Color(.secondarySystemBackground)
    ) }

    public static var tertiaryBackground: Color { themed(
        light: Color(red: 0.90, green: 0.90, blue: 0.90), // #e5e5e5
        dark: Color(.tertiarySystemBackground)
    ) }

    public static var separator: Color { themed(
        light: Color(red: 0.90, green: 0.90, blue: 0.90), // #e5e5e5
        dark: Color(.separator)
    ) }

    public static var textPrimary: Color { themed(
        light: Color(red: 0.14, green: 0.18, blue: 0.25), // #242f40
        dark: Color.primary
    ) }

    public static var textSecondary: Color { themed(
        light: Color(red: 0.21, green: 0.21, blue: 0.21), // #363636
        dark: Color.secondary
    ) }

    /// Subtle hairline color for borders like the tab bar top edge.
    public static var tabBarHairline: Color { themed(
        light: Color(red: 0.90, green: 0.90, blue: 0.90), // #e5e5e5
        dark: Color(.separator)
    ) }

    /// Palette for charts (metallic-inspired with good contrast on light/dark).
    /// Order: gold, silver, steel blue, emerald, graphite.
    public static let chartPalette: [Color] = [
        Color(red: 0.83, green: 0.69, blue: 0.22), // gold
        Color(red: 0.75, green: 0.75, blue: 0.75), // silver
        Color(red: 0.33, green: 0.42, blue: 0.58), // steel blue
        Color(red: 0.10, green: 0.63, blue: 0.52), // emerald
        Color(red: 0.33, green: 0.33, blue: 0.33)  // graphite
    ]

    // Brand accents
    public static let brandGold = Color(red: 0.80, green: 0.64, blue: 0.23) // #cca43b
    public static let brandSilver = Color(red: 0.75, green: 0.75, blue: 0.75)
    public static let brandWhite = Color.white
}


