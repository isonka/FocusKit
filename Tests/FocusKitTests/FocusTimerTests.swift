import XCTest
@testable import FocusKit

final class FocusTimerTests: XCTestCase {
    func testTickDeliveryAndCompletionWithMockClock() async throws {
        let clock = MockClock(now: Date())
        let timer = FocusTimer(clock: clock, tickInterval: 0.5)
        let stream = await timer.countdown(duration: 2)
        let recorder = TickRecorder()

        let task = Task {
            for await tick in stream {
                await recorder.append(tick)
            }
        }

        let advancer = Task {
            for _ in 0..<20 {
                clock.advance(by: 0.5)
                await Task.yield()
            }
        }

        let finished = await waitForTaskCompletion(task, timeoutNanoseconds: 1_000_000_000)
        _ = await advancer.result

        let ticks = await recorder.all()
        XCTAssertTrue(finished, "Timer stream did not complete within timeout.")
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

        let advancer = Task {
            // Keep advancing/yielding so any pending mock sleeps are unblocked.
            for _ in 0..<20 {
                clock.advance(by: 0.5)
                await Task.yield()
            }
        }

        let finished = await waitForTaskCompletion(task, timeoutNanoseconds: 1_000_000_000)
        _ = await advancer.result

        XCTAssertTrue(finished, "Cancellation did not terminate timer stream within timeout.")
    }

    private func waitForTaskCompletion(
        _ task: Task<Void, Never>,
        timeoutNanoseconds: UInt64
    ) async -> Bool {
        await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                await task.value
                return true
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: timeoutNanoseconds)
                return false
            }
            let result = await group.next() ?? false
            group.cancelAll()
            return result
        }
    }
}

private actor TickRecorder {
    private var storage: [FocusTimer.Tick] = []

    func append(_ tick: FocusTimer.Tick) {
        storage.append(tick)
    }

    func all() -> [FocusTimer.Tick] {
        storage
    }
}
