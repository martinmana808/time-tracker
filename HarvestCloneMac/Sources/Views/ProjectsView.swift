import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var store: TimerStore
    @State private var showingAddProject = false
    @State private var newProjectName = ""
    @State private var newProjectColor = "#3B82F6"
    
    @State private var editingProject: Project? = nil
    @State private var editProjectName = ""
    @State private var editProjectColor = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Projects")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: { showingAddProject.toggle() }) {
                    Image(systemName: "plus")
                    Text("New Project")
                }
                .buttonStyle(.borderedProminent)
                .popover(isPresented: $showingAddProject) {
                    VStack(spacing: 16) {
                        Text("New Project")
                            .font(.headline)
                        
                        TextField("Project Name", text: $newProjectName)
                            .textFieldStyle(.roundedBorder)
                        
                        HStack {
                            Button("Cancel") {
                                showingAddProject = false
                                newProjectName = ""
                            }
                            Button("Create") {
                                if !newProjectName.isEmpty {
                                    store.addProject(name: newProjectName, color: newProjectColor)
                                    showingAddProject = false
                                    newProjectName = ""
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newProjectName.isEmpty)
                        }
                    }
                    .padding()
                    .frame(width: 250)
                }
            }
            
            if store.projects.isEmpty {
                VStack {
                    Spacer()
                    Text("No projects yet.")
                        .foregroundColor(.secondary)
                    Text("Create one to start tracking time.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(store.projects) { project in
                            HStack {
                                Circle()
                                    .fill(Color(hex: project.color) ?? .blue)
                                    .frame(width: 12, height: 12)
                                
                                Text(project.name)
                                
                                Spacer()
                                
                                Text(store.formatDuration(store.projectTotal(for: project)))
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 10)
                                    
                                Button(action: {
                                    editProjectName = project.name
                                    editProjectColor = project.color
                                    editingProject = project
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, 5)

                                Button(action: { store.deleteProject(id: project.id) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .popover(item: $editingProject) { project in
            VStack(spacing: 16) {
                Text("Edit Project")
                    .font(.headline)
                
                TextField("Project Name", text: $editProjectName)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Button("Cancel") {
                        editingProject = nil
                    }
                    Button("Save") {
                        if !editProjectName.isEmpty {
                            store.updateProject(id: project.id, name: editProjectName, color: editProjectColor)
                            editingProject = nil
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(editProjectName.isEmpty)
                }
            }
            .padding()
            .frame(width: 250)
        }
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
