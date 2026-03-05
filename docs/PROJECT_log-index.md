# Harvest Clone Timer
## Tech Stack
React, Vite, TypeScript, Tailwind CSS, Zustand, Lucide React

## Project Summary
A local-first stopwatch and timer application cloning Harvest functionality. Users can create projects, track time against them, and view a dashboard of their tracked time.

## History

### [2026-03-05] Native App Migration | [Technical Details](./PROJECT_log-detail.md#log-20260305-electron-migration)
- Successfully migrated application into an Electron un-docked Menu Bar application.
- Wrote secure local IPC bridge bypassing standard `localStorage`.
- Packaged into `.app` bundles via `electron-builder`.

### [2026-03-05] Initial Harvest Clone Build | [Technical Details](./PROJECT_log-detail.md#log-20260305-harvest-clone-init)
- Scaffolded standard React, Vite, and Tailwind CSS base application.
- Implemented global local-storage caching via Zustand.
- Designed & wired UI interface with Dashboard, Timer View, and Project Management.
