import SwiftUI
import FocusKit

struct ContentView: View {
    @Bindable var store: FocusStore

    var body: some View {
        VStack(spacing: 16) {
            Text("FocusKit Example")
                .font(.title2.weight(.semibold))

            Text("Phase: \(store.phase.rawValue)")
                .font(.headline)

            Text(timeString(store.remaining))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()

            ProgressView(value: store.progress)
                .tint(.blue)

            HStack(spacing: 12) {
                Button("Start") {
                    Task { try? await store.start() }
                }
                .buttonStyle(.borderedProminent)

                Button("Pause") {
                    store.pause()
                }
                .buttonStyle(.bordered)

                Button("Resume") {
                    Task { try? await store.resume() }
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                Button("Skip") {
                    Task { try? await store.skip() }
                }
                .buttonStyle(.bordered)

                Button("Stop") {
                    store.stop()
                }
                .buttonStyle(.bordered)
            }

            Text("Completed work sessions: \(store.completedWorkSessions)")
                .foregroundStyle(.secondary)

            Text("Cycle: \(store.currentCycle)")
                .foregroundStyle(.secondary)
        }
        .padding(24)
    }

    private func timeString(_ value: TimeInterval) -> String {
        let total = max(0, Int(value.rounded()))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
