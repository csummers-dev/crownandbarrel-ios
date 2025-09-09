import SwiftUI

/// Typography tokens used across the app.
/// - What: Standardized font styles for titles, headings, body, and captions.
/// - Why: Encourages consistent hierarchy and readability.
/// - How: Wrap SwiftUI `Font` with descriptive names; change in one place if needed.

public enum AppTypography {
    public static let title = Font.system(.title2, design: .rounded).weight(.semibold)
    public static let heading = Font.system(.headline, design: .rounded)
    public static let body = Font.system(.body)
    public static let caption = Font.system(.caption)
}


