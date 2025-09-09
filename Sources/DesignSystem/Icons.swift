import SwiftUI

/// Centralized SF Symbols used across the app.
/// - What: Provides a single place to update icons.
/// - Why: Ensures consistent visual language and easy swapping.
/// - How: Expose symbol-based `Image`s suitable for SwiftUI.

public enum AppIcons {
    public static let collection = Image(systemName: "rectangle.grid.2x2")
    public static let stats = Image(systemName: "chart.bar")
    public static let calendar = Image(systemName: "calendar")
    public static let favorite = Image(systemName: "star")
    public static let favoriteFilled = Image(systemName: "star.fill")
    public static let add = Image(systemName: "plus")
    public static let watch = Image(systemName: "watch.case")
}


