import XCTest
@testable import FocusKit

final class FocusSessionTests: XCTestCase {
    func testDurationCalculation() {
        let start = Date()
        let end = start.addingTimeInterval(60)
        let session = FocusSession(type: .work, startedAt: start, endedAt: end, completedFully: true)
        XCTAssertEqual(session.duration, 60, accuracy: 0.001)
    }

    func testDurationNilWhenOngoing() {
        let session = FocusSession(type: .shortBreak)
        XCTAssertNil(session.duration)
    }

    func testCodableRoundTrip() throws {
        let original = FocusSession(type: .longBreak, completedFully: false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FocusSession.self, from: data)
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.type, decoded.type)
    }
}
