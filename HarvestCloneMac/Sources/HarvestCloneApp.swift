import SwiftUI

@main
struct HarvestCloneApp: App {
    @StateObject private var store = TimerStore()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(store)
                .frame(width: 800, height: 600)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: store.isTimerRunning ? "clock.fill" : "clock")
                if store.activeTimer != nil {
                    Text(store.headerTitle)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
