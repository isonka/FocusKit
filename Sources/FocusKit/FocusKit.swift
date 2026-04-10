import Foundation

/// Public facade for constructing `FocusStore` instances.
public enum FocusKit: Sendable {
    /// Creates a `FocusStore` with an optional custom configuration.
    @MainActor
    public static func makeStore(configuration: FocusConfiguration = .default) -> FocusStore {
        FocusStore(configuration: configuration)
    }
}
