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
        applySearchTextFieldAppearance()
    }

    private static func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.background)
        appearance.shadowColor = UIColor(AppColors.tabBarHairline)
        
        // Configure tab bar item colors directly on the appearance object
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textSecondary)]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.accent)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.textSecondary)
        
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textSecondary)]
        appearance.inlineLayoutAppearance.selected.iconColor = UIColor(AppColors.accent)
        appearance.inlineLayoutAppearance.normal.iconColor = UIColor(AppColors.textSecondary)
        
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColors.accent)]
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textSecondary)]
        appearance.compactInlineLayoutAppearance.selected.iconColor = UIColor(AppColors.accent)
        appearance.compactInlineLayoutAppearance.normal.iconColor = UIColor(AppColors.textSecondary)
        
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
    
    private static func applySearchTextFieldAppearance() {
        // APPROACH 1: Direct search text field configuration
        UISearchBar.appearance().searchTextField.backgroundColor = UIColor(AppColors.secondaryBackground)
        UISearchBar.appearance().searchTextField.textColor = UIColor(AppColors.textPrimary)
        UISearchBar.appearance().searchTextField.tintColor = UIColor(AppColors.accent)
        
        // APPROACH 2: Direct layer styling on search text field for iOS 26.0 Liquid Glass
        UISearchBar.appearance().searchTextField.layer.backgroundColor = UIColor(AppColors.secondaryBackground).cgColor
        UISearchBar.appearance().searchTextField.layer.cornerRadius = 18.0
        UISearchBar.appearance().searchTextField.layer.masksToBounds = true
        UISearchBar.appearance().searchTextField.clipsToBounds = true

        // APPROACH 3: UITextField appearance as fallback
        let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldAppearance.backgroundColor = UIColor(AppColors.secondaryBackground)
        textFieldAppearance.textColor = UIColor(AppColors.textPrimary)
        textFieldAppearance.tintColor = UIColor(AppColors.accent)
        textFieldAppearance.layer.backgroundColor = UIColor(AppColors.secondaryBackground).cgColor
        textFieldAppearance.layer.cornerRadius = 18.0
        textFieldAppearance.layer.masksToBounds = true

        // APPROACH 4: Search bar container styling
        UISearchBar.appearance().backgroundColor = UIColor(AppColors.background)
        UISearchBar.appearance().barTintColor = UIColor(AppColors.background)
        UISearchBar.appearance().isTranslucent = false
        UISearchBar.appearance().barStyle = .default

        // APPROACH 5: Remove system background images that could override styling
        UISearchBar.appearance().setSearchFieldBackgroundImage(nil, for: .normal)
        UISearchBar.appearance().setSearchFieldBackgroundImage(nil, for: .disabled)
        UISearchBar.appearance().setSearchFieldBackgroundImage(nil, for: .highlighted)
        UISearchBar.appearance().setSearchFieldBackgroundImage(nil, for: .selected)

        // Configure placeholder text
        UISearchBar.appearance().searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(AppColors.textSecondary)]
        )
        
        // CRITICAL: Force runtime color application to prevent system default override
        DispatchQueue.main.async {
            forceSearchFieldColorRefresh()
        }
    }
    
    /// Forces search field colors to be applied at runtime while preserving Liquid Glass shape.
    /// - What: Applies theme colors to existing search fields without affecting corner radius.
    /// - Why: System defaults can override appearance-based colors, but shape is preserved.
    /// - How: Finds and updates existing UISearchBar instances with fresh theme colors.
    static func forceSearchFieldColorRefresh() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        for window in windowScene.windows {
            updateSearchFieldColors(in: window)
        }
    }
    
    /// Recursively updates search field colors in view hierarchy.
    /// - Parameter view: The root view to search for UISearchBar instances.
    private static func updateSearchFieldColors(in view: UIView) {
        if let searchBar = view as? UISearchBar {
            // Apply theme colors without affecting the perfect Liquid Glass shape
            searchBar.searchTextField.backgroundColor = UIColor(AppColors.secondaryBackground)
            searchBar.searchTextField.textColor = UIColor(AppColors.textPrimary)
            searchBar.searchTextField.tintColor = UIColor(AppColors.accent)
            
            // Ensure layer background color matches without changing corner radius
            searchBar.searchTextField.layer.backgroundColor = UIColor(AppColors.secondaryBackground).cgColor
            // DO NOT modify layer.cornerRadius here - it's already perfect at 18pt
        }
        
        // Continue recursively through all subviews
        for subview in view.subviews {
            updateSearchFieldColors(in: subview)
        }
    }
    
}

/// The main application entry point.
@main
struct CrownAndBarrelApp: App {
    private let theme = ThemeManager()
    @AppStorage("selectedThemeId") private var selectedThemeId: String = ThemeCatalog.shared.defaultThemeId
    @State private var showSplash: Bool = true

    init() {
        // On first launch, if no saved theme preference exists, choose a default
        // based on the current system appearance (light → Daytime, dark → Nighttime).
        let key = "selectedThemeId"
        if UserDefaults.standard.object(forKey: key) == nil {
            let detected = UIScreen.main.traitCollection.userInterfaceStyle
            let defaultId = ThemeManager.defaultThemeId(for: detected)
            UserDefaults.standard.set(defaultId, forKey: key)
        }
        
        // Apply initial theme setup
        Appearance.applyAllAppearances()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(theme.preferredColorScheme)
                .background(AppColors.background.ignoresSafeArea())
                .environment(\.themeToken, selectedThemeId)
                .onAppear {
                    handleAppLaunch()
                }
                .onChange(of: selectedThemeId) { _, _ in
                    handleThemeChange()
                }
                .overlay {
                    if showSplash {
                        splashOverlay
                    }
                }
        }
    }

    // MARK: - Private Methods
    
    /// Handles app launch setup including splash animation and UI appearance configuration
    private func handleAppLaunch() {
        // Fade out the splash overlay shortly after first frame
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.25)) { showSplash = false }
        }
        // Apply themed appearances at launch
        Appearance.applyAllAppearances()
    }
    
    /// Handles theme change with clean, minimal approach
    private func handleThemeChange() {
        // Single, clean appearance application
        Appearance.applyAllAppearances()
        
        // Force search field color refresh to prevent system default override
        DispatchQueue.main.async {
            Appearance.forceSearchFieldColorRefresh()
        }
        
        // SwiftUI will handle view updates via environment changes
    }

    /// Splash overlay shown during app launch
    private var splashOverlay: some View {
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
