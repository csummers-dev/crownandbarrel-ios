import SwiftUI

/// Corner radius tokens for consistent curvature across the app.
/// - What: Provides a small/medium/large scale to avoid hard-coded values.
/// - Why: Centralizes control for future visual polish and ensures cohesion.
/// - How: Reference tokens instead of literals in views.
public enum AppRadius {
    public static let small: CGFloat = 8    // thumbnails, compact elements
    public static let medium: CGFloat = 10   // grid tiles and medium surfaces
    public static let large: CGFloat = 12    // list cards and prominent containers
}


