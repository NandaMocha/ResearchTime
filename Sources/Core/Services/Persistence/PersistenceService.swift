import Foundation

protocol PersistenceService: AnyObject {
    // Supervisor operations
    func createSupervisor(_ supervisor: Supervisor) async throws
    func updateSupervisor(_ supervisor: Supervisor) async throws
    func fetchSupervisor(id: UUID) throws -> Supervisor?
    func fetchAllSupervisors() throws -> [Supervisor]

    // Topic operations
    func createTopic(_ topic: Topic) async throws
    func updateTopic(_ topic: Topic) async throws
    func fetchTopic(id: UUID) throws -> Topic?
    func fetchAllTopics() throws -> [Topic]

    // SupervisionSession operations
    func createSession(_ session: SupervisionSession) async throws
    func updateSession(_ session: SupervisionSession) async throws
    func fetchSession(id: UUID) throws -> SupervisionSession?
    func fetchSessionsForTopic(topicId: UUID) throws -> [SupervisionSession]
    func fetchSessionsForSupervisor(supervisorId: UUID) throws -> [SupervisionSession]
    func fetchAllSessions() throws -> [SupervisionSession]
    func deleteSession(id: UUID) async throws
}
