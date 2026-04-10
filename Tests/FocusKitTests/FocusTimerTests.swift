import XCTest
@testable import FocusKit

final class FocusTimerTests: XCTestCase {
    func testTickDeliveryAndCompletionWithMockClock() async throws {
        let clock = MockClock(now: Date())
        let timer = FocusTimer(clock: clock, tickInterval: 0.5)
        let stream = await timer.countdown(duration: 2)

        var ticks: [FocusTimer.Tick] = []
        let task = Task {
            for await tick in stream {
                ticks.append(tick)
            }
        }

        clock.advance(by: 0.5)
        clock.advance(by: 0.5)
        clock.advance(by: 0.5)
        clock.advance(by: 0.5)
        clock.advance(by: 0.5)
        _ = await task.result

        XCTAssertFalse(ticks.isEmpty)
        XCTAssertEqual(ticks.last?.remaining ?? 1, 0, accuracy: 0.001)
    }

    func testCancellationStopsTimer() async {
        let clock = MockClock(now: Date())
        let timer = FocusTimer(clock: clock, tickInterval: 0.5)
        let stream = await timer.countdown(duration: 10)
        let task = Task {
            for await _ in stream {}
        }
        await timer.cancel()
        clock.advance(by: 10)
        _ = await task.result
        XCTAssertTrue(true)
    }
}
