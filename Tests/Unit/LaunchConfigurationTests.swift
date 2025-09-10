import XCTest

final class LaunchConfigurationTests: XCTestCase {
    func testInfoContainsModernLaunchScreen() throws {
        // What: Validate that a modern launch screen key is present.
        // Why: Guards against regressions that could reintroduce legacy
        //      letterboxed launch behavior on modern devices.
        // How: Read the main app bundle's Info.plist and look for either
        //      `UILaunchStoryboardName` or `UILaunchScreen`. In certain unit
        //      test environments this may not be visible; skip in that case.
        // Resolve the tested app bundle via the process’s main executable path.
        // This ensures we read the host app, not the test bundle.
        guard let mainExe = Bundle.main.executablePath,
              let appBundle = Bundle(path: (mainExe as NSString).deletingLastPathComponent),
              let info = appBundle.infoDictionary else {
            XCTFail("Unable to read app Info dictionary")
            return
        }
        let hasStoryboard = info["UILaunchStoryboardName"] != nil
        let hasLaunchDict = info["UILaunchScreen"] != nil
        XCTAssertTrue(hasStoryboard || hasLaunchDict, "Expected UILaunchStoryboardName or UILaunchScreen in Info.plist to avoid legacy letterboxing.")
    }
}


