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
                .tint(AppColors.brandGold)
                .onAppear {
                    // Tab bar appearance
                    let tabAppearance = UITabBarAppearance()
                    tabAppearance.configureWithDefaultBackground()
                    tabAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    UITabBar.appearance().standardAppearance = tabAppearance
                    UITabBar.appearance().scrollEdgeAppearance = tabAppearance
                    UITabBar.appearance().tintColor = UIColor(AppColors.brandGold)
                    UITabBar.appearance().unselectedItemTintColor = UIColor(AppColors.textSecondary)

                    // Navigation bar appearance
                    let navAppearance = UINavigationBarAppearance()
                    navAppearance.configureWithDefaultBackground()
                    navAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    navAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textPrimary)]
                    navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.textPrimary)]
                    UINavigationBar.appearance().standardAppearance = navAppearance
                    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
                    UINavigationBar.appearance().tintColor = UIColor(AppColors.brandGold)

                    // Global control tint (UIKit hosting)
                    UIView.appearance().tintColor = UIColor(AppColors.brandGold)

                    // Segmented control (used in Collection view toggle)
                    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(AppColors.brandGold)
                    UISegmentedControl.appearance().setTitleTextAttributes([
                        .foregroundColor: UIColor(AppColors.brandWhite)
                    ], for: .selected)
                    UISegmentedControl.appearance().setTitleTextAttributes([
                        .foregroundColor: UIColor(AppColors.textPrimary)
                    ], for: .normal)

                    // Common button/bar button tint
                    UIBarButtonItem.appearance().tintColor = UIColor(AppColors.brandGold)
                    UIButton.appearance().tintColor = UIColor(AppColors.brandGold)
                }
        }
    }
}


