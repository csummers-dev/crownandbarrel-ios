@testable import CrownAndBarrel
import UIKit
import XCTest

final class ThemeDefaultingTests: XCTestCase {
    func testDefaultThemeIdMapping() {
        XCTAssertEqual(ThemeManager.defaultThemeId(for: .dark), "dark-default")
        XCTAssertEqual(ThemeManager.defaultThemeId(for: .light), "light-default")
        XCTAssertEqual(ThemeManager.defaultThemeId(for: .unspecified), "light-default")
    }
}
