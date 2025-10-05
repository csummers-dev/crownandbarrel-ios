// Temporarily disabled: references unstable/in-transition APIs during V2 migration
#if false
import XCTest
@testable import CrownAndBarrel

final class ExampleTests: XCTestCase {
    @MainActor
    func testOptimisticRefreshNotificationTriggersReload() async throws { }
}

@MainActor
final class InMemoryRepo: WatchRepository {
    private var items: [Watch] = []
}
#endif
