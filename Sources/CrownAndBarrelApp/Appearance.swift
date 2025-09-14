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
        // UITableView / Cell / contained scroll backgrounds for SwiftUI List(.plain)
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UIScrollView.appearance(whenContainedInInstancesOf: [UITableView.self]).backgroundColor = .clear
        UITableViewHeaderFooterView.appearance().tintColor = .clear
        UITableViewHeaderFooterView.appearance().backgroundColor = .clear
        // Remove default hairline separators for visual clarity in custom-styled lists
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().separatorInset = .zero
        UITableView.appearance().separatorInsetReference = .fromCellEdges
        UITableView.appearance().separatorEffect = nil
        UITableView.appearance().tableFooterView = UIView(frame: .zero)

        // UICollectionView backgrounds cleared so screens can supply themed backgrounds.
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
}


