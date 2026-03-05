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
                StatCard(title: "Total Tracked", value: formatDuration(totalTime))
                StatCard(title: "Projects", value: "\(store.projects.count)")
                StatCard(title: "Entries", value: "\(store.timeEntries.count)")
            }
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
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
