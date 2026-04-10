import Foundation

/// Aggregate metrics computed from historical focus sessions.
public struct FocusStatistics: Sendable, Equatable {
    /// Number of work sessions started.
    public let totalWorkSessions: Int
    /// Total fully-completed work time in seconds.
    public let totalFocusTime: TimeInterval
    /// Highest number of consecutive days with at least one work session.
    public let longestStreak: Int
    /// Current consecutive-day streak ending on the latest day in range.
    public let currentStreak: Int
    /// Average work sessions per day across days represented in the range.
    public let averageSessionsPerDay: Double
    /// Fraction of fully completed work sessions among started work sessions.
    public let completionRate: Double

    /// Creates aggregate statistics from a list of sessions in a date range.
    public static func build(from sessions: [FocusSession], in range: ClosedRange<Date>) -> FocusStatistics {
        let workSessions = sessions.filter {
            $0.type == .work &&
            range.contains($0.startedAt)
        }

        let totalWorkSessions = workSessions.count
        let totalFocusTime = workSessions
            .filter(\.completedFully)
            .compactMap(\.duration)
            .reduce(0, +)
        let completionRate = totalWorkSessions == 0 ? 0 : Double(workSessions.filter(\.completedFully).count) / Double(totalWorkSessions)
        let days = max(1, Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day ?? 0)
        let averageSessionsPerDay = Double(totalWorkSessions) / Double(days)
        let streaks = calculateStreaks(workSessions.map(\.startedAt))

        return FocusStatistics(
            totalWorkSessions: totalWorkSessions,
            totalFocusTime: totalFocusTime,
            longestStreak: streaks.longest,
            currentStreak: streaks.current,
            averageSessionsPerDay: averageSessionsPerDay,
            completionRate: completionRate
        )
    }

    private static func calculateStreaks(_ dates: [Date]) -> (longest: Int, current: Int) {
        let calendar = Calendar.current
        let uniqueDays = Set(dates.compactMap { calendar.startOfDay(for: $0) }).sorted()
        guard !uniqueDays.isEmpty else { return (0, 0) }

        var longest = 1
        var currentRun = 1

        for index in 1..<uniqueDays.count {
            guard let previousPlusOne = calendar.date(byAdding: .day, value: 1, to: uniqueDays[index - 1]) else { continue }
            if calendar.isDate(uniqueDays[index], inSameDayAs: previousPlusOne) {
                currentRun += 1
            } else {
                longest = max(longest, currentRun)
                currentRun = 1
            }
        }
        longest = max(longest, currentRun)
        return (longest, currentRun)
    }
}
