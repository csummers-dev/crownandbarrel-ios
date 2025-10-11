import Foundation

/// Centralized date formatting utilities for consistent date displays across the app.
/// - What: Provides relative and absolute date formatting with smart switching logic.
/// - Why: Ensures consistent date presentation matching user expectations (e.g., "3 days ago" vs "Jan 15, 2025").
/// - How: Uses Calendar and DateFormatter with locale-aware formatting and relative date calculations.
public enum DateFormatters {
    
    // MARK: - Smart Formatting (Relative/Absolute)
    
    /// Formats a date using relative format for recent dates (< 7 days) and absolute format for older dates.
    /// - Parameters:
    ///   - date: The date to format
    ///   - referenceDate: The date to compare against (default: now)
    ///   - calendar: Calendar to use for calculations (default: .current)
    /// - Returns: Formatted string like "3 days ago", "Yesterday", or "Jan 15, 2025"
    /// - Note: Per PRD recommendation: relative for < 7 days, absolute for older dates
    public static func smartFormat(
        _ date: Date,
        relativeTo referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        let daysDifference = calendar.dateComponents([.day], from: date, to: referenceDate).day ?? 0
        
        // Use relative format for dates within the last 7 days
        if daysDifference >= 0 && daysDifference < 7 {
            return relativeFormat(date, relativeTo: referenceDate, calendar: calendar)
        } else {
            return absoluteFormat(date)
        }
    }
    
    // MARK: - Relative Formatting
    
    /// Formats a date as a relative string (e.g., "Today", "Yesterday", "3 days ago").
    /// - Parameters:
    ///   - date: The date to format
    ///   - referenceDate: The date to compare against (default: now)
    ///   - calendar: Calendar to use for calculations (default: .current)
    /// - Returns: Relative date string
    public static func relativeFormat(
        _ date: Date,
        relativeTo referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        let startOfDate = calendar.startOfDay(for: date)
        let startOfReference = calendar.startOfDay(for: referenceDate)
        let daysDifference = calendar.dateComponents([.day], from: startOfDate, to: startOfReference).day ?? 0
        
        switch daysDifference {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        case 2...6:
            return "\(daysDifference) days ago"
        case -1:
            return "Tomorrow"
        case -6 ... -2:
            return "In \(abs(daysDifference)) days"
        default:
            // Fallback to absolute for dates > 7 days
            return absoluteFormat(date)
        }
    }
    
    // MARK: - Absolute Formatting
    
    /// Formats a date as an absolute date string (e.g., "Jan 15, 2025").
    /// - Parameters:
    ///   - date: The date to format
    ///   - style: The date style to use (default: .medium)
    ///   - locale: The locale for formatting (default: .current)
    /// - Returns: Formatted absolute date string
    public static func absoluteFormat(
        _ date: Date,
        style: DateFormatter.Style = .medium,
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Formats a date as a short absolute date string (e.g., "1/15/25").
    /// - Parameters:
    ///   - date: The date to format
    ///   - locale: The locale for formatting (default: .current)
    /// - Returns: Short formatted date string
    public static func shortFormat(
        _ date: Date,
        locale: Locale = .current
    ) -> String {
        return absoluteFormat(date, style: .short, locale: locale)
    }
    
    /// Formats a date as a long absolute date string (e.g., "January 15, 2025").
    /// - Parameters:
    ///   - date: The date to format
    ///   - locale: The locale for formatting (default: .current)
    /// - Returns: Long formatted date string
    public static func longFormat(
        _ date: Date,
        locale: Locale = .current
    ) -> String {
        return absoluteFormat(date, style: .long, locale: locale)
    }
    
    // MARK: - Specialized Formatting
    
    /// Formats a date showing only the month and year (e.g., "January 2025", "Mar 2023").
    /// - Parameters:
    ///   - date: The date to format
    ///   - abbreviated: Whether to abbreviate month name (default: false)
    ///   - locale: The locale for formatting (default: .current)
    /// - Returns: Month and year string
    public static func monthYearFormat(
        _ date: Date,
        abbreviated: Bool = false,
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = abbreviated ? "MMM yyyy" : "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    /// Formats a date showing only the year (e.g., "2025").
    /// - Parameters:
    ///   - date: The date to format
    ///   - locale: The locale for formatting (default: .current)
    /// - Returns: Year string
    public static func yearFormat(
        _ date: Date,
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Duration Formatting
    
    /// Calculates and formats the duration between two dates (e.g., "3 months", "2 years").
    /// - Parameters:
    ///   - startDate: The start date
    ///   - endDate: The end date (default: now)
    ///   - calendar: Calendar to use for calculations (default: .current)
    /// - Returns: Human-readable duration string
    public static func durationFormat(
        from startDate: Date,
        to endDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: startDate, to: endDate)
        
        if let years = components.year, years > 0 {
            return years == 1 ? "1 year" : "\(years) years"
        } else if let months = components.month, months > 0 {
            return months == 1 ? "1 month" : "\(months) months"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1 day" : "\(days) days"
        } else {
            return "Today"
        }
    }
    
    /// Calculates total days between two dates.
    /// - Parameters:
    ///   - startDate: The start date
    ///   - endDate: The end date (default: now)
    ///   - calendar: Calendar to use for calculations (default: .current)
    /// - Returns: Number of days between dates
    public static func daysBetween(
        from startDate: Date,
        to endDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
}

