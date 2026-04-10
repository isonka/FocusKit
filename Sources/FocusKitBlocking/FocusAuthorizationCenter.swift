import FamilyControls
import Foundation

/// Wrapper around FamilyControls authorization APIs.
@MainActor
public struct FocusAuthorizationCenter: Sendable {
    private let center: AuthorizationCenter

    /// Creates an authorization wrapper.
    public init(center: AuthorizationCenter = AuthorizationCenter.shared) {
        self.center = center
    }

    /// Requests FamilyControls authorization in `.individual` mode.
    public func requestAuthorization() async throws {
        try await center.requestAuthorization(for: .individual)
    }
}
