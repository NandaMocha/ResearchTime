import Foundation

struct SupervisionSession: Identifiable, Codable {
    let id: UUID
    var dateTime: Date
    var supervisorId: UUID?
    var topicId: UUID?
    var title: String
    var keywords: [String]
    var questions: [Question]
    var actionItems: [ActionItem]
    var notesRichText: String
    var recordingPath: String?
    var isHidden: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        dateTime: Date = Date(),
        supervisorId: UUID? = nil,
        topicId: UUID? = nil,
        title: String = "",
        keywords: [String] = [],
        questions: [Question] = [],
        actionItems: [ActionItem] = [],
        notesRichText: String = "",
        recordingPath: String? = nil,
        isHidden: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.dateTime = dateTime
        self.supervisorId = supervisorId
        self.topicId = topicId
        self.title = title
        self.keywords = keywords
        self.questions = questions
        self.actionItems = actionItems
        self.notesRichText = notesRichText
        self.recordingPath = recordingPath
        self.isHidden = isHidden
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
