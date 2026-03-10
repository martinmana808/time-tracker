# Harvest Clone Timer
## Tech Stack
Native macOS Application: Swift, SwiftUI, XcodeGen

## Project Summary
A local-first stopwatch and timer application cloning Harvest functionality. Re-built natively for macOS to run silently in the Menu Bar using deep system integrations without Electron overhead.

## History

### [2026-03-10] Edit Active Timer Mid-Flight | [Technical Details](./PROJECT_log-detail.md#log-20260310-edit-midflight)
- Removed `.disabled(store.activeTimer != nil)` restrictions from `TimerView` for both Project Pickers and Description TextFields.
- Bound robust state mutations internally via `.onChange` matching direct references inside `TimerStore` enabling seamless on-the-fly corrections.

### [2026-03-10] Play/Pause Active Timer | [Technical Details](./PROJECT_log-detail.md#log-20260310-play-pause-timer)
- Rewrote the `ActiveTimer` structure bounding explicit calculation variables across `accumulatedTime` to decouple ticking spans.
- Appended native UI components inside `TimerView` for mid-stream Play/Pause interruptions instead of generating entirely distinct tracking logs.
- Adjusted `TimerStore` and `HarvestCloneApp` global tracking constraints successfully handling static dormant timer visualization cleanly inside macOS.

### [2026-03-06] Editable Projects & Totals | [Technical Details](./PROJECT_log-detail.md#log-20260306-editable-projects)
- Updated `ProjectsView` to natively display standard elapsed aggregated tracking time formatted seamlessly.
- Built a native macOS properties sheet rendering inputs over discrete projects, allowing real-time mutation of existing names globally via a `.popover()` closure.

### [2026-03-06] MenuBar Active Timer Display | [Technical Details](./PROJECT_log-detail.md#log-20260306-menubar-active-timer-display)
- Explicitly broke out `MenuBarExtra` configuration inside `HarvestCloneApp.swift` to use an encapsulated component block rather than raw parameterized text limits.
- Forced deep reactive views allowing `store.headerTitle` ticks to update cleanly in realtime globally.

### [2026-03-06] Per-Project Totals on Dashboard | [Technical Details](./PROJECT_log-detail.md#log-20260306-dashboard-project-totals)
- Added continuous polling and list rendering of precise elapsed totals mapped natively to their associated Projects in the `DashboardView`.
- Refactored logic checks so the `activeTimer` successfully merges cleanly into the aggregate Historical totals per tick.

### [2026-03-06] Editable Date for Time Entries | [Technical Details](./PROJECT_log-detail.md#log-20260306-editable-date)
- Updated native `TimeEntry` model to explicitly store a `Date` property.
- Appended `DatePicker` variables inside the `AddTimeEntryView` and `EditTimeEntryView` to allow explicit setting of the associated event date.
- Added visual date formatting inside the `TimerView` history entries.

### [2026-03-06] Menu Bar Timer | [Technical Details](./PROJECT_log-detail.md#log-20260306-menu-bar-timer)
- Added dynamic timer ticking to the macOS menu bar title using Electron's `Tray.setTitle()`.
- Implemented IPC bridging from the frontend React state (`TimerView.tsx`) to push duration string updates to the Electron backend every second.

### [2026-03-06] Re-design Native Form Logic to Duration | [Technical Details](./PROJECT_log-detail.md#log-20260306-duration-steppers)
- Swapped explicit start and end DatePickers with native scrolling Hours and Minutes bindings.
- Extended the logic directly across Edit and Manual Addition modals so all non-tracking functionality uses precise Duration formatting over Absolute Time selections to seamlessly match standard Harvest platform mechanics.

### [2026-03-06] Re-design Manual Mode with Floating Action Button | [Technical Details](./PROJECT_log-detail.md#log-20260306-manual-entry-fab)
- Abandoned the Segment Picker toggle switch logic.
- Rewrote the tracking screen back to its standard static appearance. Added a floating `+` button in the `.bottomTrailing` corner to act as a permanent Manual Addition shortcut.
- Bound the floating button to a `.overlay` similar to our edit menu, utilizing an `AddTimeEntryView` form to ensure no components override the MenuBar focus state.

### [2026-03-05] MenuBar Focus Fixes & Active Timing | [Technical Details](./PROJECT_log-detail.md#log-20260305-menubar-time-dynamic)
- Modified `TimerView` logic to utilize an internal `ZStack` overlay. This permanently prevents `.sheet` window-level interruptions from dismissing the `MenuBarExtra` parent view.
- Added an active `Timer` publisher natively into `TimerStore` bound to a specific `headerTitle` string, causing the global Apple top menu bar item to visually tick the active hours alongside the icon smoothly.

### [2026-03-05] Enable Manual Logic & Advanced Editing | [Technical Details](./PROJECT_log-detail.md#log-20260305-manual-entries)
- Rebuilt standard active inputs natively substituting tracking modes dynamically via Segmented Picker.
- Introduced declarative editing natively via Apple's `.sheet` pattern. 
- Integrated custom duration bounds picking into `TimeEntry` models natively. 

### [2026-03-05] Enable Editable Descriptions | [Technical Details](./PROJECT_log-detail.md#log-20260305-edit-descriptions)
- Refactored SwiftUI inputs to allow active typed descriptions during live ticking.
- Bound past time entries to discrete TextField components allowing retroactive editing.

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
