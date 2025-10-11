@testable import CrownAndBarrel
import XCTest

/// Tests for DateFormatters utility to verify date formatting logic.
final class DateFormattersTests: XCTestCase {

    // MARK: - Smart Format Tests

    func testSmartFormatSwitchesRelativeAndAbsolute() throws {
        let calendar = Calendar.current
        let now = Date()

        // Recent dates (< 7 days) should use relative format
        XCTAssertEqual(DateFormatters.smartFormat(now, relativeTo: now), "Today")
        XCTAssertEqual(DateFormatters.smartFormat(calendar.date(byAdding: .day, value: -1, to: now)!, relativeTo: now), "Yesterday")
        XCTAssertEqual(DateFormatters.smartFormat(calendar.date(byAdding: .day, value: -3, to: now)!, relativeTo: now), "3 days ago")

        // Older dates (>= 7 days) should use absolute format
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let result = DateFormatters.smartFormat(sevenDaysAgo, relativeTo: now)
        XCTAssertFalse(result.contains("days ago"), "Should use absolute format for dates >= 7 days old")
    }

    // MARK: - Relative Format Tests

    func testRelativeFormatAllScenarios() throws {
        let calendar = Calendar.current
        let now = Date()

        // Past dates
        XCTAssertEqual(DateFormatters.relativeFormat(now, relativeTo: now), "Today")
        XCTAssertEqual(DateFormatters.relativeFormat(calendar.date(byAdding: .day, value: -1, to: now)!, relativeTo: now), "Yesterday")
        XCTAssertEqual(DateFormatters.relativeFormat(calendar.date(byAdding: .day, value: -3, to: now)!, relativeTo: now), "3 days ago")

        // Future dates
        XCTAssertEqual(DateFormatters.relativeFormat(calendar.date(byAdding: .day, value: 1, to: now)!, relativeTo: now), "Tomorrow")
        XCTAssertEqual(DateFormatters.relativeFormat(calendar.date(byAdding: .day, value: 3, to: now)!, relativeTo: now), "In 3 days")
    }

    // MARK: - Absolute Format Tests

    func testAbsoluteFormatStyles() throws {
        let dateComponents = DateComponents(year: 2_025, month: 1, day: 15)
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create test date")
            return
        }

        // All formats should work and contain date info
        let medium = DateFormatters.absoluteFormat(date, style: .medium)
        let short = DateFormatters.shortFormat(date)
        let long = DateFormatters.longFormat(date)

        XCTAssertFalse(medium.isEmpty)
        XCTAssertFalse(short.isEmpty)
        XCTAssertTrue(long.contains("2025"), "Long format should contain year")
    }

    // MARK: - Specialized Format Tests

    func testSpecializedFormats() throws {
        let dateComponents = DateComponents(year: 2_025, month: 1, day: 15)
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create test date")
            return
        }

        // Month/year formats
        let monthYear = DateFormatters.monthYearFormat(date, abbreviated: false)
        let monthYearAbbr = DateFormatters.monthYearFormat(date, abbreviated: true)
        let year = DateFormatters.yearFormat(date)

        XCTAssertTrue(monthYear.contains("2025"), "Should contain year")
        XCTAssertTrue(monthYearAbbr.contains("Jan"), "Should contain abbreviated month")
        XCTAssertEqual(year, "2025")
    }

    // MARK: - Duration Format Tests

    func testDurationFormatting() throws {
        let calendar = Calendar.current
        let now = Date()

        // Years
        XCTAssertEqual(DateFormatters.durationFormat(from: calendar.date(byAdding: .year, value: -2, to: now)!, to: now), "2 years")
        XCTAssertEqual(DateFormatters.durationFormat(from: calendar.date(byAdding: .year, value: -1, to: now)!, to: now), "1 year")

        // Months
        XCTAssertEqual(DateFormatters.durationFormat(from: calendar.date(byAdding: .month, value: -3, to: now)!, to: now), "3 months")
        XCTAssertEqual(DateFormatters.durationFormat(from: calendar.date(byAdding: .month, value: -1, to: now)!, to: now), "1 month")

        // Days
        XCTAssertEqual(DateFormatters.durationFormat(from: calendar.date(byAdding: .day, value: -5, to: now)!, to: now), "5 days")
        XCTAssertEqual(DateFormatters.durationFormat(from: calendar.date(byAdding: .day, value: -1, to: now)!, to: now), "1 day")

        // Same day
        XCTAssertEqual(DateFormatters.durationFormat(from: now, to: now), "Today")
    }

    // MARK: - Days Between Tests

    func testDaysBetween() throws {
        let calendar = Calendar.current
        let now = Date()

        XCTAssertEqual(DateFormatters.daysBetween(from: calendar.date(byAdding: .day, value: -10, to: now)!, to: now), 10)
        XCTAssertEqual(DateFormatters.daysBetween(from: now, to: now), 0)
        XCTAssertEqual(DateFormatters.daysBetween(from: now, to: calendar.date(byAdding: .day, value: 5, to: now)!), 5)
    }
}
