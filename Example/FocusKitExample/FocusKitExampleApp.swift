import SwiftUI
import FocusKit

@main
struct FocusKitExampleApp: App {
    @State private var store = FocusKit.makeStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
