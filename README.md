# FocusKit

[![SPI](https://img.shields.io/badge/SPI-package-blue)](#)
[![SPI DocC](https://img.shields.io/badge/SPI-DocC-blueviolet)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

FocusKit fills a common gap in the iOS ecosystem: there are many complete Pomodoro apps, but very few clean Swift packages that expose reusable focus session infrastructure.

## Architecture

```text
+--------------------------+         +-----------------------------------+
| FocusKit (Core)          |         | FocusKitBlocking (Optional)       |
| - Session lifecycle      |  --->   | - FamilyControls authorization    |
| - Scheduling/cycles      |         | - ManagedSettings shields         |
| - Timer + reconciliation |         | - Store-driven blocking behavior  |
| - History/statistics     |         |                                   |
+--------------------------+         +-----------------------------------+
 No entitlement required                 Requires Screen Time entitlement
```

## Requirements

- iOS 17+
- Swift 5.9+
- No entitlement needed for `FocusKit` core
- `FocusKitBlocking` requires FamilyControls + ManagedSettings entitlement

## Installation (SPM)

```swift
dependencies: [
    .package(url: "https://github.com/isonka/FocusKit.git", from: "0.1.0")
]
```

## Quick Start (SwiftUI)

```swift
import SwiftUI
import FocusKit

@State private var store = FocusKit.makeStore()
Task { try? await store.start() }
Text("\(Int(store.remaining))s")
```

## FocusConfiguration Reference

| Property | Type | Default | Description |
|---|---|---:|---|
| `workDuration` | `TimeInterval` | `1500` | Work interval duration (seconds). |
| `shortBreakDuration` | `TimeInterval` | `300` | Short break duration (seconds). |
| `longBreakDuration` | `TimeInterval` | `900` | Long break duration (seconds). |
| `sessionsBeforeLongBreak` | `Int` | `4` | Work sessions before long break. |
| `autoStartNext` | `Bool` | `false` | Auto-transition to next phase. |
| `notificationsEnabled` | `Bool` | `true` | App-level transition notification flag. |

## Optional Blocking Layer

> Warning: `FocusKitBlocking` requires Apple Screen Time entitlement and must be tested on-device.

```swift
import FocusKit
import FocusKitBlocking

let blocker = FocusBlocker(
    store: FocusKit.makeStore(),
    configuration: BlockingConfiguration()
)
try await blocker.requestAuthorization()
await blocker.attach()
```

## Comparison

| Solution | Reusable Core API | Optional Blocking Module | Entitlement-Free Base | Swift Package Focused |
|---|---:|---:|---:|---:|
| Typical Pomodoro apps | No | No | N/A | No |
| App templates | Partial | No | Partial | Partial |
| FocusKit | Yes | Yes | Yes | Yes |