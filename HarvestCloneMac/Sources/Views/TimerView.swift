import SwiftUI

struct TimerView: View {
    @EnvironmentObject var store: TimerStore
    
    enum TrackingMode {
        case timer
        case manual
    }
    
    @State private var mode: TrackingMode = .timer
    @State private var selectedProjectId: UUID?
    @State private var currentDescription: String = ""
    @State private var elapsedSeconds: TimeInterval = 0
    
    @State private var manualStartTime = Date()
    @State private var manualEndTime = Date()
    
    @State private var entryToEdit: TimeEntry? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            // Header timer block
            VStack(spacing: 15) {
                HStack {
                    Text("Time Tracking")
                        .font(.headline)
                    Spacer()
                    Picker("", selection: $mode) {
                        Text("Timer").tag(TrackingMode.timer)
                        Text("Manual").tag(TrackingMode.manual)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                HStack(spacing: 10) {
                    TextField("What are you working on?", text: $currentDescription)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: currentDescription) { newValue in
                            if store.activeTimer != nil {
                                store.updateActiveTimerDescription(newValue)
                            }
                        }
                        .disabled(store.activeTimer != nil && mode == .manual)
                    
                    Picker("", selection: $selectedProjectId) {
                        Text("Select Project").tag(UUID?(nil))
                        ForEach(store.projects) { project in
                            Text(project.name).tag(UUID?(project.id))
                        }
                    }
                    .frame(maxWidth: 200)
                    .disabled(store.activeTimer != nil && mode == .manual)
                    
                    if mode == .timer {
                        Text(timeString(from: elapsedSeconds))
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 80)
                        
                        Button(action: {
                            if store.activeTimer != nil {
                                store.stopTimer()
                                currentDescription = ""
                                selectedProjectId = nil
                                elapsedSeconds = 0
                            } else if let pId = selectedProjectId {
                                store.startTimer(projectId: pId, description: currentDescription)
                                elapsedSeconds = 0
                            }
                        }) {
                            Image(systemName: store.activeTimer != nil ? "stop.fill" : "play.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(store.activeTimer != nil ? Color.red : Color.green)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(store.activeTimer == nil && selectedProjectId == nil)
                    } else {
                        DatePicker("", selection: $manualStartTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(width: 80)
                        
                        Text("to")
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $manualEndTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(width: 80)
                        
                        Button("Add") {
                            if let pId = selectedProjectId {
                                let entry = TimeEntry(projectId: pId, description: currentDescription, startTime: manualStartTime, endTime: manualEndTime)
                                store.addTimeEntry(entry: entry)
                                currentDescription = ""
                                selectedProjectId = nil
                                manualStartTime = Date()
                                manualEndTime = Date()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedProjectId == nil)
                    }
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
                                            
                                            Text(timeString(from: entry.endTime.timeIntervalSince(entry.startTime)))
                                                .font(.system(.body, design: .monospaced))
                                        }
                                        .padding()
                                        .background(Color(NSColor.controlBackgroundColor))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
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
        .onReceive(timer) { _ in
            if let activeInfo = store.activeTimer {
                elapsedSeconds = Date().timeIntervalSince(activeInfo.startTime)
            }
        }
        .onAppear {
            if let activeInfo = store.activeTimer {
                selectedProjectId = activeInfo.projectId
                currentDescription = activeInfo.description
                elapsedSeconds = Date().timeIntervalSince(activeInfo.startTime)
            }
        }
        .sheet(item: $entryToEdit) { entry in
            EditTimeEntryView(entry: entry)
        }
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

