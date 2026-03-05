import Foundation

struct Project: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var color: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, color: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
    }
}

struct TimeEntry: Identifiable, Codable, Hashable {
    var id: UUID
    var projectId: UUID
    var description: String
    var startTime: Date
    var endTime: Date
    
    init(id: UUID = UUID(), projectId: UUID, description: String, startTime: Date, endTime: Date) {
        self.id = id
        self.projectId = projectId
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
    }
}

struct ActiveTimer: Codable {
    var projectId: UUID
    var description: String
    var startTime: Date
}
