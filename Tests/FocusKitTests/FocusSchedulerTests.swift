import XCTest
@testable import FocusKit

final class FocusSchedulerTests: XCTestCase {
    func testCycleProgressionWorkShortBreakLongBreak() {
        var scheduler = FocusScheduler()
        let config = FocusConfiguration(
            workDuration: 10,
            shortBreakDuration: 3,
            longBreakDuration: 8,
            sessionsBeforeLongBreak: 2,
            autoStartNext: false,
            notificationsEnabled: true
        )

        let first = scheduler.nextPhase(after: nil, configuration: config)
        XCTAssertEqual(first.sessionType, .work)

        let second = scheduler.nextPhase(after: .work, configuration: config)
        XCTAssertEqual(second.sessionType, .shortBreak)

        let third = scheduler.nextPhase(after: .shortBreak, configuration: config)
        XCTAssertEqual(third.sessionType, .work)

        let fourth = scheduler.nextPhase(after: .work, configuration: config)
        XCTAssertEqual(fourth.sessionType, .longBreak)
    }

    func testAutoStartConfigurationValueRetained() {
        let config = FocusConfiguration(autoStartNext: true, notificationsEnabled: true)
        XCTAssertTrue(config.autoStartNext)
    }
}
