import Foundation

/// Utility helpers for working with dates in a consistent manner.
/// - What: Normalization and formatting helpers used across repository and UI.
/// - Why: Centralized to avoid subtle mismatches (e.g., start-of-day differences, locale drift).
/// - How: Uses injected `Calendar`/`Locale` with sensible defaults.
public enum DateUtils {
    /// Normalizes a date to the start of the day in the current calendar and time zone.
    public static func startOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        return calendar.startOfDay(for: date)
    }

    /// Formats a date for display using a medium style.
    public static func mediumString(from date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}


