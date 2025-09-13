import XCTest
@testable import CrownAndBarrel
import SwiftUI

final class ContrastTests: XCTestCase {
    func testTextContrastForThemes() {
        let themes = ThemeCatalog.shared.orderedThemes
        for theme in themes {
            let bg = UIColor(Color(themeString: theme.colors.background) ?? .white)
            let primary = UIColor(Color(themeString: theme.colors.textPrimary) ?? .black)
            let secondary = UIColor(Color(themeString: theme.colors.textSecondary) ?? .gray)

            let ratioPrimary = ContrastTests.contrastRatio(bg, primary)
            let ratioSecondary = ContrastTests.contrastRatio(bg, secondary)

            XCTAssertGreaterThanOrEqual(ratioPrimary, 7.0, "Primary text contrast too low for theme: \(theme.id)")
            XCTAssertGreaterThanOrEqual(ratioSecondary, 4.5, "Secondary text contrast too low for theme: \(theme.id)")
        }
    }

    // WCAG contrast ratio calculation
    static func contrastRatio(_ c1: UIColor, _ c2: UIColor) -> Double {
        func relLuminance(_ c: UIColor) -> Double {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            c.getRed(&r, green: &g, blue: &b, alpha: &a)
            func f(_ v: CGFloat) -> Double {
                let v = Double(v)
                return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
            }
            let R = 0.2126 * f(r)
            let G = 0.7152 * f(g)
            let B = 0.0722 * f(b)
            return R + G + B
        }
        let L1 = relLuminance(c1)
        let L2 = relLuminance(c2)
        let lighter = max(L1, L2)
        let darker = min(L1, L2)
        return (lighter + 0.05) / (darker + 0.05)
    }
}


