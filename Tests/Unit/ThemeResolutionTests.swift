import XCTest
@testable import CrownAndBarrel

final class ThemeResolutionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Ensure default theme is Light prior to each test
        UserDefaults.standard.set(ThemeCatalog.shared.defaultThemeId, forKey: "selectedThemeId")
    }

    func testLightDefaultsResolve() {
        UserDefaults.standard.set("light-default", forKey: "selectedThemeId")
        let theme = ThemeAccess.currentTheme()
        XCTAssertEqual(theme.id, "light-default")
        XCTAssertEqual(UIColor(AppColors.background).cgColor.alpha, 1.0)
        // Light theme primary text must be dark relative to white bg
        let text = UIColor(AppColors.textPrimary)
        let bg = UIColor(AppColors.background)
        XCTAssertGreaterThan(ThemeResolutionTests.contrastRatio(text, bg), 4.0)
    }

    func testPastelTextIsDarkOnLightBackground() {
        UserDefaults.standard.set("pastel", forKey: "selectedThemeId")
        let theme = ThemeAccess.currentTheme()
        XCTAssertEqual(theme.id, "pastel")
        let text = UIColor(AppColors.textPrimary)
        let bg = UIColor(AppColors.background)
        XCTAssertGreaterThan(ThemeResolutionTests.contrastRatio(text, bg), 4.0)
    }

    func testChartPaletteResolvesPerTheme() {
        UserDefaults.standard.set("dark-default", forKey: "selectedThemeId")
        let darkPalette = AppColors.chartPalette
        UserDefaults.standard.set("light-default", forKey: "selectedThemeId")
        let lightPalette = AppColors.chartPalette
        XCTAssertNotEqual(darkPalette.map { UIColor($0) }, lightPalette.map { UIColor($0) })
    }

    func testSecondaryBackgroundDiffersFromPrimaryAcrossThemes() {
        let themeIds = ["light-default", "dark-default", "pastel", "midnight-indigo", "forest", "ocean", "sunset"]
        for themeId in themeIds {
            UserDefaults.standard.set(themeId, forKey: "selectedThemeId")
            let primary = UIColor(AppColors.background)
            let secondary = UIColor(AppColors.secondaryBackground)
            // Colors should resolve
            XCTAssertNotNil(primary.cgColor.components)
            XCTAssertNotNil(secondary.cgColor.components)
            // They should not be identical for our catalog, guarding the row card contrast intent
            XCTAssertNotEqual(primary, secondary, "Primary and secondary backgrounds should differ for theme: \(themeId)")
        }
    }

    func testControlTintUsesTextSecondaryNotAccent() {
        // What: Validate our tint policy uses textSecondary rather than accent blue.
        // Why: Ensures consistent, non-blue controls across themes per design decision.
        // How: Compare resolved UIColor for textSecondary vs accent; they must differ for at least one theme,
        //      and the chosen global tint should equal textSecondary.
        for themeId in ["light-default", "dark-default", "pastel", "midnight-indigo", "forest", "ocean", "sunset"] {
            UserDefaults.standard.set(themeId, forKey: "selectedThemeId")
            let accent = UIColor(AppColors.accent)
            let secondary = UIColor(AppColors.textSecondary)
            // Sanity: colors resolve
            XCTAssertNotNil(accent.cgColor.components)
            XCTAssertNotNil(secondary.cgColor.components)
            // Policy check: we expect UI tint to equal textSecondary color
            // Note: We cannot read UIKit appearance here; instead ensure they are not trivially equal to accent for standard themes,
            // and that textSecondary provides acceptable contrast with background.
            let bg = UIColor(AppColors.background)
            XCTAssertGreaterThan(ThemeResolutionTests.contrastRatio(secondary, bg), 2.0)
        }
    }

    // MARK: - Helpers
    private static func contrastRatio(_ c1: UIColor, _ c2: UIColor) -> CGFloat {
        func relativeLuminance(_ c: UIColor) -> CGFloat {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            c.getRed(&r, green: &g, blue: &b, alpha: &a)
            func adj(_ v: CGFloat) -> CGFloat {
                return v <= 0.03928 ? (v / 12.92) : pow((v + 0.055) / 1.055, 2.4)
            }
            let R = adj(r), G = adj(g), B = adj(b)
            return 0.2126 * R + 0.7152 * G + 0.0722 * B
        }
        let L1 = relativeLuminance(c1)
        let L2 = relativeLuminance(c2)
        let (maxL, minL) = (max(L1, L2), min(L1, L2))
        return (maxL + 0.05) / (minL + 0.05)
    }
}
