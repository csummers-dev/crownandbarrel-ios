import XCTest
import SwiftUI
@testable import CrownAndBarrel

final class ThemeCatalogTests: XCTestCase {
    func testCatalogLoadsThemes() {
        let catalog = ThemeCatalog.shared
        XCTAssertFalse(catalog.orderedThemes.isEmpty, "Themes should load from JSON or fallback")
        XCTAssertNotNil(catalog.themesById[catalog.defaultThemeId])
        // Ensure each theme has 5 chart colors
        for theme in catalog.orderedThemes {
            XCTAssertEqual(theme.colors.chartPalette.count, 5, "Each theme must define 5 chart colors")
        }
    }

    func testColorParsing() {
        XCTAssertNotNil(Color(themeString: "#FFFFFF"))
        XCTAssertNotNil(Color(themeString: "#000000FF"))
        XCTAssertNotNil(Color(themeString: "rgba(60,60,67,0.29)"))
        XCTAssertNil(Color(themeString: "not-a-color"))
    }
}


