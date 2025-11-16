import Foundation

struct Question: Identifiable, Codable {
    let id: UUID
    var questionText: String
    var answerText: String?

    init(
        id: UUID = UUID(),
        questionText: String = "",
        answerText: String? = nil
    ) {
        self.id = id
        self.questionText = questionText
        self.answerText = answerText
    }
}
