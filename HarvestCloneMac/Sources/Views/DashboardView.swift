import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: TimerStore
    
    var totalTime: TimeInterval {
        store.timeEntries.reduce(0) { total, entry in
            total + entry.endTime.timeIntervalSince(entry.startTime)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Dashboard")
                .font(.title)
                .bold()
            
            HStack {
                StatCard(title: "Total Tracked", value: store.formatDuration(totalTime))
                StatCard(title: "Projects", value: "\(store.projects.count)")
                StatCard(title: "Entries", value: "\(store.timeEntries.count)")
            }
            
            Text("Project Totals")
                .font(.headline)
                .padding(.top, 10)
            
            if store.projects.isEmpty {
                Text("No projects available.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(store.projects) { project in
                            HStack {
                                Circle()
                                    .fill(Color(hex: project.color) ?? .blue)
                                    .frame(width: 12, height: 12)
                                
                                Text(project.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(store.formatDuration(store.projectTotal(for: project)))
                                    .font(.system(.body, design: .monospaced))
                                    .bold()
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}
