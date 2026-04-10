import Foundation

/// A single focus-related interval, such as work or break.
public struct FocusSession: Sendable, Identifiable, Codable, Equatable {
    /// Unique session identifier.
    public let id: UUID
    /// Session type (work, short break, long break).
    public let type: SessionType
    /// Session start timestamp.
    public let startedAt: Date
    /// Session end timestamp, if ended.
    public var endedAt: Date?
    /// Whether this session completed the full scheduled duration.
    public var completedFully: Bool

    /// Available focus interval types.
    public enum SessionType: String, Sendable, Codable, CaseIterable {
        /// A work interval.
        case work
        /// A short break interval.
        case shortBreak
        /// A long break interval.
        case longBreak
    }

    /// Creates a new focus session.
    public init(
        id: UUID = UUID(),
        type: SessionType,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        completedFully: Bool = false
    ) {
        self.id = id
        self.type = type
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.completedFully = completedFully
    }

    /// Session duration in seconds when ended, otherwise `nil`.
    public var duration: TimeInterval? {
        guard let end = endedAt else { return nil }
        return end.timeIntervalSince(startedAt)
    }
}
