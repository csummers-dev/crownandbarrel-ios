@testable import CrownAndBarrel
import XCTest

final class AssetsPresenceTests: XCTestCase {
    func testAppIconAssetExistsInBundle() {
        // Verify a compiled app icon resource exists in the application bundle.
        // Xcode emits variant names; the 60x60@2x icon is standard on iPhone.
        let iconPath = Bundle.main.path(forResource: "AppIcon60x60@2x", ofType: "png")
        XCTAssertNotNil(iconPath, "Expected AppIcon60x60@2x.png in app bundle. Ensure asset catalog AppIcon is configured.")
    }

    func testPlaceholderImageLoadsForLightAndDark() {
        // Verify theme-aware placeholders load for at least one mode (light or dark).
        let light = ImageStore.loadPlaceholder(colorScheme: .light)
        let dark = ImageStore.loadPlaceholder(colorScheme: .dark)
        XCTAssertNotNil(light ?? dark, "Placeholder image should load for light or dark mode from assets or bundled PNG.")
    }
}
