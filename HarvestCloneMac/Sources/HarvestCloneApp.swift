import SwiftUI

@main
struct HarvestCloneApp: App {
    @StateObject private var store = TimerStore()
    
    var body: some Scene {
        MenuBarExtra("Harvest Clone", systemImage: "clock") {
            ContentView()
                .environmentObject(store)
                .frame(width: 800, height: 600)
        }
        .menuBarExtraStyle(.window)
    }
}
