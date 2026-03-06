import SwiftUI

struct EditTimeEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: TimerStore
    
    @State var entry: TimeEntry
    
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
                
                DatePicker("Start Time", selection: $entry.startTime)
                DatePicker("End Time", selection: $entry.endTime)
            }
            .padding()
            
            HStack {
                Button("Delete", role: .destructive) {
                    store.deleteTimeEntry(id: entry.id)
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    store.updateTimeEntry(entry)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 400, height: 280)
    }
}
