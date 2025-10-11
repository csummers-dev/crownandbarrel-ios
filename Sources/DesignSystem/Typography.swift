import SwiftUI

/// Typography system for Crown & Barrel watch collection app.
/// 
/// **Design Philosophy:**
/// Combines serif elegance for branding with sans-serif clarity for content.
/// 
/// **Usage:**
/// - **Serif fonts**: Navigation titles, watch manufacturer names, headings
/// - **Sans-serif fonts**: Body text, captions, general UI elements

public enum AppTypography {
    // MARK: - Navigation & Branding

    /// Serif font for navigation titles and primary branding.
    /// Used for: Navigation bar titles, app branding, primary headers
    public static let titleCompact = Font.system(size: 20, weight: .medium, design: .serif)

    // MARK: - Content Hierarchy

    /// Serif headings for important sections and content.
    /// Used for: Section headers, important content titles
    public static let heading = Font.system(.headline, design: .serif, weight: .medium)

    /// Sans-serif captions for secondary information and metadata.
    /// Used for: Timestamps, secondary info, small labels
    public static let caption = Font.system(.caption, design: .default, weight: .medium)

    // MARK: - Luxury Elements

    /// Serif font for watch manufacturer names and luxury content.
    /// Used for: Watch manufacturer names, premium content highlights
    public static let luxury = Font.system(size: 18, weight: .medium, design: .serif)
}
