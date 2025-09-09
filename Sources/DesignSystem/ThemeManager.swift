import SwiftUI

public struct ThemeManager {
    @AppStorage("themePreference") private var themeRaw: String = ThemePreference.system.rawValue
    public init() {}
    public var preferredColorScheme: ColorScheme? {
        guard let pref = ThemePreference(rawValue: themeRaw) else { return nil }
        switch pref { case .system: return nil; case .light: return .light; case .dark: return .dark }
    }
}


