import Foundation

/// Domain-specific errors used by FocusKit.
public enum FocusError: LocalizedError, Sendable, Equatable {
    /// The active configuration is invalid.
    case invalidConfiguration(String)
    /// An operation was requested while no session was active.
    case noActiveSession
    /// A start operation was requested while a session is already active.
    case sessionAlreadyActive
    /// A pause operation was requested while the session is not running.
    case notRunning
    /// A resume operation was requested while the session is not paused.
    case notPaused
}

public extension FocusError {
    /// A localized message describing the current error.
    var errorDescription: String? {
        switch self {
        case let .invalidConfiguration(message):
            return "Invalid focus configuration: \(message)"
        case .noActiveSession:
            return "No active focus session."
        case .sessionAlreadyActive:
            return "A focus session is already active."
        case .notRunning:
            return "The current session is not running."
        case .notPaused:
            return "The current session is not paused."
        }
    }
}
