# Harvest Clone Timer
## Tech Stack
Native macOS Application: Swift, SwiftUI, XcodeGen

## Project Summary
A local-first stopwatch and timer application cloning Harvest functionality. Re-built natively for macOS to run silently in the Menu Bar using deep system integrations without Electron overhead.

## History

### [2026-03-05] Pure SwiftUI Full Native Rewrite | [Technical Details](./PROJECT_log-detail.md#log-20260305-xcode-migration)
- Circumvented Node/Electron bundle issues by transitioning entirely to native Swift rendering.
- Set up automated `xcodegen` schema for deterministic project generation.
- Re-created persistent storage natively via `ObservableObject` and system-level `FileManager` serialization.

### [2026-03-05] Native App Migration | [Technical Details](./PROJECT_log-detail.md#log-20260305-electron-migration)
- Successfully migrated application into an Electron un-docked Menu Bar application.
- Wrote secure local IPC bridge bypassing standard `localStorage`.
- Packaged into `.app` bundles via `electron-builder`.

### [2026-03-05] Initial Harvest Clone Build | [Technical Details](./PROJECT_log-detail.md#log-20260305-harvest-clone-init)
- Scaffolded standard React, Vite, and Tailwind CSS base application.
- Implemented global local-storage caching via Zustand.
- Designed & wired UI interface with Dashboard, Timer View, and Project Management.
