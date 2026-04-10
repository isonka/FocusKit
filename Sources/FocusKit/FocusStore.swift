import Foundation
import Observation

/// The high-level phase currently represented by `FocusStore`.
public enum FocusPhase: String, Sendable, Equatable {
    /// No active timer.
    case idle
    /// Active work interval.
    case working
    /// Active short break interval.
    case onShortBreak
    /// Active long break interval.
    case onLongBreak
    /// Temporarily paused interval.
    case paused
    /// A cycle completed and is waiting to start the next one.
    case finished
}

/// Observable state container and action interface for SwiftUI.
@MainActor
@Observable
public final class FocusStore {
    /// Current focus phase.
    public private(set) var phase: FocusPhase
    /// Remaining time in the active phase in seconds.
    public private(set) var remaining: TimeInterval
    /// Progress between `0` and `1`.
    public private(set) var progress: Double
    /// Number of completed work sessions in current scheduler state.
    public private(set) var completedWorkSessions: Int
    /// Current cycle number.
    public private(set) var currentCycle: Int
    /// Runtime behavior and durations.
    public var configuration: FocusConfiguration

    private var scheduler: FocusScheduler
    private let timer: FocusTimer
    private var tickTask: Task<Void, Never>?
    private var activeSession: FocusSession?
    private var historyStore: [FocusSession]
    private var pausedRemaining: TimeInterval?

    /// Creates a new store for managing focus sessions.
    public init(
        configuration: FocusConfiguration = .default,
        history: [FocusSession] = []
    ) {
        self.configuration = configuration
        self.scheduler = FocusScheduler()
        self.timer = FocusTimer()
        self.historyStore = history
        self.phase = .idle
        self.remaining = configuration.workDuration
        self.progress = 0
        self.completedWorkSessions = 0
        self.currentCycle = 1
    }

    init(
        configuration: FocusConfiguration,
        scheduler: FocusScheduler,
        timer: FocusTimer,
        history: [FocusSession]
    ) {
        self.configuration = configuration
        self.scheduler = scheduler
        self.timer = timer
        self.historyStore = history
        self.phase = .idle
        self.remaining = configuration.workDuration
        self.progress = 0
        self.completedWorkSessions = 0
        self.currentCycle = 1
    }

    /// Starts a new session sequence or resumes from idle.
    public func start() async throws {
        try configuration.validate()
        guard phase == .idle || phase == .finished else {
            throw FocusError.sessionAlreadyActive
        }
        let next = scheduler.nextPhase(after: activeSession?.type, configuration: configuration)
        begin(phasePlan: next)
    }

    /// Pauses the active countdown and preserves remaining time.
    public func pause() {
        guard phase == .working || phase == .onShortBreak || phase == .onLongBreak else { return }
        pausedRemaining = remaining
        phase = .paused
        tickTask?.cancel()
        Task { await timer.cancel() }
    }

    /// Resumes a paused countdown.
    public func resume() async throws {
        guard phase == .paused else { throw FocusError.notPaused }
        guard let pausedRemaining else { throw FocusError.noActiveSession }
        guard let session = activeSession else { throw FocusError.noActiveSession }
        let resumedPhase: FocusPhase
        switch session.type {
        case .work: resumedPhase = .working
        case .shortBreak: resumedPhase = .onShortBreak
        case .longBreak: resumedPhase = .onLongBreak
        }
        phase = resumedPhase
        runTimer(duration: pausedRemaining, sessionType: session.type)
    }

    /// Skips the active phase and transitions to the next one.
    public func skip() async throws {
        guard phase != .idle else { throw FocusError.noActiveSession }
        finishActiveSession(fullyCompleted: false)
        let next = scheduler.nextPhase(after: activeSession?.type, configuration: configuration)
        if configuration.autoStartNext {
            begin(phasePlan: next)
        } else {
            phase = .finished
            remaining = 0
            progress = 1
        }
    }

    /// Stops the current phase and stores partial history when available.
    public func stop() {
        tickTask?.cancel()
        Task { await timer.cancel() }
        finishActiveSession(fullyCompleted: false)
        phase = .idle
        remaining = configuration.workDuration
        progress = 0
        pausedRemaining = nil
    }

    /// Resets runtime state and clears in-memory history.
    public func reset() {
        stop()
        scheduler.reset()
        completedWorkSessions = 0
        currentCycle = 1
        historyStore.removeAll()
    }

    /// Returns sessions started on the same day as `date`.
    public func history(for date: Date) -> [FocusSession] {
        let calendar = Calendar.current
        return historyStore.filter { calendar.isDate($0.startedAt, inSameDayAs: date) }
    }

    /// Returns aggregate statistics for the provided date range.
    public func statistics(for range: ClosedRange<Date>) -> FocusStatistics {
        FocusStatistics.build(from: historyStore, in: range)
    }

    private func begin(phasePlan: FocusScheduler.PlannedPhase) {
        phase = phasePlan.phase
        progress = 0
        remaining = phasePlan.duration
        pausedRemaining = nil
        activeSession = FocusSession(type: phasePlan.sessionType, startedAt: Date(), endedAt: nil, completedFully: false)
        runTimer(duration: phasePlan.duration, sessionType: phasePlan.sessionType)
        completedWorkSessions = scheduler.completedWorkSessions
        currentCycle = scheduler.currentCycle
    }

    private func runTimer(duration: TimeInterval, sessionType: FocusSession.SessionType) {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            guard let self else { return }
            let stream = await timer.countdown(duration: duration)
            var lastPublishedSecond = -1
            for await tick in stream {
                guard !Task.isCancelled else { break }
                let second = Int(tick.remaining.rounded(.down))
                if second != lastPublishedSecond {
                    remaining = tick.remaining
                    progress = tick.progress
                    lastPublishedSecond = second
                }
            }
            if remaining <= 0 {
                finishActiveSession(fullyCompleted: true)
                let next = scheduler.nextPhase(after: sessionType, configuration: configuration)
                completedWorkSessions = scheduler.completedWorkSessions
                currentCycle = scheduler.currentCycle
                if configuration.autoStartNext {
                    begin(phasePlan: next)
                } else {
                    phase = .finished
                }
            }
        }
    }

    private func finishActiveSession(fullyCompleted: Bool) {
        guard var session = activeSession else { return }
        session.endedAt = Date()
        session.completedFully = fullyCompleted
        historyStore.append(session)
        activeSession = session
    }
}
