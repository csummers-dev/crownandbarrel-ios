import XCTest
@testable import CrownAndBarrel

/// Tests for DateFormatters utility to verify date formatting logic.
final class DateFormattersTests: XCTestCase {
    
    // MARK: - Smart Format Tests
    
    func testSmartFormatUsesRelativeForRecentDates() throws {
        let calendar = Calendar.current
        let now = Date()
        
        // Today
        let today = calendar.startOfDay(for: now)
        XCTAssertEqual(DateFormatters.smartFormat(today, relativeTo: now), "Today")
        
        // Yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        XCTAssertEqual(DateFormatters.smartFormat(yesterday, relativeTo: now), "Yesterday")
        
        // 3 days ago
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        XCTAssertEqual(DateFormatters.smartFormat(threeDaysAgo, relativeTo: now), "3 days ago")
        
        // 6 days ago (still relative)
        let sixDaysAgo = calendar.date(byAdding: .day, value: -6, to: now)!
        XCTAssertEqual(DateFormatters.smartFormat(sixDaysAgo, relativeTo: now), "6 days ago")
    }
    
    func testSmartFormatUsesAbsoluteForOlderDates() throws {
        let calendar = Calendar.current
        let now = Date()
        
        // 7 days ago (should be absolute)
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let result = DateFormatters.smartFormat(sevenDaysAgo, relativeTo: now)
        XCTAssertFalse(result.contains("days ago"), "Should use absolute format for dates >= 7 days old")
        XCTAssertFalse(result == "Today", "Should not show as Today")
        
        // 30 days ago
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        let result30 = DateFormatters.smartFormat(thirtyDaysAgo, relativeTo: now)
        XCTAssertFalse(result30.contains("days ago"), "Should use absolute format for dates >= 7 days old")
    }
    
    // MARK: - Relative Format Tests
    
    func testRelativeFormatToday() throws {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        XCTAssertEqual(DateFormatters.relativeFormat(today, relativeTo: now), "Today")
    }
    
    func testRelativeFormatYesterday() throws {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        
        XCTAssertEqual(DateFormatters.relativeFormat(yesterday, relativeTo: now), "Yesterday")
    }
    
    func testRelativeFormatMultipleDaysAgo() throws {
        let calendar = Calendar.current
        let now = Date()
        
        for days in 2...6 {
            let date = calendar.date(byAdding: .day, value: -days, to: now)!
            let expected = "\(days) days ago"
            XCTAssertEqual(DateFormatters.relativeFormat(date, relativeTo: now), expected)
        }
    }
    
    func testRelativeFormatTomorrow() throws {
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        
        XCTAssertEqual(DateFormatters.relativeFormat(tomorrow, relativeTo: now), "Tomorrow")
    }
    
    func testRelativeFormatFutureDays() throws {
        let calendar = Calendar.current
        let now = Date()
        
        for days in 2...6 {
            let date = calendar.date(byAdding: .day, value: days, to: now)!
            let expected = "In \(days) days"
            XCTAssertEqual(DateFormatters.relativeFormat(date, relativeTo: now), expected)
        }
    }
    
    // MARK: - Absolute Format Tests
    
    func testAbsoluteFormatMediumStyle() throws {
        let dateComponents = DateComponents(year: 2025, month: 1, day: 15)
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create test date")
            return
        }
        
        let result = DateFormatters.absoluteFormat(date, style: .medium)
        // Result will be locale-dependent, but should contain the date components
        XCTAssertTrue(result.contains("15") || result.contains("2025"), "Should contain date components")
    }
    
    func testShortFormat() throws {
        let dateComponents = DateComponents(year: 2025, month: 1, day: 15)
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create test date")
            return
        }
        
        let result = DateFormatters.shortFormat(date)
        XCTAssertFalse(result.isEmpty, "Short format should return non-empty string")
    }
    
    func testLongFormat() throws {
        let dateComponents = DateComponents(year: 2025, month: 1, day: 15)
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create test date")
            return
        }
        
        let result = DateFormatters.longFormat(date)
        XCTAssertTrue(result.contains("2025"), "Long format should contain year")
    }
    
    // MARK: - Month/Year Format Tests
    
    func testMonthYearFormat() throws {
        let dateComponents = DateComponents(year: 2025, month: 1, day: 15)
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create test date")
            return
        }
        
        let result = DateFormatters.monthYearFormat(date, abbreviated: false)
        XCTAssertTrue(result.contains("2025"), "Should contain year")
        XCTAssertTrue(result.contains("January") || result.contains("Jan"), "Should contain month")
    }
    
    func testMonthYearFormatAbbreviated() throws {
        let dateComponents = DateComponents(year: 2025, month: 1, day: 15)
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create test date")
            return
        }
        
        let result = DateFormatters.monthYearFormat(date, abbreviated: true)
        XCTAssertTrue(result.contains("2025"), "Should contain year")
        XCTAssertTrue(result.contains("Jan"), "Should contain abbreviated month")
    }
    
    func testYearFormat() throws {
        let dateComponents = DateComponents(year: 2025, month: 1, day: 15)
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create test date")
            return
        }
        
        let result = DateFormatters.yearFormat(date)
        XCTAssertEqual(result, "2025")
    }
    
    // MARK: - Duration Format Tests
    
    func testDurationFormatYears() throws {
        let calendar = Calendar.current
        let now = Date()
        let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: now)!
        
        let result = DateFormatters.durationFormat(from: twoYearsAgo, to: now)
        XCTAssertEqual(result, "2 years")
    }
    
    func testDurationFormatSingleYear() throws {
        let calendar = Calendar.current
        let now = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
        
        let result = DateFormatters.durationFormat(from: oneYearAgo, to: now)
        XCTAssertEqual(result, "1 year")
    }
    
    func testDurationFormatMonths() throws {
        let calendar = Calendar.current
        let now = Date()
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)!
        
        let result = DateFormatters.durationFormat(from: threeMonthsAgo, to: now)
        XCTAssertEqual(result, "3 months")
    }
    
    func testDurationFormatSingleMonth() throws {
        let calendar = Calendar.current
        let now = Date()
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        
        let result = DateFormatters.durationFormat(from: oneMonthAgo, to: now)
        XCTAssertEqual(result, "1 month")
    }
    
    func testDurationFormatDays() throws {
        let calendar = Calendar.current
        let now = Date()
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now)!
        
        let result = DateFormatters.durationFormat(from: fiveDaysAgo, to: now)
        XCTAssertEqual(result, "5 days")
    }
    
    func testDurationFormatSingleDay() throws {
        let calendar = Calendar.current
        let now = Date()
        let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: now)!
        
        let result = DateFormatters.durationFormat(from: oneDayAgo, to: now)
        XCTAssertEqual(result, "1 day")
    }
    
    func testDurationFormatToday() throws {
        let now = Date()
        let result = DateFormatters.durationFormat(from: now, to: now)
        XCTAssertEqual(result, "Today")
    }
    
    // MARK: - Days Between Tests
    
    func testDaysBetween() throws {
        let calendar = Calendar.current
        let now = Date()
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: now)!
        
        let result = DateFormatters.daysBetween(from: tenDaysAgo, to: now)
        XCTAssertEqual(result, 10)
    }
    
    func testDaysBetweenSameDay() throws {
        let now = Date()
        let result = DateFormatters.daysBetween(from: now, to: now)
        XCTAssertEqual(result, 0)
    }
    
    func testDaysBetweenFuture() throws {
        let calendar = Calendar.current
        let now = Date()
        let fiveDaysFromNow = calendar.date(byAdding: .day, value: 5, to: now)!
        
        let result = DateFormatters.daysBetween(from: now, to: fiveDaysFromNow)
        XCTAssertEqual(result, 5)
    }
}

