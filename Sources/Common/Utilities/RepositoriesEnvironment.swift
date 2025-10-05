import SwiftUI

private struct WatchRepositoryV2Key: EnvironmentKey {
    static let defaultValue: WatchRepositoryV2 = WatchRepositoryGRDB()
}

public extension EnvironmentValues {
    var watchRepositoryV2: WatchRepositoryV2 {
        get { self[WatchRepositoryV2Key.self] }
        set { self[WatchRepositoryV2Key.self] = newValue }
    }
}


