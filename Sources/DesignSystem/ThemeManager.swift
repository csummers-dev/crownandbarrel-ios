import SwiftUI

/// Persists and exposes the user's theme preference.
/// - What: Bridges a stored preference to SwiftUI's `ColorScheme?` for `.preferredColorScheme`.
/// - Why: Allows forcing light/dark or following the system across the entire app.
/// - How: Uses `@AppStorage` to persist a simple enum in UserDefaults.
public struct ThemeManager {
    @AppStorage("themePreference") private var themeRaw: String = ThemePreference.system.rawValue
    public init() {}
    public var preferredColorScheme: ColorScheme? {
        guard let pref = ThemePreference(rawValue: themeRaw) else { return nil }
        switch pref { case .system: return nil; case .light: return .light; case .dark: return .dark }
    }
}


