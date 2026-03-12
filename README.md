# Harvest Clone (macOS)

A native macOS menu bar application built with SwiftUI to seamlessly track time against projects, mimicking the core experience of [Harvest](https://www.getharvest.com/).

## Features

- **Native Menu Bar App**: Lives entirely in your Mac's menu bar for lightweight, instant access.
- **Time Tracking**: Start, pause, and stop timers associated with specific projects and descriptions.
- **Inline Resumption**: Seamlessly resume past time entries. Clicking play on a historical entry resumes the tracker natively in the list, exactly like Harvest.
- **Mid-Flight Editing**: Edit the project association and description of a running timer without having to stop it.
- **Local Persistence**: All projects and time entries are saved to your local Application Support directory instantly.

## Tech Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: `ObservableObject` state management tracking a central `TimerStore`.
- **Target**: macOS 13.0+

## Development

Open `HarvestCloneMac/HarvestClone.xcodeproj` natively in Xcode to view, modify, and build the target.

```bash
# Build the project via CLI
xcodebuild -project HarvestCloneMac/HarvestClone.xcodeproj -scheme HarvestClone build
```

## Architecture Notes

Check out `./docs/` for a comprehensive historical ledger (`PROJECT_log-detail.md`) capturing architectural decisions, implementation walkthroughs, and iterative feature bounds tracked strictly to the project's evolution.
