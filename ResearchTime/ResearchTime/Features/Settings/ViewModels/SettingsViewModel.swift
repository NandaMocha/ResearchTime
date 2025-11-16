import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var supervisors: [Supervisor] = []
    @Published var topics: [Topic] = []
    @Published var selectedSupervisor: Supervisor?
    @Published var selectedTopic: Topic?

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
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
}
