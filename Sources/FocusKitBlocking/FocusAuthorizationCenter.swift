import FamilyControls
import Foundation

/// Wrapper around FamilyControls authorization APIs.
@MainActor
public struct FocusAuthorizationCenter: Sendable {
    /// Creates an authorization wrapper.
    public init() {}

    /// Requests FamilyControls authorization in `.individual` mode.
    public func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }
}
