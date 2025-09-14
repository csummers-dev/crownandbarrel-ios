import XCTest
@testable import CrownAndBarrel

final class RadiusTokensTests: XCTestCase {
    func testRadiusTokensAreOrderedAndPositive() {
        let small = AppRadius.small
        let medium = AppRadius.medium
        let large = AppRadius.large

        XCTAssertGreaterThan(small, 0)
        XCTAssertGreaterThan(medium, 0)
        XCTAssertGreaterThan(large, 0)

        XCTAssertLessThan(small, medium)
        XCTAssertLessThan(medium, large)
    }
}


