import SwiftUI

struct AddTimeEntryView: View {
    @EnvironmentObject var store: TimerStore
    var onClose: () -> Void
    
    @State private var currentDescription: String = ""
    @State private var selectedProjectId: UUID?
    @State private var manualStartTime = Date()
    @State private var manualEndTime = Date()
    
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
                
                DatePicker("Start Time", selection: $manualStartTime)
                DatePicker("End Time", selection: $manualEndTime)
            }
            .padding()
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    onClose()
                }
                
                Button("Save") {
                    if let pId = selectedProjectId {
                        let entry = TimeEntry(projectId: pId, description: currentDescription, startTime: manualStartTime, endTime: manualEndTime)
                        store.addTimeEntry(entry: entry)
                        onClose()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedProjectId == nil)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 400, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }
}
