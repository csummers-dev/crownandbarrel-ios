import SwiftUI
import UIKit

/// The main application entry point.
/// - What: Composes the root window and applies the theme (light/dark/system) via a small theme manager.
/// - Why: Centralized control of color scheme and scene lifecycle makes system-wide behavior (e.g., iOS 17 full-screen behavior) predictable.
/// - How: SwiftUI `App` creates a `WindowGroup` hosting `RootView`. The theme manager maps persisted preference to a `ColorScheme?`.

@main
struct GoodWatchApp: App {
    private let theme = ThemeManager()
    @AppStorage("selectedThemeId") private var selectedThemeId: String = ThemeCatalog.shared.defaultThemeId
    /// Controls the visibility of the splash overlay at boot.
    /// - What: Starts true so the user sees a branded, theme-matching screen.
    /// - Why: Avoids a flash of unthemed UI between process launch and SwiftUI render.
    /// - How: Fades out shortly after the first frame using a small, non-blocking delay.
    @State private var showSplash: Bool = true

    var body: some Scene {
        WindowGroup {
            // Compose the app root with a transient, theme-driven splash overlay.
            // The overlay uses the current theme's background and secondary text color
            // to ensure immediate visual consistency with user preferences.
            ZStack {
                RootView()
                if showSplash {
                    SplashOverlay()
                        .transition(.opacity)
                }
            }
                .preferredColorScheme(theme.preferredColorScheme)
                // What: Bind SwiftUI tint to the theme accent.
                // Why: Ensures SwiftUI controls (e.g., segmented controls) adopt the accent immediately.
                .tint(AppColors.accent)
                .background(AppColors.background.ignoresSafeArea())
                .environment(\.themeToken, selectedThemeId)
                .onAppear {
                    // Fade out the splash overlay shortly after first frame
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeOut(duration: 0.25)) { showSplash = false }
                    }
                    // Apply themed appearances at launch
                    // Tab bar appearance
                    let tabAppearance = UITabBarAppearance()
                    tabAppearance.configureWithDefaultBackground()
                    tabAppearance.backgroundColor = UIColor(AppColors.background)
                    tabAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    UITabBar.appearance().standardAppearance = tabAppearance
                    UITabBar.appearance().scrollEdgeAppearance = tabAppearance
                    UITabBar.appearance().tintColor = UIColor(AppColors.accent)
                    UITabBar.appearance().unselectedItemTintColor = UIColor(AppColors.textSecondary)

                    // Navigation bar appearance
                    let navAppearance = UINavigationBarAppearance()
                    navAppearance.configureWithDefaultBackground()
                    navAppearance.backgroundColor = UIColor(AppColors.background)
                    navAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    navAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textSecondary)]
                    navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.textSecondary)]
                    UINavigationBar.appearance().standardAppearance = navAppearance
                    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
                    UINavigationBar.appearance().tintColor = UIColor(AppColors.accent)

                    // Global control tint (UIKit hosting).
                    // What: Use themed accent instead of system tint.
                    // Why: Some UIKit elements cache tint on creation; this sets a consistent baseline.
                    UIView.appearance().tintColor = UIColor(AppColors.accent)
                    // Ensure calendar header arrow buttons adopt accent
                    UIButton.appearance(whenContainedInInstancesOf: [UICalendarView.self]).tintColor = UIColor(AppColors.accent)

                    // UITableView / Cell backgrounds for SwiftUI List(.plain)
                    UITableView.appearance().backgroundColor = UIColor(AppColors.secondaryBackground)
                    UITableViewCell.appearance().backgroundColor = UIColor(AppColors.secondaryBackground)

                    // Segmented control (used in Collection view toggle)
                    // What: Use accent for selected segment, white text for selected, primary for normal.
                    // Why: Keeps selection visible across themes and avoids system blue.
                    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(AppColors.accent)
                    UISegmentedControl.appearance().setTitleTextAttributes([
                        .foregroundColor: UIColor(AppColors.brandWhite)
                    ], for: .selected)
                    UISegmentedControl.appearance().setTitleTextAttributes([
                        .foregroundColor: UIColor(AppColors.textPrimary)
                    ], for: .normal)

                    // Common button/bar button tint
                    UIBarButtonItem.appearance().tintColor = UIColor(AppColors.accent)
                    UIButton.appearance().tintColor = UIColor(AppColors.accent)
                    // Calendar labels inside UICalendarView should inherit theme text color
                    UILabel.appearance(whenContainedInInstancesOf: [UICalendarView.self]).textColor = UIColor(AppColors.textPrimary)
                }
                .onChange(of: selectedThemeId) { _, _ in
                    // Reapply appearance proxies on theme changes
                    let tabAppearance = UITabBarAppearance()
                    tabAppearance.configureWithDefaultBackground()
                    tabAppearance.backgroundColor = UIColor(AppColors.background)
                    tabAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    UITabBar.appearance().standardAppearance = tabAppearance
                    UITabBar.appearance().scrollEdgeAppearance = tabAppearance
                    UITabBar.appearance().tintColor = UIColor(AppColors.accent)
                    UITabBar.appearance().unselectedItemTintColor = UIColor(AppColors.textSecondary)

                    let navAppearance = UINavigationBarAppearance()
                    navAppearance.configureWithDefaultBackground()
                    navAppearance.backgroundColor = UIColor(AppColors.background)
                    navAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    navAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textSecondary)]
                    navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.textSecondary)]
                    UINavigationBar.appearance().standardAppearance = navAppearance
                    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
                    UINavigationBar.appearance().tintColor = UIColor(AppColors.accent)

                    // Re-assert global and calendar-contained button tint to reflect new theme.
                    UIView.appearance().tintColor = UIColor(AppColors.accent)
                    UIButton.appearance(whenContainedInInstancesOf: [UICalendarView.self]).tintColor = UIColor(AppColors.accent)
                    // Keep segmented control selected tint in sync with theme accent on changes
                    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(AppColors.accent)
                    UISegmentedControl.appearance().setTitleTextAttributes([
                        .foregroundColor: UIColor(AppColors.brandWhite)
                    ], for: .selected)
                    UISegmentedControl.appearance().setTitleTextAttributes([
                        .foregroundColor: UIColor(AppColors.textPrimary)
                    ], for: .normal)

                    // Reapply List backgrounds on theme change
                    UITableView.appearance().backgroundColor = UIColor(AppColors.secondaryBackground)
                    UITableViewCell.appearance().backgroundColor = UIColor(AppColors.secondaryBackground)
                    UILabel.appearance(whenContainedInInstancesOf: [UICalendarView.self]).textColor = UIColor(AppColors.textPrimary)
                    // Environment token is bound at the scene; view-level `.id(themeToken)` handles SwiftUI refresh.
                }
        }
    }
}


/// A lightweight, theme-driven splash overlay shown briefly on app launch.
/// Uses the user's saved theme: primary background and secondary text color.
private struct SplashOverlay: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 8) {
                Text(Brand.appDisplayName)
                    .font(AppTypography.titleCompact)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .accessibilityIdentifier("SplashOverlay")
    }
}


