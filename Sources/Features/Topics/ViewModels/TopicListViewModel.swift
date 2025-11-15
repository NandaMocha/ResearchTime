import SwiftUI

class TopicListViewModel: ObservableObject {
    @Published var topics: [Topic] = []
    @Published var supervisors: [Supervisor] = []
    @Published var selectedTopic: Topic?
    @Published var sessions: [SupervisionSession] = []

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }

    @MainActor
    func loadTopics() async {
        do {
            topics = try persistenceService.fetchAllTopics()
        } catch {
            print("Error loading topics: \(error)")
        }
    }

    @MainActor
    func loadSupervisors() async {
        do {
            supervisors = try persistenceService.fetchAllSupervisors()
        } catch {
            print("Error loading supervisors: \(error)")
        }
    }

    @MainActor
    func loadSessionsForTopic(_ topic: Topic) async {
        do {
            sessions = try persistenceService.fetchSessionsForTopic(topicId: topic.id)
        } catch {
            print("Error loading sessions: \(error)")
        }
    }

    @MainActor
    func updateTopic(_ topic: Topic) async throws {
        try persistenceService.updateTopic(topic)
        await loadTopics()
    }

    @MainActor
    func deleteTopic(_ topic: Topic) async throws {
        // In v1, topics cannot be deleted; implement soft delete if needed
        print("Deleting topic is not supported in v1")
    }

    func getSupervisor(id: UUID) -> Supervisor? {
        supervisors.first { $0.id == id }
    }
}
