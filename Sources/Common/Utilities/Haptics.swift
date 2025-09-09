import UIKit

/// Lightweight haptic helpers for user feedback.
/// - What: One-liners for common feedback patterns (success, selection, error).
/// - Why: Improves perceived responsiveness and delight on supported devices.
/// - How: Uses UIFeedbackGenerator variants with sensible defaults.
public enum Haptics {
    public static func success() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    public static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
    public static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}


