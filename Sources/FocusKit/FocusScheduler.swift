import Foundation

/// Determines the next focus phase and duration in a Pomodoro-style cycle.
public struct FocusScheduler: Sendable {
    /// A planned phase with concrete runtime details.
    public struct PlannedPhase: Sendable, Equatable {
        /// The resulting store phase.
        public let phase: FocusPhase
        /// The corresponding session type.
        public let sessionType: FocusSession.SessionType
        /// The target duration in seconds.
        public let duration: TimeInterval
    }

    private(set) var completedWorkSessions: Int = 0
    private(set) var currentCycle: Int = 1

    /// Creates a scheduler with a clean cycle state.
    public init() {}

    /// Resets all counters to initial values.
    public mutating func reset() {
        completedWorkSessions = 0
        currentCycle = 1
    }

    /// Returns the next planned phase based on the previous one.
    public mutating func nextPhase(
        after current: FocusSession.SessionType?,
        configuration: FocusConfiguration
    ) -> PlannedPhase {
        switch current {
        case nil, .shortBreak, .longBreak:
            return PlannedPhase(phase: .working, sessionType: .work, duration: configuration.workDuration)
        case .work:
            completedWorkSessions += 1
            if completedWorkSessions % configuration.sessionsBeforeLongBreak == 0 {
                currentCycle += 1
                return PlannedPhase(
                    phase: .onLongBreak,
                    sessionType: .longBreak,
                    duration: configuration.longBreakDuration
                )
            }
            return PlannedPhase(
                phase: .onShortBreak,
                sessionType: .shortBreak,
                duration: configuration.shortBreakDuration
            )
        }
    }
}
