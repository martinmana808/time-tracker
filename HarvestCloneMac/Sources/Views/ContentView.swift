import SwiftUI

enum Tab {
    case dashboard
    case timer
    case projects
}

struct ContentView: View {
    @EnvironmentObject var store: TimerStore
    @State private var currentTab: Tab = .timer

    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Header
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                        .font(.system(size: 18))
                    Text("HarvestClone")
                        .font(.headline)
                }
                .padding(.trailing, 10)

                HStack(spacing: 12) {
                    TabButton(title: "Time", icon: "clock", isSelected: currentTab == .timer) {
                        currentTab = .timer
                    }
                    TabButton(title: "Dashboard", icon: "square.grid.2x2", isSelected: currentTab == .dashboard) {
                        currentTab = .dashboard
                    }
                    TabButton(title: "Projects", icon: "folder", isSelected: currentTab == .projects) {
                        currentTab = .projects
                    }
                }
                
                Spacer()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Quit HarvestClone")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()

            // Main Content
            VStack {
                switch currentTab {
                case .dashboard:
                    DashboardView()
                case .timer:
                    TimerView()
                case .projects:
                    ProjectsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.underPageBackgroundColor))
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .medium : .regular))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .foregroundColor(isSelected ? .accentColor : .primary)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
