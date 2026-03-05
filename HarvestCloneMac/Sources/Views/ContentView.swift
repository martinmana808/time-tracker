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
        HStack(spacing: 0) {
            // Sidebar
            VStack {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                    Text("HarvestClone")
                        .font(.headline)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)

                VStack(alignment: .leading, spacing: 10) {
                    SidebarButton(title: "Time", icon: "clock", isSelected: currentTab == .timer) {
                        currentTab = .timer
                    }
                    SidebarButton(title: "Dashboard", icon: "square.grid.2x2", isSelected: currentTab == .dashboard) {
                        currentTab = .dashboard
                    }
                    SidebarButton(title: "Projects", icon: "folder", isSelected: currentTab == .projects) {
                        currentTab = .projects
                    }
                }
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .padding()
                .foregroundColor(.secondary)
            }
            .frame(width: 180)
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

struct SidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                Text(title)
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .foregroundColor(isSelected ? .accentColor : .primary)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 10)
    }
}
