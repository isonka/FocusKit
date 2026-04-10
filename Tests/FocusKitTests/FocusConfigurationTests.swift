import XCTest
@testable import FocusKit

final class FocusConfigurationTests: XCTestCase {
    func testDefaultValues() {
        let config = FocusConfiguration.default
        XCTAssertEqual(config.workDuration, 25 * 60)
        XCTAssertEqual(config.shortBreakDuration, 5 * 60)
        XCTAssertEqual(config.longBreakDuration, 15 * 60)
        XCTAssertEqual(config.sessionsBeforeLongBreak, 4)
        XCTAssertFalse(config.autoStartNext)
        XCTAssertTrue(config.notificationsEnabled)
    }

    func testCodableRoundTrip() throws {
        let original = FocusConfiguration.default
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FocusConfiguration.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testValidationFailsForInvalidDurations() throws {
        let invalid = FocusConfiguration(
            workDuration: 0,
            shortBreakDuration: -1,
            longBreakDuration: 0,
            sessionsBeforeLongBreak: 0,
            autoStartNext: false,
            notificationsEnabled: true
        )
        XCTAssertThrowsError(try invalid.validate())
        XCTAssertFalse(invalid.validationErrors().isEmpty)
    }
}
