import Foundation

struct Supervisor: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String?
    var phone: String?
    var department: String?
    var createdAt: Date
    var updatedAt: Date
    var isActive: Bool = true

    init(
        id: UUID = UUID(),
        name: String,
        email: String? = nil,
        phone: String? = nil,
        department: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.department = department
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isActive = isActive
    }
}
