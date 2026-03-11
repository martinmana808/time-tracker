import Foundation
import Combine

class TimerStore: ObservableObject {
    @Published var projects: [Project] = []
    @Published var timeEntries: [TimeEntry] = []
    @Published var activeTimer: ActiveTimer? = nil
    @Published var headerTitle: String = "Harvest Clone"
    @Published var isTimerRunning: Bool = false
    @Published var activeTimeString: String = "00:00:00"
    
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
                self?.updateTimerStrings()
            }
            .store(in: &cancellables)
    }
    
    private func updateTimerStrings() {
        guard let timer = activeTimer else {
            if headerTitle != "Harvest Clone" {
                headerTitle = "Harvest Clone"
                isTimerRunning = false
                activeTimeString = "00:00:00"
            }
            return
        }
        
        let elapsed: TimeInterval
        if let startTime = timer.startTime {
            elapsed = timer.accumulatedTime + Date().timeIntervalSince(startTime)
        } else {
            elapsed = timer.accumulatedTime
        }
        
        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) / 60 % 60
        let seconds = Int(elapsed) % 60
        
        let fullTimeString = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        activeTimeString = fullTimeString
        
        let newTitle: String
        if hours > 0 {
            newTitle = fullTimeString
        } else {
            newTitle = String(format: "%02i:%02i", minutes, seconds)
        }
        
        let isRunningNow = (timer.startTime != nil)
        
        if headerTitle != newTitle {
            headerTitle = newTitle
        }
        
        if isTimerRunning != isRunningNow {
            isTimerRunning = isRunningNow
        }
    }
    
    func addProject(name: String, color: String) {
        let project = Project(name: name, color: color)
        projects.append(project)
        saveData()
    }
    
    func updateProject(id: UUID, name: String, color: String) {
        if let index = projects.firstIndex(where: { $0.id == id }) {
            projects[index].name = name
            projects[index].color = color
            saveData()
        }
    }
    
    func deleteProject(id: UUID) {
        projects.removeAll { $0.id == id }
        saveData()
    }
    
    func startTimer(projectId: UUID, description: String) {
        activeTimer = ActiveTimer(projectId: projectId, description: description, startTime: Date(), accumulatedTime: 0)
        saveData()
    }
    
    func pauseTimer() {
        guard var timer = activeTimer, let startTime = timer.startTime else { return }
        
        timer.accumulatedTime += Date().timeIntervalSince(startTime)
        timer.startTime = nil
        activeTimer = timer
        saveData()
        updateTimerStrings()
    }
    
    func resumeTimer() {
        guard var timer = activeTimer, timer.startTime == nil else { return }
        
        timer.startTime = Date()
        activeTimer = timer
        saveData()
        updateTimerStrings()
    }
    
    func stopTimer() {
        guard let timer = activeTimer else { return }
        
        let endTime = Date()
        let totalElapsed: TimeInterval
        if let startTime = timer.startTime {
            totalElapsed = timer.accumulatedTime + endTime.timeIntervalSince(startTime)
        } else {
            totalElapsed = timer.accumulatedTime
        }
        
        let effectiveStartTime = endTime.addingTimeInterval(-totalElapsed)
        
        let entry = TimeEntry(projectId: timer.projectId, description: timer.description, startTime: effectiveStartTime, endTime: endTime)
        timeEntries.insert(entry, at: 0)
        activeTimer = nil
        saveData()
    }
    
    func resumeTimeEntry(_ entry: TimeEntry) {
        if activeTimer != nil {
            stopTimer()
        }
        
        let accumulatedTime = entry.endTime.timeIntervalSince(entry.startTime)
        let _ = deleteTimeEntry(id: entry.id)
        
        activeTimer = ActiveTimer(projectId: entry.projectId, description: entry.description, startTime: Date(), accumulatedTime: accumulatedTime)
        saveData()
        updateTimerStrings()
    }
    
    func updateActiveTimerDescription(_ description: String) {
        if activeTimer != nil && activeTimer?.description != description {
            activeTimer?.description = description
            saveData()
        }
    }
    
    func updateActiveTimerProject(_ projectId: UUID) {
        if activeTimer != nil && activeTimer?.projectId != projectId {
            activeTimer?.projectId = projectId
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
    
    // MARK: - Utilities
    
    func projectTotal(for project: Project) -> TimeInterval {
        let historicalTotal = timeEntries
            .filter { $0.projectId == project.id }
            .reduce(0) { total, entry in
                total + entry.endTime.timeIntervalSince(entry.startTime)
            }
        
        let activeTotal: TimeInterval
        if let active = activeTimer, active.projectId == project.id {
            if let startTime = active.startTime {
                activeTotal = active.accumulatedTime + Date().timeIntervalSince(startTime)
            } else {
                activeTotal = active.accumulatedTime
            }
        } else {
            activeTotal = 0
        }
        
        return historicalTotal + activeTotal
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
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
