import SwiftUI

class SupervisionFormViewModel: ObservableObject {
    @Published var session: SupervisionSession
    @Published var supervisors: [Supervisor] = []
    @Published var topics: [Topic] = []
    @Published var showAddSupervisor = false
    @Published var showAddTopic = false
    @Published var newSupervisorName: String = ""
    @Published var newTopicName: String = ""
    @Published var selectedSupervisors: [UUID] = []

    private let persistenceService: PersistenceService
    var isEditMode: Bool = false

    init(persistenceService: PersistenceService, session: SupervisionSession? = nil) {
        self.persistenceService = persistenceService
        if let session = session {
            self.session = session
            self.isEditMode = true
        } else {
            self.session = SupervisionSession()
        }
    }

    @MainActor
    func loadData() async {
        do {
            supervisors = try persistenceService.fetchAllSupervisors()
            topics = try persistenceService.fetchAllTopics()
        } catch {
            print("Error loading data: \(error)")
        }
    }

    @MainActor
    func saveSession() async throws {
        session.updatedAt = Date()
        if isEditMode {
            try await persistenceService.updateSession(session)
        } else {
            try await persistenceService.createSession(session)
        }
    }

    @MainActor
    func addQuestion() {
        session.questions.append(Question())
    }

    @MainActor
    func removeQuestion(at index: Int) {
        if index >= 0 && index < session.questions.count {
            session.questions.remove(at: index)
        }
    }

    @MainActor
    func addActionItem() {
        session.actionItems.append(ActionItem())
    }

    @MainActor
    func removeActionItem(at index: Int) {
        if index >= 0 && index < session.actionItems.count {
            session.actionItems.remove(at: index)
        }
    }

    @MainActor
    func addNewSupervisor() async throws {
        let supervisor = Supervisor(name: newSupervisorName)
        try await persistenceService.createSupervisor(supervisor)
        supervisors.append(supervisor)
        supervisors.sort { $0.name < $1.name }
        session.supervisorId = supervisor.id
        showAddSupervisor = false
        newSupervisorName = ""
    }

    @MainActor
    func addNewTopic() async throws {
        var topic = Topic(name: newTopicName)
        topic.relatedSupervisorIds = selectedSupervisors
        try await persistenceService.createTopic(topic)
        topics.append(topic)
        topics.sort { $0.name < $1.name }
        session.topicId = topic.id
        showAddTopic = false
        newTopicName = ""
        selectedSupervisors = []
    }
}
