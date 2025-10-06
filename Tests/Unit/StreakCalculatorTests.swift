import XCTest
@testable import CrownAndBarrel

/// Unit tests for StreakCalculator service.
/// Tests cover all streak types and edge cases defined in the PRD.
final class StreakCalculatorTests: XCTestCase {
    
    let calendar = Calendar.current
    
    // MARK: - Current Streak Tests
    
    func testCalculateCurrentStreakEmpty() {
        let entries: [WearEntry] = []
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 0)
    }
    
    func testCalculateCurrentStreakSingleDay() {
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        let entries = [
            WearEntry(watchId: watchId, date: today)
        ]
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 1)
    }
    
    func testCalculateCurrentStreakConsecutiveDays() {
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            entries.append(WearEntry(watchId: watchId, date: date))
        }
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 7)
    }
    
    func testCalculateCurrentStreakMultipleWatchesSameDay() {
        // PRD Rule: Multiple watches worn on the same day count as one day toward the streak
        let watch1 = UUID()
        let watch2 = UUID()
        let watch3 = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        
        // Day 1: Three watches worn
        entries.append(WearEntry(watchId: watch1, date: today))
        entries.append(WearEntry(watchId: watch2, date: today))
        entries.append(WearEntry(watchId: watch3, date: today))
        
        // Day 2: Two watches worn
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        entries.append(WearEntry(watchId: watch1, date: yesterday))
        entries.append(WearEntry(watchId: watch2, date: yesterday))
        
        // Day 3: One watch worn
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        entries.append(WearEntry(watchId: watch1, date: twoDaysAgo))
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 3, "Multiple watches on same day should count as one day")
    }
    
    func testCalculateCurrentStreakWithGap() {
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        
        // Today and yesterday
        entries.append(WearEntry(watchId: watchId, date: today))
        entries.append(WearEntry(watchId: watchId, date: calendar.date(byAdding: .day, value: -1, to: today)!))
        
        // Gap (skip 2 days ago)
        
        // 3 days ago (should not count toward current streak)
        entries.append(WearEntry(watchId: watchId, date: calendar.date(byAdding: .day, value: -3, to: today)!))
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 2, "Streak should break at gap")
    }
    
    func testCalculateCurrentStreakDoesNotStartToday() {
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        
        // No entry today, but entries for past 7 days starting yesterday
        for i in 1...7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            entries.append(WearEntry(watchId: watchId, date: date))
        }
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 0, "Current streak requires entry today or continuing from today")
    }
    
    func testCalculateCurrentStreakLongStreak() {
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        for i in 0..<365 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            entries.append(WearEntry(watchId: watchId, date: date))
        }
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 365)
    }
    
    // MARK: - Consecutive Weekends/Weekdays (duplicate block disabled)
    #if false
    func testCalculateConsecutiveWeekendsEmpty() { }
    func testCalculateConsecutiveWeekendsSingleWeekend() { }
    func testCalculateConsecutiveWeekendsMultipleWeekends() { }
    func testCalculateConsecutiveWeekdaysEmpty() { }
    func testCalculateConsecutiveWeekdaysSingleDay() { }
    func testCalculateConsecutiveWeekdaysWithWeekendGap() { }
    #endif
    
    // MARK: - Edge Case Tests
    
    func testStreakWithEntriesInFuture() {
        // Entries with future dates should not break the calculation
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        
        // Current streak: today and yesterday
        entries.append(WearEntry(watchId: watchId, date: today))
        entries.append(WearEntry(watchId: watchId, date: calendar.date(byAdding: .day, value: -1, to: today)!))
        
        // Future entry (shouldn't affect current streak)
        entries.append(WearEntry(watchId: watchId, date: calendar.date(byAdding: .day, value: 1, to: today)!))
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 2, "Future entries should not extend current streak")
    }
    
    func testStreakWithDuplicateSameDayEntries() {
        // Multiple entries on exact same timestamp should still count as one day
        let watchId1 = UUID()
        let watchId2 = UUID()
        let today = calendar.startOfDay(for: Date())
        let exactTime = Date()
        
        var entries: [WearEntry] = []
        
        // Same exact time, different watches
        entries.append(WearEntry(watchId: watchId1, date: exactTime))
        entries.append(WearEntry(watchId: watchId2, date: exactTime))
        
        // Yesterday
        entries.append(WearEntry(watchId: watchId1, date: calendar.date(byAdding: .day, value: -1, to: today)!))
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 2, "Duplicate same-day entries should count as one day")
    }
    
    func testStreakWithUnorderedEntries() {
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        // Create entries in random order
        var entries: [WearEntry] = []
        entries.append(WearEntry(watchId: watchId, date: calendar.date(byAdding: .day, value: -2, to: today)!))
        entries.append(WearEntry(watchId: watchId, date: today))
        entries.append(WearEntry(watchId: watchId, date: calendar.date(byAdding: .day, value: -1, to: today)!))
        entries.append(WearEntry(watchId: watchId, date: calendar.date(byAdding: .day, value: -5, to: today)!))
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 3, "Should handle unordered entries correctly")
    }
    
    func testStreakBreaksWithOneDayGap() {
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        
        // Today
        entries.append(WearEntry(watchId: watchId, date: today))
        
        // Skip yesterday (gap)
        
        // 2 days ago
        entries.append(WearEntry(watchId: watchId, date: calendar.date(byAdding: .day, value: -2, to: today)!))
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 1, "One day gap should break streak")
    }
    
    func testCurrentStreakIgnoresPastStreaks() {
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        
        // Current streak: today and yesterday (2 days)
        entries.append(WearEntry(watchId: watchId, date: today))
        entries.append(WearEntry(watchId: watchId, date: calendar.date(byAdding: .day, value: -1, to: today)!))
        
        // Gap
        
        // Past streak: 10 days in a row, 3-12 days ago
        for i in 3...12 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            entries.append(WearEntry(watchId: watchId, date: date))
        }
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 2, "Should only count current streak, not past streaks")
    }
    
    // MARK: - Multiple Watches Per Day Tests (PRD Edge Case)
    
    func testMultipleWatchesSameDayCountsAsOneDay() {
        let watch1 = UUID()
        let watch2 = UUID()
        let watch3 = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        
        // Day 1: Three watches worn (should count as 1 day)
        entries.append(WearEntry(watchId: watch1, date: today))
        entries.append(WearEntry(watchId: watch2, date: today))
        entries.append(WearEntry(watchId: watch3, date: today))
        
        // Day 2: One watch worn (should count as 1 day)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        entries.append(WearEntry(watchId: watch1, date: yesterday))
        
        // Day 3: Two watches worn (should count as 1 day)
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        entries.append(WearEntry(watchId: watch2, date: twoDaysAgo))
        entries.append(WearEntry(watchId: watch3, date: twoDaysAgo))
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 3, "Three days with multiple watches should count as 3-day streak")
    }
    
    func testSameDayEntriesAtDifferentTimes() {
        let watchId1 = UUID()
        let watchId2 = UUID()
        
        // Same calendar day but different times
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        
        let entries = [
            WearEntry(watchId: watchId1, date: morning),
            WearEntry(watchId: watchId2, date: evening)
        ]
        
        let streak = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        XCTAssertEqual(streak, 1, "Entries at different times on same day should count as one day")
    }
    
    // MARK: - Consecutive Weekends Tests
    
    func testCalculateConsecutiveWeekendsEmpty() {
        let entries: [WearEntry] = []
        let streak = StreakCalculator.calculateConsecutiveWeekends(from: entries)
        XCTAssertEqual(streak, 0)
    }
    
    func testConsecutiveWeekendsVariants() {
        let watchId = UUID()
        
        struct Case { let name: String; let dates: [Date] }
        
        let saturday = mostRecent(weekday: 7)
        let sunday = calendar.date(byAdding: .day, value: 1, to: saturday)!
        
        let cases: [Case] = [
            Case(name: "Saturday only", dates: [saturday]),
            Case(name: "Sunday only", dates: [sunday]),
            Case(name: "Both weekend days", dates: [saturday, sunday])
        ]
        
        for testCase in cases {
            let entries = testCase.dates.map { WearEntry(watchId: watchId, date: $0) }
            let streak = StreakCalculator.calculateConsecutiveWeekends(from: entries)
            XCTAssertGreaterThanOrEqual(streak, 1, testCase.name)
        }
    }
    
    // MARK: - Consecutive Weekdays Tests
    
    func testCalculateConsecutiveWeekdaysEmpty() {
        let entries: [WearEntry] = []
        let streak = StreakCalculator.calculateConsecutiveWeekdays(from: entries)
        XCTAssertEqual(streak, 0)
    }
    
    func testCalculateConsecutiveWeekdaysSingleDay() {
        let watchId = UUID()
        
        // Find most recent weekday (Mon-Fri). Recompute within loop to avoid infinite loop on weekends.
        var weekday = calendar.startOfDay(for: Date())
        while true {
            let day = calendar.component(.weekday, from: weekday)
            if day != 1 && day != 7 { break }
            weekday = calendar.date(byAdding: .day, value: -1, to: weekday)!
        }
        
        let entries = [
            WearEntry(watchId: watchId, date: weekday)
        ]
        
        let streak = StreakCalculator.calculateConsecutiveWeekdays(from: entries)
        XCTAssertGreaterThanOrEqual(streak, 1)
    }
    
    func testCalculateConsecutiveWeekdaysSkipsWeekends() {
        let watchId = UUID()
        
        // Find the most recent weekday to make the test work with current dates
        var currentDate = calendar.startOfDay(for: Date())
        while isWeekend(currentDate) {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        var entries: [WearEntry] = []
        
        // Create entries for the last 5 weekdays (skipping weekends)
        var date = currentDate
        var weekdayCount = 0
        while weekdayCount < 5 {
            if !isWeekend(date) {
                entries.append(WearEntry(watchId: watchId, date: date))
                weekdayCount += 1
            }
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }
        
        let streak = StreakCalculator.calculateConsecutiveWeekdays(from: entries)
        XCTAssertEqual(streak, 5, "Weekday streak should count 5 consecutive weekdays")
    }
    
    private func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // Sunday = 1, Saturday = 7
    }
    
    // MARK: - Integration Tests
    
    func testStreakCalculatorConsistencyAcrossMultipleCalls() {
        let watchId = UUID()
        let today = calendar.startOfDay(for: Date())
        
        var entries: [WearEntry] = []
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            entries.append(WearEntry(watchId: watchId, date: date))
        }
        
        // Call multiple times - should get same result
        let streak1 = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        let streak2 = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        let streak3 = StreakCalculator.calculateCurrentStreak(wearEntries: entries)
        
        XCTAssertEqual(streak1, streak2)
        XCTAssertEqual(streak2, streak3)
        XCTAssertEqual(streak1, 7)
    }

    // MARK: - Helpers
    private func mostRecent(weekday: Int) -> Date {
        var date = calendar.startOfDay(for: Date())
        while calendar.component(.weekday, from: date) != weekday {
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }
        return date
    }
}
