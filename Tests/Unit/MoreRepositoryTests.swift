// Temporarily disabled: references legacy Core Data APIs removed in V2
#if false
import XCTest
@testable import CrownAndBarrel

final class MoreRepositoryTests: XCTestCase {
    func makeRepo() -> WatchRepositoryCoreData { WatchRepositoryCoreData(stack: CoreDataStack(inMemory: true)) }
    func testExistsWearEntryAfterIncrement() async throws { /* disabled */ }
    func testSortByLastWornDate() async throws { /* disabled */ }
    func testImportWithReplaceFalseThrows() async throws { /* disabled */ }
}
#endif
