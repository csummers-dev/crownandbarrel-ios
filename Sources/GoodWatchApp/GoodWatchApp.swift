import SwiftUI
import UIKit

/// The main application entry point.
/// - What: Composes the root window and applies the theme (light/dark/system) via a small theme manager.
/// - Why: Centralized control of color scheme and scene lifecycle makes system-wide behavior (e.g., iOS 17 full-screen behavior) predictable.
/// - How: SwiftUI `App` creates a `WindowGroup` hosting `RootView`. The theme manager maps persisted preference to a `ColorScheme?`.

@main
struct GoodWatchApp: App {
    private let theme = ThemeManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(theme.preferredColorScheme)
                .onAppear {
                    let appearance = UITabBarAppearance()
                    appearance.configureWithDefaultBackground()
                    appearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
        }
    }
}


