import XCTest
@testable import FocusKit

final class FocusStatisticsTests: XCTestCase {
    func testTotalsCompletionAndStreaks() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let day1 = today.addingTimeInterval(-2 * 24 * 60 * 60)
        let day2 = today.addingTimeInterval(-1 * 24 * 60 * 60)
        let day3 = today

        let sessions = [
            FocusSession(type: .work, startedAt: day1, endedAt: day1.addingTimeInterval(1500), completedFully: true),
            FocusSession(type: .work, startedAt: day2, endedAt: day2.addingTimeInterval(1200), completedFully: false),
            FocusSession(type: .work, startedAt: day3, endedAt: day3.addingTimeInterval(1500), completedFully: true),
            FocusSession(type: .shortBreak, startedAt: day3, endedAt: day3.addingTimeInterval(300), completedFully: true),
        ]

        let range = day1...day3.addingTimeInterval(24 * 60 * 60)
        let stats = FocusStatistics.build(from: sessions, in: range)

        XCTAssertEqual(stats.totalWorkSessions, 3)
        XCTAssertEqual(stats.totalFocusTime, 3000, accuracy: 0.001)
        XCTAssertEqual(stats.longestStreak, 3)
        XCTAssertEqual(stats.currentStreak, 3)
        XCTAssertEqual(stats.completionRate, 2.0 / 3.0, accuracy: 0.0001)
    }

    func testCurrentStreakIsZeroWhenLatestSessionIsOlderThanYesterday() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let fiveDaysAgo = today.addingTimeInterval(-5 * 24 * 60 * 60)
        let fourDaysAgo = today.addingTimeInterval(-4 * 24 * 60 * 60)

        let sessions = [
            FocusSession(type: .work, startedAt: fiveDaysAgo, endedAt: fiveDaysAgo.addingTimeInterval(1500), completedFully: true),
            FocusSession(type: .work, startedAt: fourDaysAgo, endedAt: fourDaysAgo.addingTimeInterval(1500), completedFully: true),
        ]

        let range = fiveDaysAgo...today
        let stats = FocusStatistics.build(from: sessions, in: range)

        XCTAssertEqual(stats.longestStreak, 2)
        XCTAssertEqual(stats.currentStreak, 0)
    }
}
