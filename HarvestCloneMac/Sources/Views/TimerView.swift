import SwiftUI

struct TimerView: View {
    @EnvironmentObject var store: TimerStore
    
    @State private var selectedProjectId: UUID?
    @State private var currentDescription: String = ""
    
    @State private var isAddingEntry: Bool = false
    @State private var entryToEdit: TimeEntry? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 20) {
                // Header timer block
                VStack(spacing: 15) {
                    Text("Time Tracking")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 10) {
                        TextField("What are you working on?", text: $currentDescription)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: currentDescription) { newValue in
                                if store.activeTimer != nil {
                                    store.updateActiveTimerDescription(newValue)
                                }
                            }
                        
                        Picker("", selection: $selectedProjectId) {
                            Text("Select Project").tag(UUID?(nil))
                            ForEach(store.projects) { project in
                                Text(project.name).tag(UUID?(project.id))
                            }
                        }
                        .frame(maxWidth: 200)
                        .onChange(of: selectedProjectId) { newValue in
                            if store.activeTimer != nil {
                                if let pId = newValue {
                                    store.updateActiveTimerProject(pId)
                                } else {
                                    selectedProjectId = store.activeTimer?.projectId
                                }
                            }
                        }
                        
                        Text(store.activeTimer?.entryId == nil ? store.activeTimeString : "00:00:00")
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 80)
                        
                        if store.activeTimer != nil && store.activeTimer?.entryId == nil {
                            Button(action: {
                                if store.activeTimer?.startTime != nil {
                                    store.pauseTimer()
                                } else {
                                    store.resumeTimer()
                                }
                            }) {
                                Image(systemName: store.activeTimer?.startTime != nil ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.orange)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }

                        Button(action: {
                            if store.activeTimer != nil && store.activeTimer?.entryId == nil {
                                store.stopTimer()
                                currentDescription = ""
                                selectedProjectId = nil
                            } else if let pId = selectedProjectId {
                                store.startTimer(projectId: pId, description: currentDescription)
                            }
                        }) {
                            Image(systemName: (store.activeTimer != nil && store.activeTimer?.entryId == nil) ? "stop.fill" : "play.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background((store.activeTimer != nil && store.activeTimer?.entryId == nil) ? Color.red : Color.green)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled((store.activeTimer == nil) && selectedProjectId == nil)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                
                // Entries
                VStack(alignment: .leading) {
                    Text("Recent Entries")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    if store.timeEntries.isEmpty {
                        Text("No time entries yet.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(store.timeEntries) { entry in
                                    if let project = store.getProject(id: entry.projectId) {
                                        HStack {
                                            Button(action: {
                                                entryToEdit = entry
                                            }) {
                                                HStack {
                                                    Circle()
                                                        .fill(Color(hex: project.color) ?? .blue)
                                                        .frame(width: 10, height: 10)
                                                    
                                                    Text(project.name)
                                                        .font(.subheadline)
                                                        .frame(width: 100, alignment: .leading)
                                                    
                                                    Text(entry.description.isEmpty ? "No description" : entry.description)
                                                        .foregroundColor(entry.description.isEmpty ? .secondary : .primary)
                                                    
                                                    Spacer()
                                                    
                                                    Text(entry.date, style: .date)
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                        .padding(.trailing, 8)
                                                }
                                            }
                                            .buttonStyle(.plain)
                                            
                                            // Conditional Right Aligned UI 
                                            if store.activeTimer?.entryId == entry.id {
                                                // Timer is actively running here implicitly
                                                Text(store.activeTimeString)
                                                    .font(.system(.body, design: .monospaced))
                                                    .foregroundColor(.blue) // Highlight it so user knows it's mutating
                                                
                                                Button(action: {
                                                    if store.activeTimer?.startTime != nil {
                                                        store.pauseTimer()
                                                    } else {
                                                        store.resumeTimer()
                                                    }
                                                }) {
                                                    Image(systemName: store.activeTimer?.startTime != nil ? "pause.fill" : "play.fill")
                                                        .foregroundColor(.orange)
                                                        .padding(.leading, 8)
                                                }
                                                .buttonStyle(.plain)
                                                
                                                Button(action: {
                                                    store.stopTimer() // Stops this row cleanly returning text view layout natively
                                                }) {
                                                    Image(systemName: "stop.fill")
                                                        .foregroundColor(.red)
                                                        .padding(.leading, 4)
                                                }
                                                .buttonStyle(.plain)

                                            } else {
                                                // Default historical data display
                                                Text(timeString(from: entry.endTime.timeIntervalSince(entry.startTime)))
                                                    .font(.system(.body, design: .monospaced))
                                            
                                                Button(action: {
                                                    store.resumeTimeEntry(entry)
                                                    selectedProjectId = entry.projectId
                                                    currentDescription = entry.description
                                                }) {
                                                    Image(systemName: "play.fill")
                                                        .foregroundColor(.blue)
                                                        .padding(.leading, 8)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding()
                                        .background(store.activeTimer?.entryId == entry.id ? Color.accentColor.opacity(0.08) : Color(NSColor.controlBackgroundColor))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(store.activeTimer?.entryId == entry.id ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            Button(action: {
                isAddingEntry = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .padding(30)
            .zIndex(10)
            
            if let entry = entryToEdit {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            entryToEdit = nil
                        }
                        
                    EditTimeEntryView(entry: entry) {
                        entryToEdit = nil
                    }
                }
                .zIndex(100)
            }
            
            if isAddingEntry {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isAddingEntry = false
                        }
                        
                    AddTimeEntryView {
                        isAddingEntry = false
                    }
                }
                .zIndex(100)
            }
        }
        .onAppear {
            if let activeInfo = store.activeTimer {
                selectedProjectId = activeInfo.projectId
                currentDescription = activeInfo.description
            }
        }
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

