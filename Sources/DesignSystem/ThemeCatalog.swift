import SwiftUI

/// Represents the color scheme intent for a theme.
public enum AppThemeColorScheme: String, Codable {
    case system
    case light
    case dark
}

/// Raw color values for a theme, stored as hex strings (e.g., "#RRGGBB" or "#RRGGBBAA") or rgba("r,g,b,a").
public struct AppThemeColors: Codable {
    public let accent: String
    public let background: String
    public let secondaryBackground: String
    public let tertiaryBackground: String
    public let separator: String
    public let textPrimary: String
    public let textSecondary: String
    public let tabBarHairline: String
    public let chartPalette: [String]
}

/// A complete theme definition loaded from Themes.json.
public struct AppTheme: Codable, Identifiable {
    public let id: String
    public let name: String
    public let colorScheme: AppThemeColorScheme
    public let colors: AppThemeColors
}

/// A lightweight theme provider that loads a catalog of themes from a JSON resource at runtime.
/// ThemeCatalog loads and holds all themes defined in `AppResources/Themes.json`.
/// - What: Parses an ordered list of `AppTheme` and exposes lookup helpers.
/// - Why: Centralizes theme configuration so UI code only depends on tokens, not raw values.
/// - How: Loads once at init; provides `reloadFromBundle()` for hot reloads in development.
public final class ThemeCatalog {
    public static let shared = ThemeCatalog()

    private(set) var themesById: [String: AppTheme] = [:]
    public private(set) var orderedThemes: [AppTheme] = []
    public let defaultThemeId: String = "light-default"

    private init() {
        reloadFromBundle()
    }

    /// Attempts to load Themes.json from the main bundle. Falls back to a built-in default if missing.
    /// Attempts to reload the theme catalog from the app bundle.
    /// Falls back to a minimal Light/Dark set to ensure the app remains usable.
    public func reloadFromBundle() {
        if let url = Bundle.main.url(forResource: "Themes", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([AppTheme].self, from: data) {
            applyCatalog(decoded)
            return
        }
        // Fallback: minimal Light/Dark default themes to keep the app functional.
        // Rationale: Prevents hard failures if the JSON is missing or invalid in debug builds.
        let fallback: [AppTheme] = [
            AppTheme(
                id: "light-default",
                name: "Daytime",
                colorScheme: .light,
                colors: AppThemeColors(
                    accent: "#007AFF",
                    background: "#FFFFFF",
                    secondaryBackground: "#F2F2F7",
                    tertiaryBackground: "#FFFFFF",
                    separator: "rgba(60,60,67,0.29)",
                    textPrimary: "#000000",
                    textSecondary: "rgba(60,60,67,0.60)",
                    tabBarHairline: "rgba(60,60,67,0.29)",
                    chartPalette: ["#0A84FF", "#34C759", "#FF9500", "#FF2D55", "#AF52DE"]
                )
            ),
            AppTheme(
                id: "dark-default",
                name: "Nighttime",
                colorScheme: .dark,
                colors: AppThemeColors(
                    accent: "#0A84FF",
                    background: "#000000",
                    secondaryBackground: "#1C1C1E",
                    tertiaryBackground: "#2C2C2E",
                    separator: "rgba(84,84,88,0.60)",
                    textPrimary: "#FFFFFF",
                    textSecondary: "rgba(235,235,245,0.60)",
                    tabBarHairline: "rgba(84,84,88,0.65)",
                    chartPalette: ["#64D2FF", "#30D158", "#FFD60A", "#FF375F", "#BF5AF2"]
                )
            )
        ]
        applyCatalog(fallback)
    }

    /// Applies a new set of themes to the in-memory catalog.
    /// - Note: Keeps both an ordered list (for pickers) and a dictionary (for fast lookup).
    private func applyCatalog(_ themes: [AppTheme]) {
        orderedThemes = themes
        themesById = Dictionary(uniqueKeysWithValues: themes.map { ($0.id, $0) })
    }
}

// MARK: - Color parsing helpers

extension Color {
    /// Creates a Color from a theme string: `#RRGGBB`, `#RRGGBBAA`, or `rgba(r,g,b,a)`.
    /// - Why: Allows flexible authoring of colors in JSON without app code changes.
    init?(themeString: String) {
        let trimmed = themeString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.hasPrefix("#") {
            self.init(hex: trimmed)
        } else if trimmed.hasPrefix("rgba(") {
            self.init(rgbaString: trimmed)
        } else {
            return nil
        }
    }

    /// Parses `#RRGGBB` or `#RRGGBBAA` hex string.
    init?(hex: String) {
        var hexString = hex
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        guard hexString.count == 6 || hexString.count == 8 else { return nil }
        var value: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&value) else { return nil }
        let r, g, b, a: Double
        if hexString.count == 6 {
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
            a = 1.0
        } else {
            r = Double((value >> 24) & 0xFF) / 255.0
            g = Double((value >> 16) & 0xFF) / 255.0
            b = Double((value >> 8) & 0xFF) / 255.0
            a = Double(value & 0xFF) / 255.0
        }
        self = Color(red: r, green: g, blue: b, opacity: a)
    }

    /// Parses `rgba(r,g,b,a)` where `r,g,b ∈ [0,255]` and `a ∈ [0,1]`.
    init?(rgbaString: String) {
        // Expected format: rgba(r,g,b,a) where r,g,b 0-255 and a 0-1
        guard let open = rgbaString.firstIndex(of: "("), let close = rgbaString.firstIndex(of: ")") else { return nil }
        let params = rgbaString[rgbaString.index(after: open)..<close]
        let parts = params.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 4,
              let r = Double(parts[0]), let g = Double(parts[1]), let b = Double(parts[2]), let a = Double(parts[3]) else { return nil }
        self = Color(red: r/255.0, green: g/255.0, blue: b/255.0, opacity: a)
    }
}

// MARK: - Theme accessors

/// Static helpers to read the active theme and identifier.
public enum ThemeAccess {
    /// Returns the current theme id from storage, or the default.
    public static func currentThemeId() -> String {
        let stored = UserDefaults.standard.string(forKey: "selectedThemeId")
        return stored ?? ThemeCatalog.shared.defaultThemeId
    }

    /// Returns the current theme object, falling back to default if missing.
    /// The full theme object for the current selection.
    public static func currentTheme() -> AppTheme {
        let id = currentThemeId()
        return ThemeCatalog.shared.themesById[id] ?? ThemeCatalog.shared.themesById[ThemeCatalog.shared.defaultThemeId]!
    }
}


