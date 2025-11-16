import Foundation

struct Topic: Identifiable, Codable {
    let id: UUID
    var name: String
    var relatedSupervisorIds: [UUID]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        relatedSupervisorIds: [UUID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.relatedSupervisorIds = relatedSupervisorIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
