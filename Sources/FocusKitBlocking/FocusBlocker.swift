import FocusKit
import Foundation
import ManagedSettings

/// Shields selected apps/categories in response to focus state changes.
@MainActor
public final class FocusBlocker {
    private let store: FocusStore
    private var configuration: BlockingConfiguration
    private let authorizationCenter: FocusAuthorizationCenter
    private let managedSettingsStore: ManagedSettingsStore
    private var observerTask: Task<Void, Never>?

    /// Creates a blocker attached to a `FocusStore`.
    public init(store: FocusStore, configuration: BlockingConfiguration) {
        self.store = store
        self.configuration = configuration
        self.authorizationCenter = FocusAuthorizationCenter()
        self.managedSettingsStore = ManagedSettingsStore()
    }

    /// Requests FamilyControls authorization in `.individual` mode.
    public func requestAuthorization() async throws {
        try await authorizationCenter.requestAuthorization()
    }

    /// Starts observing focus state and applying/removing shields.
    public func attach() async {
        observerTask?.cancel()
        observerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                applyShieldsIfNeeded(for: store.phase)
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }

    /// Stops observation and clears all active shields.
    public func detach() {
        observerTask?.cancel()
        observerTask = nil
        removeAllShields()
    }

    private func applyShieldsIfNeeded(for phase: FocusPhase) {
        switch phase {
        case .working:
            applyShields()
        case .onShortBreak, .onLongBreak:
            if configuration.blockDuringBreaks {
                applyShields()
            } else {
                removeAllShields()
            }
        case .idle, .paused, .finished:
            removeAllShields()
        }
    }

    private func applyShields() {
        managedSettingsStore.shield.applications = configuration.selection.applicationTokens
        managedSettingsStore.shield.applicationCategories = .specific(configuration.selection.categoryTokens)
    }

    private func removeAllShields() {
        managedSettingsStore.clearAllSettings()
    }
}
