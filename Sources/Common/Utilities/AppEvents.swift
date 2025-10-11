import Foundation

/// Centralized notification names used across the app.
/// - What: A single source of truth for `Notification.Name`s that are posted and observed
///         by various screens (e.g., collection reloads after edits or deletes).
/// - Why: Avoids stringly-typed event names scattered across the codebase and reduces
///         typos or mismatches between publishers and subscribers.
/// - How: Expose static constants on an enum namespace, so usage reads as
///         `AppNotification.watchUpserted`.
public enum AppNotification {
    public static let watchUpserted = Notification.Name("watchUpserted")
    public static let watchDeleted = Notification.Name("watchDeleted")
}
