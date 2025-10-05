import SwiftUI

private struct UseWatchV2Key: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var useWatchV2: Bool {
        get { self[UseWatchV2Key.self] }
        set { self[UseWatchV2Key.self] = newValue }
    }
}


