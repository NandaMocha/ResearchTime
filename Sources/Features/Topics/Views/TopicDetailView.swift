import SwiftUI

struct TopicDetailView: View {
    @ObservedObject var viewModel: TopicListViewModel
    let topic: Topic
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedSupervisorIds: [UUID] = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(topic.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        Text("\(topic.relatedSupervisorIds.count) supervisor(s)")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    Spacer()
                    if !isEditing {
                        Button(action: { startEditing() }) {
                            Image(systemName: "pencil.circle")
                                .font(.title3)
                                .foregroundColor(.appInfo)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .background(Color.appSecondary)
            .borderBottom(height: 1, color: .appBorder)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if isEditing {
                        editingView
                    } else {
                        detailView
                    }

                    // Sessions list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Supervision Sessions")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)

                        if viewModel.sessions.isEmpty {
                            Text("No supervision sessions yet")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(viewModel.sessions) { session in
                                    if let supervisor = viewModel.getSupervisor(id: session.supervisorId) {
                                        SessionListItemView(
                                            session: session,
                                            supervisorName: supervisor.name
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)

                    Spacer()
                }
                .padding(0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appMain)
        .task {
            await viewModel.loadSessionsForTopic(topic)
            await viewModel.loadSupervisors()
        }
    }

    private var detailView: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Related Supervisors")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appText)

                if topic.relatedSupervisorIds.isEmpty {
                    Text("No supervisors assigned")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(topic.relatedSupervisorIds, id: \.self) { supervisorId in
                            if let supervisor = viewModel.getSupervisor(id: supervisorId) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.appInfo)
                                    Text(supervisor.name)
                                        .font(.subheadline)
                                        .foregroundColor(.appText)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
    }

    private var editingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Topic Name")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)
                TextField("Topic name", text: $editedName)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Related Supervisors")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.supervisors) { supervisor in
                        Toggle(supervisor.name, isOn: Binding(
                            get: { editedSupervisorIds.contains(supervisor.id) },
                            set: { isSelected in
                                if isSelected {
                                    editedSupervisorIds.append(supervisor.id)
                                } else {
                                    editedSupervisorIds.removeAll { $0 == supervisor.id }
                                }
                            }
                        ))
                    }
                }
            }

            HStack {
                Button("Cancel") { isEditing = false }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Save") { saveChanges() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
    }

    private func startEditing() {
        editedName = topic.name
        editedSupervisorIds = topic.relatedSupervisorIds
        isEditing = true
    }

    private func saveChanges() {
        var updated = topic
        updated.name = editedName
        updated.relatedSupervisorIds = editedSupervisorIds

        Task {
            try await viewModel.updateTopic(updated)
            isEditing = false
        }
    }
}

#Preview {
    Group {
        if let service = try? JSONPersistenceService() {
            TopicDetailView(
                viewModel: TopicListViewModel(persistenceService: service),
                topic: Topic(name: "Thesis Research", relatedSupervisorIds: [])
            )
        } else {
            Text("Failed to create JSONPersistenceService for preview.")
        }
    }
}
