import Foundation
import Combine

class TimerStore: ObservableObject {
    @Published var projects: [Project] = []
    @Published var timeEntries: [TimeEntry] = []
    @Published var activeTimer: ActiveTimer? = nil
    @Published var headerTitle: String = "Harvest Clone"
    @Published var isTimerRunning: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private let fileManager = FileManager.default
    private var dataURL: URL {
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupportURL.appendingPathComponent("HarvestClone")
        
        if !fileManager.fileExists(atPath: appDir.path) {
            try? fileManager.createDirectory(at: appDir, withIntermediateDirectories: true)
        }
        
        return appDir.appendingPathComponent("data.json")
    }
    
    init() {
        loadData()
        
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateHeaderTitle()
            }
            .store(in: &cancellables)
    }
    
    private func updateHeaderTitle() {
        guard let timer = activeTimer else {
            if headerTitle != "Harvest Clone" {
                headerTitle = "Harvest Clone"
                isTimerRunning = false
            }
            return
        }
        
        let elapsed = Date().timeIntervalSince(timer.startTime)
        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) / 60 % 60
        let seconds = Int(elapsed) % 60
        
        let newTitle: String
        if hours > 0 {
            newTitle = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            newTitle = String(format: "%02i:%02i", minutes, seconds)
        }
        
        if headerTitle != newTitle {
            headerTitle = newTitle
            isTimerRunning = true
        }
    }
    
    func addProject(name: String, color: String) {
        let project = Project(name: name, color: color)
        projects.append(project)
        saveData()
    }
    
    func deleteProject(id: UUID) {
        projects.removeAll { $0.id == id }
        saveData()
    }
    
    func startTimer(projectId: UUID, description: String) {
        activeTimer = ActiveTimer(projectId: projectId, description: description, startTime: Date())
        saveData()
    }
    
    func stopTimer() {
        guard let timer = activeTimer else { return }
        
        let entry = TimeEntry(projectId: timer.projectId, description: timer.description, startTime: timer.startTime, endTime: Date())
        timeEntries.insert(entry, at: 0)
        activeTimer = nil
        saveData()
    }
    
    func updateActiveTimerDescription(_ description: String) {
        if activeTimer != nil && activeTimer?.description != description {
            activeTimer?.description = description
            saveData()
        }
    }
    
    func updateTimeEntryDescription(id: UUID, description: String) {
        if let index = timeEntries.firstIndex(where: { $0.id == id }) {
            if timeEntries[index].description != description {
                timeEntries[index].description = description
                saveData()
            }
        }
    }
    
    func updateTimeEntry(_ updatedEntry: TimeEntry) {
        if let index = timeEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            timeEntries[index] = updatedEntry
            saveData()
        }
    }
    
    func deleteTimeEntry(id: UUID) {
        timeEntries.removeAll { $0.id == id }
        saveData()
    }
    
    func addTimeEntry(entry: TimeEntry) {
        timeEntries.insert(entry, at: 0)
        saveData()
    }
    
    func getProject(id: UUID) -> Project? {
        return projects.first { $0.id == id }
    }
    
    // MARK: - Persistence
    
    struct StoredData: Codable {
        var projects: [Project]
        var timeEntries: [TimeEntry]
        var activeTimer: ActiveTimer?
    }
    
    private func saveData() {
        let data = StoredData(projects: projects, timeEntries: timeEntries, activeTimer: activeTimer)
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: dataURL)
        }
    }
    
    private func loadData() {
        if let data = try? Data(contentsOf: dataURL) {
            if let decoded = try? JSONDecoder().decode(StoredData.self, from: data) {
                self.projects = decoded.projects
                self.timeEntries = decoded.timeEntries
                self.activeTimer = decoded.activeTimer
            }
        }
    }
}
