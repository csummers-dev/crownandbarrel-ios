import XCTest
@testable import CrownAndBarrel

/// Verifies spacing scale tokens remain consistent.
/// - What: Guards key increments used by recent list/card layout tweaks.
/// - Why: Prevents accidental regressions when adjusting design rhythm.
/// - How: Asserts specific points and ascending ordering.
final class SpacingTokensTests: XCTestCase {
    func testSpacingTokensValuesAndOrder() {
        XCTAssertEqual(AppSpacing.xxs, 2)
        XCTAssertEqual(AppSpacing.xs, 4)
        XCTAssertEqual(AppSpacing.md, 12)
        XCTAssertEqual(AppSpacing.lg, 16)

        XCTAssertLessThan(AppSpacing.xxs, AppSpacing.xs)
        XCTAssertLessThan(AppSpacing.xs, AppSpacing.sm)
        XCTAssertLessThan(AppSpacing.sm, AppSpacing.md)
        XCTAssertLessThan(AppSpacing.md, AppSpacing.lg)
        XCTAssertLessThan(AppSpacing.lg, AppSpacing.xl)
    }
}


