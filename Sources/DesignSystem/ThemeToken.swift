import SwiftUI

/// An environment token that changes whenever the selected theme id changes.
/// Views that read this value will refresh immediately on theme selection.
private struct ThemeTokenKey: EnvironmentKey {
    static let defaultValue: String = ""
}

public extension EnvironmentValues {
    var themeToken: String {
        get { self[ThemeTokenKey.self] }
        set { self[ThemeTokenKey.self] = newValue }
    }
}


