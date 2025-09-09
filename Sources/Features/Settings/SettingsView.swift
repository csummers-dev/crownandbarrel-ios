import SwiftUI

/// SettingsView presents user preferences that affect global app behavior.
/// - What: Currently exposes the theme preference (System/Light/Dark).
/// - Why: Users expect control over appearance; tying to `@AppStorage` persists
///   the choice across launches without custom persistence code.
/// - How: The picker binds to a raw `String` stored in `AppStorage` that
///   corresponds to `ThemePreference.rawValue`. The `ThemeManager` reads this
///   value at app start and applies the appropriate color scheme.
struct SettingsView: View {
    /// Persisted raw value for the selected theme preference.
    /// Using `@AppStorage` keeps the setting in `UserDefaults` under the key
    /// `themePreference` and automatically updates the UI when changed.
    @AppStorage("themePreference") private var themeRaw: String = ThemePreference.system.rawValue

    /// The root content view for settings. Uses a `Form` to match iOS
    /// conventions and to ensure dynamic type and accessibility work out of the box.
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $themeRaw) {
                    ForEach(ThemePreference.allCases) { pref in
                        Text(pref.rawValue.capitalized).tag(pref.rawValue)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}


