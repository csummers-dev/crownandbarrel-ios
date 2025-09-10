import SwiftUI

/// Centralized color tokens for consistent theming across the app.
/// - What: Provides semantic colors (backgrounds, text, separator, accent) mapped to system-aware values.
/// - Why: Keeps views device/theme agnostic and simplifies future palette changes.
/// - How: Expose static properties, not raw values, so call sites stay readable and maintainable.

public enum AppColors {
    public static let accent = Color.accentColor
    public static let background = Color(.systemBackground)
    public static let secondaryBackground = Color(.secondarySystemBackground)
    public static let tertiaryBackground = Color(.tertiarySystemBackground)
    public static let separator = Color(.separator)
    public static let textPrimary = Color.primary
    public static let textSecondary = Color.secondary

    /// Subtle hairline color for borders like the tab bar top edge.
    public static let tabBarHairline = Color(.separator)

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
    public static let brandGold = Color(red: 0.83, green: 0.69, blue: 0.22)
    public static let brandSilver = Color(red: 0.75, green: 0.75, blue: 0.75)
    public static let brandWhite = Color.white
}


