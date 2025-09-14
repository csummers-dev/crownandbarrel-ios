import SwiftUI
import UIKit

/// Centralized UIAppearance configuration for themed UI.
/// - What: Applies tab bar, navigation bar, list/collection backgrounds, and common tints.
/// - Why: Prevents system defaults (separators, system backgrounds) from bleeding into themed views.
/// - How: Configure UIAppearance proxies once at launch and re-apply on theme changes.
enum Appearance {
    static func applyAllAppearances() {
        applyTabBarAppearance()
        applyNavigationBarAppearance()
        applyListAndCollectionAppearance()
        applyControlTints()
    }

    private static func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.background)
        appearance.shadowColor = UIColor(AppColors.tabBarHairline)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = UIColor(AppColors.accent)
        UITabBar.appearance().unselectedItemTintColor = UIColor(AppColors.textSecondary)
    }

    private static func applyNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.background)
        appearance.shadowColor = UIColor(AppColors.tabBarHairline)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
        let backItemAppearance = UIBarButtonItemAppearance()
        let hiddenTitleAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
        backItemAppearance.normal.titleTextAttributes = hiddenTitleAttrs
        backItemAppearance.highlighted.titleTextAttributes = hiddenTitleAttrs
        backItemAppearance.disabled.titleTextAttributes = hiddenTitleAttrs
        backItemAppearance.focused.titleTextAttributes = hiddenTitleAttrs
        appearance.backButtonAppearance = backItemAppearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(AppColors.accent)
    }

    private static func applyListAndCollectionAppearance() {
        // Ensure window base background matches theme to avoid flashes or stale system color
        UIWindow.appearance().backgroundColor = UIColor(AppColors.background)
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UIScrollView.appearance(whenContainedInInstancesOf: [UITableView.self]).backgroundColor = .clear
        // Keep header/footers clear here; Settings applies a scoped override while visible
        UITableViewHeaderFooterView.appearance().tintColor = .clear
        UITableViewHeaderFooterView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().separatorInset = .zero
        UITableView.appearance().separatorInsetReference = .fromCellEdges
        UITableView.appearance().separatorEffect = nil
        UITableView.appearance().tableFooterView = UIView(frame: .zero)

        UICollectionView.appearance().backgroundColor = .clear
        UICollectionViewCell.appearance().backgroundColor = .clear
    }

    private static func applyControlTints() {
        UIView.appearance().tintColor = UIColor(AppColors.accent)
        UIButton.appearance(whenContainedInInstancesOf: [UICalendarView.self]).tintColor = UIColor(AppColors.accent)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(AppColors.accent)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(AppColors.brandWhite)
        ], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(AppColors.textPrimary)
        ], for: .normal)
        UIBarButtonItem.appearance().tintColor = UIColor(AppColors.accent)
        UIButton.appearance().tintColor = UIColor(AppColors.accent)
        UILabel.appearance(whenContainedInInstancesOf: [UICalendarView.self]).textColor = UIColor(AppColors.textPrimary)
    }

    /// Applies updated appearances directly to any visible UINavigationBar/UITabBar instances.
    /// - Why: UIAppearance proxies do not always propagate to already-present bars; assigning
    ///        appearances on live instances ensures immediate visual updates on theme change.
    static func refreshVisibleBars() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(AppColors.background)
        navAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(AppColors.background)
        tabAppearance.shadowColor = UIColor(AppColors.tabBarHairline)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                func applyRecursively(_ view: UIView) {
                    if let navBar = view as? UINavigationBar {
                        navBar.standardAppearance = navAppearance
                        navBar.scrollEdgeAppearance = navAppearance
                        navBar.setNeedsLayout(); navBar.layoutIfNeeded()
                    } else if let tabBar = view as? UITabBar {
                        tabBar.standardAppearance = tabAppearance
                        tabBar.scrollEdgeAppearance = tabAppearance
                        tabBar.tintColor = UIColor(AppColors.accent)
                        tabBar.unselectedItemTintColor = UIColor(AppColors.textSecondary)
                        tabBar.setNeedsLayout(); tabBar.layoutIfNeeded()
                    }
                    for sub in view.subviews { applyRecursively(sub) }
                }
                applyRecursively(window)
                window.setNeedsLayout(); window.layoutIfNeeded()
            }
        }
    }
}

/// The main application entry point.
/// - What: Composes the root window and applies the theme (light/dark/system) via a small theme manager.
/// - Why: Centralized control of color scheme and scene lifecycle makes system-wide behavior (e.g., iOS 17 full-screen behavior) predictable.
/// - How: SwiftUI `App` creates a `WindowGroup` hosting `RootView`. The theme manager maps persisted preference to a `ColorScheme?`.

@main
struct CrownAndBarrelApp: App {
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
                    Appearance.applyAllAppearances()
                    #if DEBUG
                    // What: Allow UI tests to pin a specific theme via launch argument.
                    // Why: Ensures we can deterministically validate dark vs light cards and containers.
                    // How: Pass e.g. "--uiTestTheme=dark-default" in UITest launch configuration.
                    if let themeArg = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--uiTestTheme=") })?.split(separator: "=").last {
                        UserDefaults.standard.set(String(themeArg), forKey: "selectedThemeId")
                    }
                    #endif
                    // Tab bar appearance
                    let tabAppearance = UITabBarAppearance()
                    tabAppearance.configureWithOpaqueBackground()
                    tabAppearance.backgroundColor = UIColor(AppColors.background)
                    tabAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    UITabBar.appearance().standardAppearance = tabAppearance
                    UITabBar.appearance().scrollEdgeAppearance = tabAppearance
                    UITabBar.appearance().tintColor = UIColor(AppColors.accent)
                    UITabBar.appearance().unselectedItemTintColor = UIColor(AppColors.textSecondary)

                    // Navigation bar appearance
                    let navAppearance = UINavigationBarAppearance()
                    navAppearance.configureWithOpaqueBackground()
                    navAppearance.backgroundColor = UIColor(AppColors.background)
                    navAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    navAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
                    navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
                    // Hide back button titles globally (chevron only)
                    let backItemAppearance = UIBarButtonItemAppearance()
                    let hiddenTitleAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
                    backItemAppearance.normal.titleTextAttributes = hiddenTitleAttrs
                    backItemAppearance.highlighted.titleTextAttributes = hiddenTitleAttrs
                    backItemAppearance.disabled.titleTextAttributes = hiddenTitleAttrs
                    backItemAppearance.focused.titleTextAttributes = hiddenTitleAttrs
                    navAppearance.backButtonAppearance = backItemAppearance
                    UINavigationBar.appearance().standardAppearance = navAppearance
                    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
                    UINavigationBar.appearance().tintColor = UIColor(AppColors.accent)

                    // Global control tint (UIKit hosting).
                    // What: Use themed accent instead of system tint.
                    // Why: Some UIKit elements cache tint on creation; this sets a consistent baseline.
                    UIView.appearance().tintColor = UIColor(AppColors.accent)
                    // Ensure calendar header arrow buttons adopt accent
                    UIButton.appearance(whenContainedInInstancesOf: [UICalendarView.self]).tintColor = UIColor(AppColors.accent)

                    // UITableView / Cell / contained scroll backgrounds for SwiftUI List(.plain)
                    // Default clear so screens can supply themed backgrounds.
                    UITableView.appearance().backgroundColor = .clear
                    UITableViewCell.appearance().backgroundColor = .clear
                    UIScrollView.appearance(whenContainedInInstancesOf: [UITableView.self]).backgroundColor = .clear
                    UITableViewHeaderFooterView.appearance().tintColor = .clear
                    UITableViewHeaderFooterView.appearance().backgroundColor = .clear

                    // UICollectionView backgrounds cleared so screens can supply themed backgrounds.
                    UICollectionView.appearance().backgroundColor = .clear
                    UICollectionViewCell.appearance().backgroundColor = .clear
                    // Remove default hairline separators for visual clarity in custom-styled lists
                    UITableView.appearance().separatorStyle = .none
                    UITableView.appearance().separatorColor = .clear
                    UITableView.appearance().separatorInset = .zero
                    UITableView.appearance().separatorInsetReference = .fromCellEdges
                    UITableView.appearance().separatorEffect = nil
                    UITableView.appearance().tableFooterView = UIView(frame: .zero)

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
                    // Reapply appearance proxies on theme changes and refresh visible bars
                    Appearance.applyAllAppearances()
                    Appearance.refreshVisibleBars()
                    let tabAppearance = UITabBarAppearance()
                    tabAppearance.configureWithOpaqueBackground()
                    tabAppearance.backgroundColor = UIColor(AppColors.background)
                    tabAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    UITabBar.appearance().standardAppearance = tabAppearance
                    UITabBar.appearance().scrollEdgeAppearance = tabAppearance
                    UITabBar.appearance().tintColor = UIColor(AppColors.accent)
                    UITabBar.appearance().unselectedItemTintColor = UIColor(AppColors.textSecondary)

                    let navAppearance = UINavigationBarAppearance()
                    navAppearance.configureWithOpaqueBackground()
                    navAppearance.backgroundColor = UIColor(AppColors.background)
                    navAppearance.shadowColor = UIColor(AppColors.tabBarHairline)
                    navAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
                    navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
                    let backItemAppearance = UIBarButtonItemAppearance()
                    let hiddenTitleAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
                    backItemAppearance.normal.titleTextAttributes = hiddenTitleAttrs
                    backItemAppearance.highlighted.titleTextAttributes = hiddenTitleAttrs
                    backItemAppearance.disabled.titleTextAttributes = hiddenTitleAttrs
                    backItemAppearance.focused.titleTextAttributes = hiddenTitleAttrs
                    navAppearance.backButtonAppearance = backItemAppearance
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

                    // Reapply List backgrounds on theme change and ensure separators stay hidden
                    UITableView.appearance().backgroundColor = .clear
                    UITableViewCell.appearance().backgroundColor = .clear
                    UIScrollView.appearance(whenContainedInInstancesOf: [UITableView.self]).backgroundColor = .clear
                    UITableViewHeaderFooterView.appearance().tintColor = .clear
                    UITableViewHeaderFooterView.appearance().backgroundColor = .clear
                    UICollectionView.appearance().backgroundColor = .clear
                    UICollectionViewCell.appearance().backgroundColor = .clear
                    UITableView.appearance().separatorStyle = .none
                    UITableView.appearance().separatorColor = .clear
                    UITableView.appearance().separatorInset = .zero
                    UITableView.appearance().separatorInsetReference = .fromCellEdges
                    UITableView.appearance().separatorEffect = nil
                    UITableView.appearance().tableFooterView = UIView(frame: .zero)
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


