import SwiftUI

struct EditTimeEntryView: View {
    @EnvironmentObject var store: TimerStore
    
    @State var entry: TimeEntry
    var onClose: () -> Void
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Entry")
                .font(.headline)
            
            Form {
                TextField("Description", text: $entry.description)
                
                Picker("Project", selection: $entry.projectId) {
                    ForEach(store.projects) { project in
                        Text(project.name).tag(project.id)
                    }
                }
                
                HStack(spacing: 20) {
                    Stepper("Hours: \(hours)", value: $hours, in: 0...99)
                    Stepper("Minutes: \(minutes)", value: $minutes, in: 0...59)
                }
            }
            .padding()
            
            HStack {
                Button("Delete", role: .destructive) {
                    store.deleteTimeEntry(id: entry.id)
                    onClose()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
                Spacer()
                
                Button("Cancel") {
                    onClose()
                }
                
                Button("Save") {
                    let duration = TimeInterval(hours * 3600 + minutes * 60)
                    entry.endTime = entry.startTime.addingTimeInterval(duration)
                    
                    store.updateTimeEntry(entry)
                    onClose()
                }
                .buttonStyle(.borderedProminent)
                .disabled(hours == 0 && minutes == 0)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 400, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
        .onAppear {
            let duration = entry.endTime.timeIntervalSince(entry.startTime)
            hours = Int(duration) / 3600
            minutes = Int(duration) / 60 % 60
        }
    }
}
