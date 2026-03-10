import SwiftUI

struct AddTimeEntryView: View {
    @EnvironmentObject var store: TimerStore
    var onClose: () -> Void
    
    @State private var currentDescription: String = ""
    @State private var selectedProjectId: UUID?
    @State private var entryDate: Date = Date()
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Manual Entry")
                .font(.headline)
            
            Form {
                TextField("Description", text: $currentDescription)
                
                Picker("Project", selection: $selectedProjectId) {
                    Text("Select Project").tag(UUID?(nil))
                    ForEach(store.projects) { project in
                        Text(project.name).tag(UUID?(project.id))
                    }
                }
                
                DatePicker("Date", selection: $entryDate, displayedComponents: .date)
                
                HStack(spacing: 20) {
                    Stepper("Hours: \(hours)", value: $hours, in: 0...99)
                    Stepper("Minutes: \(minutes)", value: $minutes, in: 0...59)
                }
            }
            .padding()
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    onClose()
                }
                
                Button("Save") {
                    if let pId = selectedProjectId {
                        let duration = TimeInterval(hours * 3600 + minutes * 60)
                        let end = Date()
                        let start = end.addingTimeInterval(-duration)
                        
                        let entry = TimeEntry(projectId: pId, description: currentDescription, date: entryDate, startTime: start, endTime: end)
                        store.addTimeEntry(entry: entry)
                        onClose()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedProjectId == nil || (hours == 0 && minutes == 0))
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 400, height: 320)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }
}
