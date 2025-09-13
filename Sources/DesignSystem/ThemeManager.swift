import SwiftUI

/// Persists and exposes the user's theme preference.
/// - What: Bridges a stored preference to SwiftUI's `ColorScheme?` for `.preferredColorScheme`.
/// - Why: Allows forcing light/dark or following the system across the entire app.
/// - How: Uses `@AppStorage` to persist a simple enum in UserDefaults.
public struct ThemeManager {
    @AppStorage("selectedThemeId") private var selectedThemeId: String = ThemeCatalog.shared.defaultThemeId
    public init() {}
    public var preferredColorScheme: ColorScheme? {
        // Map the theme's `colorScheme` to SwiftUI's `ColorScheme?` for `.preferredColorScheme`.
        switch currentTheme.colorScheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    public var currentTheme: AppTheme {
        // Read-through lookup with a safe default so UI never crashes if an id is missing.
        ThemeCatalog.shared.themesById[selectedThemeId] ?? ThemeCatalog.shared.orderedThemes.first!
    }
}


