import XCTest
@testable import CrownAndBarrel
import UIKit

final class ThemeDefaultingTests: XCTestCase {
    func testDefaultThemeIdMapping() {
        XCTAssertEqual(ThemeManager.defaultThemeId(for: .dark), "dark-default")
        XCTAssertEqual(ThemeManager.defaultThemeId(for: .light), "light-default")
        XCTAssertEqual(ThemeManager.defaultThemeId(for: .unspecified), "light-default")
    }
}


