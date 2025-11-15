import Foundation

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

    func createSupervisor(_ supervisor: Supervisor) throws {
        var mutableSupervisor = supervisor
        mutableSupervisor.createdAt = Date()
        mutableSupervisor.updatedAt = Date()

        queue.async(flags: .barrier) { [weak self] in
            self?.supervisors.append(mutableSupervisor)
            try? self?.saveSupervisors()
        }
    }

    func updateSupervisor(_ supervisor: Supervisor) throws {
        var mutableSupervisor = supervisor
        mutableSupervisor.updatedAt = Date()

        queue.async(flags: .barrier) { [weak self] in
            if let index = self?.supervisors.firstIndex(where: { $0.id == supervisor.id }) {
                self?.supervisors[index] = mutableSupervisor
                try? self?.saveSupervisors()
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

    func createTopic(_ topic: Topic) throws {
        var mutableTopic = topic
        mutableTopic.createdAt = Date()
        mutableTopic.updatedAt = Date()

        queue.async(flags: .barrier) { [weak self] in
            self?.topics.append(mutableTopic)
            try? self?.saveTopics()
        }
    }

    func updateTopic(_ topic: Topic) throws {
        var mutableTopic = topic
        mutableTopic.updatedAt = Date()

        queue.async(flags: .barrier) { [weak self] in
            if let index = self?.topics.firstIndex(where: { $0.id == topic.id }) {
                self?.topics[index] = mutableTopic
                try? self?.saveTopics()
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

    func createSession(_ session: SupervisionSession) throws {
        var mutableSession = session
        mutableSession.createdAt = Date()
        mutableSession.updatedAt = Date()

        queue.async(flags: .barrier) { [weak self] in
            self?.sessions.append(mutableSession)
            try? self?.saveSessions()
        }
    }

    func updateSession(_ session: SupervisionSession) throws {
        var mutableSession = session
        mutableSession.updatedAt = Date()

        queue.async(flags: .barrier) { [weak self] in
            if let index = self?.sessions.firstIndex(where: { $0.id == session.id }) {
                self?.sessions[index] = mutableSession
                try? self?.saveSessions()
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

    func deleteSession(id: UUID) throws {
        queue.async(flags: .barrier) { [weak self] in
            self?.sessions.removeAll { $0.id == id }
            try? self?.saveSessions()
        }
    }
}
