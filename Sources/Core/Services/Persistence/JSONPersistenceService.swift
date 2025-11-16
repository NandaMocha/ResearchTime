import Foundation

enum PersistenceError: Error, LocalizedError {
    case supervisorNotFound
    case topicNotFound
    case sessionNotFound

    var errorDescription: String? {
        switch self {
        case .supervisorNotFound:
            return "The requested supervisor was not found."
        case .topicNotFound:
            return "The requested topic was not found."
        case .sessionNotFound:
            return "The requested session was not found."
        }
    }
}

class JSONPersistenceService: PersistenceService {
    private let fileManager = FileManager.default
    private let baseDirectory: URL
    private let supervisorsFile: URL
    private let topicsFile: URL
    private let sessionsFile: URL

    private var supervisors: [Supervisor] = []
    private var topics: [Topic] = []
    private var sessions: [SupervisionSession] = []

    private let queue = DispatchQueue(label: "com.researchsupervision.persistence", attributes: .concurrent)

    init() throws {
        let appSupportDir = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        baseDirectory = appSupportDir.appendingPathComponent("ResearchSupervisionLog")
        supervisorsFile = baseDirectory.appendingPathComponent("supervisors.json")
        topicsFile = baseDirectory.appendingPathComponent("topics.json")
        sessionsFile = baseDirectory.appendingPathComponent("sessions.json")

        try createDirectoryIfNeeded()
        try loadData()
    }

    private func createDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: baseDirectory.path) {
            try fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private func loadData() throws {
        if fileManager.fileExists(atPath: supervisorsFile.path) {
            let data = try Data(contentsOf: supervisorsFile)
            supervisors = try JSONDecoder().decode([Supervisor].self, from: data)
        }

        if fileManager.fileExists(atPath: topicsFile.path) {
            let data = try Data(contentsOf: topicsFile)
            topics = try JSONDecoder().decode([Topic].self, from: data)
        }

        if fileManager.fileExists(atPath: sessionsFile.path) {
            let data = try Data(contentsOf: sessionsFile)
            sessions = try JSONDecoder().decode([SupervisionSession].self, from: data)
        }
    }

    private func saveSupervisors() throws {
        let data = try JSONEncoder().encode(supervisors)
        try data.write(to: supervisorsFile, options: .atomic)
    }

    private func saveTopics() throws {
        let data = try JSONEncoder().encode(topics)
        try data.write(to: topicsFile, options: .atomic)
    }

    private func saveSessions() throws {
        let data = try JSONEncoder().encode(sessions)
        try data.write(to: sessionsFile, options: .atomic)
    }

    // MARK: - Supervisor Operations

    func createSupervisor(_ supervisor: Supervisor) async throws {
        var mutableSupervisor = supervisor
        mutableSupervisor.createdAt = Date()
        mutableSupervisor.updatedAt = Date()

        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [self] in
                supervisors.append(mutableSupervisor)
                do {
                    try saveSupervisors()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func updateSupervisor(_ supervisor: Supervisor) async throws {
        var mutableSupervisor = supervisor
        mutableSupervisor.updatedAt = Date()

        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [self] in
                if let index = supervisors.firstIndex(where: { $0.id == supervisor.id }) {
                    supervisors[index] = mutableSupervisor
                    do {
                        try saveSupervisors()
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume(throwing: PersistenceError.supervisorNotFound)
                }
            }
        }
    }

    func fetchSupervisor(id: UUID) throws -> Supervisor? {
        return queue.sync {
            supervisors.first { $0.id == id }
        }
    }

    func fetchAllSupervisors() throws -> [Supervisor] {
        return queue.sync {
            supervisors.filter { $0.isActive }.sorted { $0.name < $1.name }
        }
    }

    // MARK: - Topic Operations

    func createTopic(_ topic: Topic) async throws {
        var mutableTopic = topic
        mutableTopic.createdAt = Date()
        mutableTopic.updatedAt = Date()

        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [self] in
                topics.append(mutableTopic)
                do {
                    try saveTopics()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func updateTopic(_ topic: Topic) async throws {
        var mutableTopic = topic
        mutableTopic.updatedAt = Date()

        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [self] in
                if let index = topics.firstIndex(where: { $0.id == topic.id }) {
                    topics[index] = mutableTopic
                    do {
                        try saveTopics()
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume(throwing: PersistenceError.topicNotFound)
                }
            }
        }
    }

    func fetchTopic(id: UUID) throws -> Topic? {
        return queue.sync {
            topics.first { $0.id == id }
        }
    }

    func fetchAllTopics() throws -> [Topic] {
        return queue.sync {
            topics.sorted { $0.name < $1.name }
        }
    }

    // MARK: - SupervisionSession Operations

    func createSession(_ session: SupervisionSession) async throws {
        var mutableSession = session
        mutableSession.createdAt = Date()
        mutableSession.updatedAt = Date()

        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [self] in
                sessions.append(mutableSession)
                do {
                    try saveSessions()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func updateSession(_ session: SupervisionSession) async throws {
        var mutableSession = session
        mutableSession.updatedAt = Date()

        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [self] in
                if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                    sessions[index] = mutableSession
                    do {
                        try saveSessions()
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume(throwing: PersistenceError.sessionNotFound)
                }
            }
        }
    }

    func fetchSession(id: UUID) throws -> SupervisionSession? {
        return queue.sync {
            sessions.first { $0.id == id && !$0.isHidden }
        }
    }

    func fetchSessionsForTopic(topicId: UUID) throws -> [SupervisionSession] {
        return queue.sync {
            sessions
                .filter { $0.topicId == topicId && !$0.isHidden }
                .sorted { $0.dateTime > $1.dateTime }
        }
    }

    func fetchSessionsForSupervisor(supervisorId: UUID) throws -> [SupervisionSession] {
        return queue.sync {
            sessions
                .filter { $0.supervisorId == supervisorId && !$0.isHidden }
                .sorted { $0.dateTime > $1.dateTime }
        }
    }

    func fetchAllSessions() throws -> [SupervisionSession] {
        return queue.sync {
            sessions
                .filter { !$0.isHidden }
                .sorted { $0.dateTime > $1.dateTime }
        }
    }

    func deleteSession(id: UUID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [self] in
                sessions.removeAll { $0.id == id }
                do {
                    try saveSessions()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
