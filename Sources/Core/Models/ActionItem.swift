import Foundation

struct ActionItem: Identifiable, Codable {
    let id: UUID
    var itemText: String
    var notes: String?

    init(
        id: UUID = UUID(),
        itemText: String = "",
        notes: String? = nil
    ) {
        self.id = id
        self.itemText = itemText
        self.notes = notes
    }
}
