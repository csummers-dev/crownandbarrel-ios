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
}


