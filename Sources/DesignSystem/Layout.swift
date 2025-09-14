import SwiftUI

/// Standardized layout tokens for grid/list item sizing.
/// - What: Provides named widths for grid tiles to avoid magic numbers.
/// - Why: Ensures consistent sizing and easy future adjustments.
/// - How: Reference `GridTileWidth.medium.width` in grids.
public enum GridTileWidth: CaseIterable {
    case small
    case medium
    case large

    /// The square image/container width for a grid tile.
    public var width: CGFloat {
        switch self {
        case .small: return 100
        case .medium: return 120
        case .large: return 140
        }
    }
}


