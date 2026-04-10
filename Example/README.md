# FocusKit Example App

This folder contains a minimal SwiftUI example app that demonstrates using `FocusKit` in an iOS app target.

## Structure

- `FocusKitExample/FocusKitExampleApp.swift` - app entry point
- `FocusKitExample/ContentView.swift` - simple controls and live session status

## Open in Xcode

1. In Xcode, create a new iOS App project named `FocusKitExample` in this folder.
2. Replace generated app and content files with the provided files.
3. Add local package dependency:
   - File -> Add Package Dependencies... -> Add Local...
   - Choose the repository root (`FocusKit`).
4. Link product `FocusKit` to the app target.
5. Build and run on iOS 17+ simulator/device.

`FocusKitBlocking` is intentionally not used in this example since it requires Screen Time entitlement and device-side setup.
