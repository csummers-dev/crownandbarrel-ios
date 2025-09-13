import SwiftUI

/// SettingsView presents user preferences that affect global app behavior.
/// - What: Currently exposes the theme preference (System/Light/Dark).
/// - Why: Users expect control over appearance; tying to `@AppStorage` persists
///   the choice across launches without custom persistence code.
/// - How: The picker binds to a raw `String` stored in `AppStorage` that
///   corresponds to `ThemePreference.rawValue`. The `ThemeManager` reads this
///   value at app start and applies the appropriate color scheme.
struct SettingsView: View {
    @Environment(\.themeToken) private var themeToken
    /// Persisted raw value for the selected theme preference.
    /// Using `@AppStorage` keeps the setting in `UserDefaults` under the key
    /// `themePreference` and automatically updates the UI when changed.
    /// Combined theme selector: stores the selected theme id (drives color scheme and palette)
    @AppStorage("selectedThemeId") private var selectedThemeId: String = ThemeCatalog.shared.defaultThemeId

    /// The root content view for settings. Uses a `Form` to match iOS
    /// conventions and to ensure dynamic type and accessibility work out of the box.
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $selectedThemeId) {
                    ForEach(ThemeCatalog.shared.orderedThemes) { theme in
                        ThemeRow(theme: theme)
                            .tag(theme.id)
                    }
                }
                .pickerStyle(.inline)
                .tint(AppColors.textPrimary)
                .foregroundStyle(AppColors.textPrimary)
                .listRowBackground(AppColors.background)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(AppTypography.titleCompact)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .id(themeToken)
    }
}

private struct ThemeRow: View {
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 8) {
            Text(theme.name)
            Spacer()
            Swatches(hexes: Array(theme.colors.chartPalette.prefix(5)))
        }
    }
}

private struct Swatches: View {
    let hexes: [String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(hexes.enumerated()), id: \.offset) { _, hex in
                Circle()
                    .fill(Color(themeString: hex) ?? .clear)
                    .frame(width: 10, height: 10)
            }
        }
    }
}
