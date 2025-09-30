import Foundation

/// Service for calculating various types of streaks from wear entries.
/// - What: Provides static methods to calculate consecutive day streaks, weekend streaks,
///         and weekday streaks based on wear entry data.
/// - Why: Centralizes complex streak calculation logic that implements the PRD's streak rules,
///        where multiple watches worn on the same day count as maintaining the streak.
/// - How: Analyzes wear entries to identify consecutive calendar days, weekends, or weekdays
///        where at least one wear entry exists.
public enum StreakCalculator {
    
    /// Calculates the current consecutive days streak.
    /// - Parameter wearEntries: Array of wear entries to analyze
    /// - Returns: Number of consecutive days from today backwards where at least one wear exists
    /// - Note: Per PRD: If multiple watches are worn on the same day, it still counts as one day
    ///         toward the streak.
    public static func calculateCurrentStreak(wearEntries: [WearEntry]) -> Int {
        guard !wearEntries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        
        // Create set of unique dates (start of day) from wear entries
        var daySet = Set<Date>()
        for entry in wearEntries {
            let day = calendar.startOfDay(for: entry.date)
            daySet.insert(day)
        }
        
        // Count consecutive days from today backwards
        var streak = 0
        while daySet.contains(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }
        
        return streak
    }
    
    /// Calculates the current consecutive weekends streak.
    /// - Parameter wearEntries: Array of wear entries to analyze
    /// - Returns: Number of consecutive weekends where at least one wear exists
    /// - Note: A weekend is defined as Saturday or Sunday. Both days don't need entries,
    ///         just at least one day of the weekend.
    public static func calculateConsecutiveWeekends(from wearEntries: [WearEntry]) -> Int {
        guard !wearEntries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        
        // Create set of unique dates from wear entries
        var daySet = Set<Date>()
        for entry in wearEntries {
            let day = calendar.startOfDay(for: entry.date)
            daySet.insert(day)
        }
        
        // Start from the most recent weekend
        var currentDate = Date()
        
        // Move to the most recent weekend day (Saturday or Sunday)
        while !isWeekend(currentDate, calendar: calendar) {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                return 0
            }
            currentDate = previousDay
        }
        
        var weekendStreak = 0
        
        // Check consecutive weekends backwards
        while true {
            // Get the weekend dates (Saturday and Sunday) for this week
            let weekendDates = getWeekendDates(for: currentDate, calendar: calendar)
            
            // Check if at least one day of this weekend has a wear entry
            let hasWeekendEntry = weekendDates.contains { daySet.contains($0) }
            
            if hasWeekendEntry {
                weekendStreak += 1
                // Move to previous weekend
                guard let previousWeekend = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousWeekend
            } else {
                // Streak broken
                break
            }
        }
        
        return weekendStreak
    }
    
    /// Calculates the current consecutive weekdays streak.
    /// - Parameter wearEntries: Array of wear entries to analyze
    /// - Returns: Number of consecutive weekdays where at least one wear exists
    /// - Note: Weekdays are Monday through Friday. The streak continues even if weekends are skipped.
    public static func calculateConsecutiveWeekdays(from wearEntries: [WearEntry]) -> Int {
        guard !wearEntries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        
        // Create set of unique dates from wear entries
        var daySet = Set<Date>()
        for entry in wearEntries {
            let day = calendar.startOfDay(for: entry.date)
            daySet.insert(day)
        }
        
        // Start from today
        var currentDate = calendar.startOfDay(for: Date())
        
        // Move to the most recent weekday
        while isWeekend(currentDate, calendar: calendar) {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                return 0
            }
            currentDate = previousDay
        }
        
        var weekdayStreak = 0
        
        // Check consecutive weekdays backwards
        while true {
            // Skip weekends
            if isWeekend(currentDate, calendar: calendar) {
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
                continue
            }
            
            // Check if this weekday has a wear entry
            if daySet.contains(currentDate) {
                weekdayStreak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            } else {
                // Streak broken
                break
            }
        }
        
        return weekdayStreak
    }
    
    // MARK: - Private Helpers
    
    private static func isWeekend(_ date: Date, calendar: Calendar) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // Sunday = 1, Saturday = 7
    }
    
    private static func getWeekendDates(for date: Date, calendar: Calendar) -> [Date] {
        var weekendDates: [Date] = []
        
        // Find the Saturday of this week
        let currentDate = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: currentDate)
        
        // Move to Saturday
        if weekday == 1 { // Sunday
            // Move back to Saturday
            if let saturday = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                weekendDates.append(saturday)
            }
            weekendDates.append(currentDate)
        } else if weekday == 7 { // Saturday
            weekendDates.append(currentDate)
            if let sunday = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                weekendDates.append(sunday)
            }
        } else {
            // Not a weekend day, find the nearest previous weekend
            let daysToSaturday = (weekday + 7 - 7) % 7
            if let saturday = calendar.date(byAdding: .day, value: -daysToSaturday, to: currentDate) {
                weekendDates.append(saturday)
                if let sunday = calendar.date(byAdding: .day, value: 1, to: saturday) {
                    weekendDates.append(sunday)
                }
            }
        }
        
        return weekendDates.map { calendar.startOfDay(for: $0) }
    }
}
