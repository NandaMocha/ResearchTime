import SwiftUI

class SupervisorListViewModel: ObservableObject {
    @Published var supervisors: [Supervisor] = []
    @Published var selectedSupervisor: Supervisor?
    @Published var sessions: [SupervisionSession] = []

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
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
    func loadSessionsForSupervisor(_ supervisor: Supervisor) async {
        do {
            sessions = try persistenceService.fetchSessionsForSupervisor(supervisorId: supervisor.id)
        } catch {
            print("Error loading sessions: \(error)")
        }
    }

    @MainActor
    func updateSupervisor(_ supervisor: Supervisor) async throws {
        try persistenceService.updateSupervisor(supervisor)
        await loadSupervisors()
    }
}
