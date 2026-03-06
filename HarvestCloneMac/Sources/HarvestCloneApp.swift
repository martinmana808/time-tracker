import SwiftUI

@main
struct HarvestCloneApp: App {
    @StateObject private var store = TimerStore()
    
    var body: some Scene {
        MenuBarExtra(store.headerTitle, systemImage: store.isTimerRunning ? "clock.fill" : "clock") {
            ContentView()
                .environmentObject(store)
                .frame(width: 800, height: 600)
        }
        .menuBarExtraStyle(.window)
    }
}
