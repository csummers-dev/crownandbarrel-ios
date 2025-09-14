import XCTest
import SwiftUI
@testable import CrownAndBarrel

/// Unit-level checks for the Settings Appearance header composition.
/// - What: Asserts the "Appearance" title is rendered as a table cell (not a native header),
///         and that the inline theme picker sits closely under it.
/// - Why: Prevent regressions where UIKit grouped headers leak system background colors or
///         where the inline picker collapses when wrapped.
/// - How: Embed `SettingsView` in a `UIHostingController`, traverse UIKit hierarchy to
///         locate cells and measure the vertical gap between the header cell and the first
///         theme row ("Theme").
final class SettingsViewTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Ensure a known theme is active for deterministic backgrounds/spacing.
        UserDefaults.standard.set("dark-default", forKey: "selectedThemeId")
    }

    func testAppearanceHeaderIsCellAndGapIsTight() {
        // Build the view under test
        let root = NavigationStack { SettingsView() }
        let host = UIHostingController(rootView: root)
        // Load view hierarchy and mount into a window to ensure UIKit containers are realized on CI
        _ = host.view
        host.view.frame = UIScreen.main.bounds
        host.view.layoutIfNeeded()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = host
        window.makeKeyAndVisible()
        addTeardownBlock { [weak window] in window?.isHidden = true }

        // Allow the run loop to process layout passes SwiftUI may schedule
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))

        // Locate the UITableView or UICollectionView backing the Form (iOS versions differ)
        let table = findSubview(ofType: UITableView.self, in: host.view)
        let collection = findSubview(ofType: UICollectionView.self, in: host.view)
        guard table != nil || collection != nil else {
            XCTFail("Backed Form UITableView/UICollectionView not found")
            return
        }

        // Find the cell that contains the "Appearance" label
        guard let appearanceCell = (table != nil ? findCell(containingText: "Appearance", in: table!) : findCellInCollection(containingText: "Appearance", in: collection!)) else {
            XCTFail("Appearance header cell not found")
            return
        }

        // Ensure the label is not rendered inside a UITableViewHeaderFooterView
        let headerAncestor = findAncestor(of: appearanceCell, ofType: UITableViewHeaderFooterView.self)
        XCTAssertNil(headerAncestor, "Appearance should be a custom row, not a grouped header")

        // Find the first theme title row ("Theme")
        guard let themeCell = (table != nil ? findCell(containingText: "Theme", in: table!) : findCellInCollection(containingText: "Theme", in: collection!)) else {
            XCTFail("Theme row cell not found")
            return
        }

        // Measure vertical gap between the bottom of the header cell and top of the theme cell
        let headerFrame = appearanceCell.convert(appearanceCell.bounds, to: host.view)
        let themeFrame = themeCell.convert(themeCell.bounds, to: host.view)
        let gap = themeFrame.minY - headerFrame.maxY

        // Heuristic threshold: the custom header uses tight spacing; expect < 24pt
        XCTAssertLessThan(gap, 24.0, "Gap between Appearance header and Theme row should be tight (<24pt), got \(gap)")
    }

    // MARK: - Helpers
    private func findSubview<T: UIView>(ofType: T.Type, in root: UIView) -> T? {
        if let view = root as? T { return view }
        for sub in root.subviews { if let found: T = findSubview(ofType: ofType, in: sub) { return found } }
        return nil
    }

    private func findCellInCollection(containingText text: String, in collection: UICollectionView) -> UICollectionViewCell? {
        collection.layoutIfNeeded()
        for section in 0..<collection.numberOfSections {
            for item in 0..<collection.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                if let cell = collection.cellForItem(at: indexPath) ?? collection.dataSource?.collectionView(collection, cellForItemAt: indexPath) {
                    if containsLabel(withText: text, in: cell.contentView) { return cell }
                }
            }
        }
        for cell in collection.visibleCells { if containsLabel(withText: text, in: cell.contentView) { return cell } }
        return nil
    }

    private func findCell(containingText text: String, in table: UITableView) -> UITableViewCell? {
        // Ask the table to layout cells
        table.layoutIfNeeded()
        for section in 0..<table.numberOfSections {
            for row in 0..<table.numberOfRows(inSection: section) {
                if let cell = table.cellForRow(at: IndexPath(row: row, section: section)) ?? table.dataSource?.tableView(table, cellForRowAt: IndexPath(row: row, section: section)) {
                    if containsLabel(withText: text, in: cell.contentView) { return cell }
                }
            }
        }
        // Fallback: scan visible cells
        for cell in table.visibleCells { if containsLabel(withText: text, in: cell.contentView) { return cell } }
        return nil
    }

    private func containsLabel(withText text: String, in view: UIView) -> Bool {
        if let label = view as? UILabel, label.text == text { return true }
        for sub in view.subviews { if containsLabel(withText: text, in: sub) { return true } }
        return false
    }

    private func findAncestor<T: UIView>(of view: UIView, ofType: T.Type) -> T? {
        var parent = view.superview
        while let p = parent {
            if let match = p as? T { return match }
            parent = p.superview
        }
        return nil
    }
}


