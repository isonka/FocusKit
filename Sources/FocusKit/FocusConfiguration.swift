import Foundation

/// Configuration values that define focus and break cycle behavior.
public struct FocusConfiguration: Sendable, Codable, Equatable {
    /// Work interval duration in seconds. Default: 25 minutes.
    public var workDuration: TimeInterval
    /// Short break duration in seconds. Default: 5 minutes.
    public var shortBreakDuration: TimeInterval
    /// Long break duration in seconds. Default: 15 minutes.
    public var longBreakDuration: TimeInterval
    /// Number of work sessions before a long break. Default: 4.
    public var sessionsBeforeLongBreak: Int
    /// Automatically start the next phase after finishing the current one.
    public var autoStartNext: Bool
    /// Whether transition notifications are enabled.
    public var notificationsEnabled: Bool

    /// The default Pomodoro-style configuration.
    public static let `default` = FocusConfiguration(
        workDuration: 25 * 60,
        shortBreakDuration: 5 * 60,
        longBreakDuration: 15 * 60,
        sessionsBeforeLongBreak: 4,
        autoStartNext: false,
        notificationsEnabled: true
    )

    /// Creates a custom configuration.
    public init(
        workDuration: TimeInterval = FocusConfiguration.default.workDuration,
        shortBreakDuration: TimeInterval = FocusConfiguration.default.shortBreakDuration,
        longBreakDuration: TimeInterval = FocusConfiguration.default.longBreakDuration,
        sessionsBeforeLongBreak: Int = FocusConfiguration.default.sessionsBeforeLongBreak,
        autoStartNext: Bool = FocusConfiguration.default.autoStartNext,
        notificationsEnabled: Bool = FocusConfiguration.default.notificationsEnabled
    ) {
        self.workDuration = workDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.sessionsBeforeLongBreak = sessionsBeforeLongBreak
        self.autoStartNext = autoStartNext
        self.notificationsEnabled = notificationsEnabled
    }

    /// Returns validation errors, or an empty array when valid.
    public func validationErrors() -> [String] {
        var errors: [String] = []
        if workDuration <= 0 { errors.append("workDuration must be greater than 0.") }
        if shortBreakDuration <= 0 { errors.append("shortBreakDuration must be greater than 0.") }
        if longBreakDuration <= 0 { errors.append("longBreakDuration must be greater than 0.") }
        if sessionsBeforeLongBreak < 1 { errors.append("sessionsBeforeLongBreak must be at least 1.") }
        return errors
    }

    /// Throws when this configuration is invalid.
    public func validate() throws {
        let errors = validationErrors()
        guard errors.isEmpty else {
            throw FocusError.invalidConfiguration(errors.joined(separator: " "))
        }
    }
}
