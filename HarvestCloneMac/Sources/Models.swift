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
    var date: Date
    var startTime: Date
    var endTime: Date
    
    init(id: UUID = UUID(), projectId: UUID, description: String, date: Date = Date(), startTime: Date, endTime: Date) {
        self.id = id
        self.projectId = projectId
        self.description = description
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
    }
    
    // Custom decoding to handle older entries missing the `date` field
    enum CodingKeys: String, CodingKey {
        case id, projectId, description, date, startTime, endTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        projectId = try container.decode(UUID.self, forKey: .projectId)
        description = try container.decode(String.self, forKey: .description)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        // If date is missing (old data), fallback to startTime
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? startTime
    }
}

struct ActiveTimer: Codable {
    var projectId: UUID
    var description: String
    var startTime: Date?
    var accumulatedTime: TimeInterval
    
    init(projectId: UUID, description: String, startTime: Date?, accumulatedTime: TimeInterval = 0) {
        self.projectId = projectId
        self.description = description
        self.startTime = startTime
        self.accumulatedTime = accumulatedTime
    }
    
    enum CodingKeys: String, CodingKey {
        case projectId, description, startTime, accumulatedTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        projectId = try container.decode(UUID.self, forKey: .projectId)
        description = try container.decode(String.self, forKey: .description)
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        accumulatedTime = try container.decodeIfPresent(TimeInterval.self, forKey: .accumulatedTime) ?? 0
    }
}
