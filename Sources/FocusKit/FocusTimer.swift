import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// A clock abstraction used by `FocusTimer` to support deterministic tests.
protocol FocusClockProtocol: Sendable {
    /// Suspends for the given number of nanoseconds.
    func sleep(nanoseconds: UInt64) async throws
    /// The current wall-clock time.
    var now: Date { get }
}

/// Production clock based on real time.
struct SystemClock: FocusClockProtocol {
    var now: Date { Date() }

    func sleep(nanoseconds: UInt64) async throws {
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}

/// A test clock that advances virtual time.
final class MockClock: FocusClockProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var _now: Date
    private var sleepers: [(target: Date, continuation: CheckedContinuation<Void, Error>)] = []

    init(now: Date = Date()) {
        _now = now
    }

    var now: Date {
        lock.lock()
        defer { lock.unlock() }
        return _now
    }

    func sleep(nanoseconds: UInt64) async throws {
        let target = now.addingTimeInterval(Double(nanoseconds) / 1_000_000_000)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            lock.lock()
            sleepers.append((target: target, continuation: continuation))
            lock.unlock()
        }
    }

    /// Advances virtual time and resumes completed sleepers.
    func advance(by seconds: TimeInterval) {
        lock.lock()
        _now = _now.addingTimeInterval(seconds)
        let ready = sleepers.partitioned { $0.target <= _now }
        sleepers = ready.remaining
        lock.unlock()
        ready.matched.forEach { $0.continuation.resume() }
    }
}

private extension Array {
    func partitioned(_ predicate: (Element) -> Bool) -> (matched: [Element], remaining: [Element]) {
        var matched: [Element] = []
        var remaining: [Element] = []
        for element in self {
            if predicate(element) {
                matched.append(element)
            } else {
                remaining.append(element)
            }
        }
        return (matched, remaining)
    }
}

/// Internal asynchronous countdown timer.
actor FocusTimer {
    struct Tick: Sendable {
        let remaining: TimeInterval
        let progress: Double
    }

    private let clock: FocusClockProtocol
    private let tickInterval: TimeInterval
    private var countdownTask: Task<Void, Never>?
    #if canImport(UIKit)
    private var backgroundedAt: Date?
    #endif

    init(clock: FocusClockProtocol = SystemClock(), tickInterval: TimeInterval = 0.5) {
        self.clock = clock
        self.tickInterval = tickInterval
    }

    func cancel() {
        countdownTask?.cancel()
        countdownTask = nil
    }

    func countdown(duration: TimeInterval) -> AsyncStream<Tick> {
        cancel()
        return AsyncStream { continuation in
            countdownTask = Task { [weak self, clock, tickInterval] in
                guard let self else {
                    continuation.finish()
                    return
                }
                let start = clock.now
                await self.setBackgroundedAt(nil)
                #if canImport(UIKit)
                let center = NotificationCenter.default
                let bgObserver = center.addObserver(
                    forName: UIApplication.willResignActiveNotification,
                    object: nil,
                    queue: nil
                ) { [weak self] _ in
                    Task { await self?.setBackgroundedAt(clock.now) }
                }
                let fgObserver = center.addObserver(
                    forName: UIApplication.didBecomeActiveNotification,
                    object: nil,
                    queue: nil
                ) { [weak self] _ in
                    Task {
                        // Keep wall-clock progression: foreground transition only clears marker.
                        await self?.setBackgroundedAt(nil)
                    }
                }
                defer {
                    center.removeObserver(bgObserver)
                    center.removeObserver(fgObserver)
                }
                #endif

                while !Task.isCancelled {
                    let elapsed = max(0, clock.now.timeIntervalSince(start))
                    let remaining = max(0, duration - elapsed)
                    let progress = duration == 0 ? 1 : min(1, max(0, elapsed / duration))
                    continuation.yield(Tick(remaining: remaining, progress: progress))
                    if remaining <= 0 {
                        continuation.finish()
                        return
                    }
                    let nanos = UInt64(tickInterval * 1_000_000_000)
                    do {
                        try await clock.sleep(nanoseconds: nanos)
                    } catch {
                        continuation.finish()
                        return
                    }
                }
                continuation.finish()
            }
        }
    }

    #if canImport(UIKit)
    private func setBackgroundedAt(_ date: Date?) {
        backgroundedAt = date
    }
    #endif
}
