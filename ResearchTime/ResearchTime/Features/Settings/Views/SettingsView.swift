import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var themeManager: ThemeManager
    @State private var showAddSupervisor = false
    @State private var showAddTopic = false
    @State private var selectedSupervisor: Supervisor?
    @State private var selectedTopic: Topic?
    @State private var newSupervisorName = ""
    @State private var newTopicName = ""
    @State private var selectedSupervisorIds: [UUID] = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.appTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
            .background(Color.appSecondary)
            .borderBottom(height: 1, color: .appBorder)

            // Content
            TabView {
                // Appearance Tab
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Appearance")
                            .font(.headline)
                            .foregroundColor(.appText)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                RadioButton(
                                    label: mode.label,
                                    isSelected: themeManager.appearanceMode == mode,
                                    action: { themeManager.appearanceMode = mode }
                                )
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.appSecondary.opacity(0.3))
                    .cornerRadius(8)

                    Spacer()
                }
                .padding(16)
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }

                // Supervisors Tab
                VStack(spacing: 0) {
                    HStack {
                        Text("Supervisors")
                            .font(.headline)
                            .foregroundColor(.appText)
                        Spacer()
                        Button(action: { showAddSupervisor = true }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.appInfo)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)

                    Divider()

                    ScrollView {
                        VStack(spacing: 8) {
                            if viewModel.supervisors.isEmpty {
                                Text("No supervisors yet")
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                                    .padding(16)
                            } else {
                                ForEach(viewModel.supervisors) { supervisor in
                                    supervisorRow(supervisor)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
                .tabItem {
                    Label("Supervisors", systemImage: "person.2")
                }

                // Topics Tab
                VStack(spacing: 0) {
                    HStack {
                        Text("Research Topics")
                            .font(.headline)
                            .foregroundColor(.appText)
                        Spacer()
                        Button(action: { showAddTopic = true }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.appInfo)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)

                    Divider()

                    ScrollView {
                        VStack(spacing: 8) {
                            if viewModel.topics.isEmpty {
                                Text("No topics yet")
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                                    .padding(16)
                            } else {
                                ForEach(viewModel.topics) { topic in
                                    topicRow(topic)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
                .tabItem {
                    Label("Topics", systemImage: "bookmark")
                }

                // About Tab
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.appText)

                        VStack(alignment: .leading, spacing: 8) {
                            infoRow(label: "Application", value: "Research Supervision Log")
                            infoRow(label: "Version", value: "1.0.0")
                            infoRow(label: "Platform", value: "macOS")
                        }
                    }
                    .padding(16)
                    .background(Color.appSecondary.opacity(0.3))
                    .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data Storage")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)

                        Text("All data is stored locally in your Application Support directory.")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                            .lineLimit(3)
                    }
                    .padding(16)
                    .background(Color.appSecondary.opacity(0.3))
                    .cornerRadius(8)

                    Spacer()
                }
                .padding(16)
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
            }
            .tabViewStyle(.automatic)
        }
        .frame(minWidth: 500, minHeight: 500)
        .background(Color.appMain)
        .task {
            await viewModel.loadData()
        }
        .sheet(isPresented: $showAddSupervisor) {
            AddSupervisorSheet(
                isPresented: $showAddSupervisor,
                persistenceService: viewModel.persistenceService,
                onSaved: {
                    Task { await viewModel.loadData() }
                }
            )
        }
        .sheet(isPresented: $showAddTopic) {
            AddTopicSheet(
                isPresented: $showAddTopic,
                supervisors: viewModel.supervisors,
                persistenceService: viewModel.persistenceService,
                onSaved: {
                    Task { await viewModel.loadData() }
                }
            )
        }
    }

    private func supervisorRow(_ supervisor: Supervisor) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(supervisor.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appText)
            if let email = supervisor.email {
                Text(email)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.appSecondary.opacity(0.3))
        .cornerRadius(6)
    }

    private func topicRow(_ topic: Topic) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(topic.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appText)
            Text("\(topic.relatedSupervisorIds.count) supervisor(s)")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.appSecondary.opacity(0.3))
        .cornerRadius(6)
    }

    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.appTextSecondary)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.appText)
        }
    }
}

struct RadioButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .appInfo : .appTextSecondary)
                Text(label)
                    .foregroundColor(.appText)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct AddSupervisorSheet: View {
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var department = ""
    let persistenceService: PersistenceService
    let onSaved: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Add New Supervisor")
                .font(.headline)
                .foregroundColor(.appText)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name *").font(.caption).fontWeight(.semibold).foregroundColor(.appText)
                    TextField("Name", text: $name).textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email").font(.caption).fontWeight(.semibold).foregroundColor(.appText)
                    TextField("Email (optional)", text: $email).textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Phone").font(.caption).fontWeight(.semibold).foregroundColor(.appText)
                    TextField("Phone (optional)", text: $phone).textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Department").font(.caption).fontWeight(.semibold).foregroundColor(.appText)
                    TextField("Department (optional)", text: $department).textFieldStyle(.roundedBorder)
                }
            }

            HStack {
                Button("Cancel") { isPresented = false }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Add") {
                    let supervisor = Supervisor(
                        name: name,
                        email: email.isEmpty ? nil : email,
                        phone: phone.isEmpty ? nil : phone,
                        department: department.isEmpty ? nil : department
                    )
                    Task {
                        try persistenceService.createSupervisor(supervisor)
                        await MainActor.run {
                            onSaved()
                            isPresented = false
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding(20)
        .background(Color.appMain)
    }
}

struct AddTopicSheet: View {
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var selectedSupervisorIds: [UUID] = []
    let supervisors: [Supervisor]
    let persistenceService: PersistenceService
    let onSaved: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Add New Topic")
                .font(.headline)
                .foregroundColor(.appText)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Topic Name *").font(.caption).fontWeight(.semibold).foregroundColor(.appText)
                    TextField("Name", text: $name).textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Related Supervisors").font(.caption).fontWeight(.semibold).foregroundColor(.appText)
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(supervisors) { supervisor in
                            Toggle(supervisor.name, isOn: Binding(
                                get: { selectedSupervisorIds.contains(supervisor.id) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedSupervisorIds.append(supervisor.id)
                                    } else {
                                        selectedSupervisorIds.removeAll { $0 == supervisor.id }
                                    }
                                }
                            ))
                        }
                    }
                }
            }

            HStack {
                Button("Cancel") { isPresented = false }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Add") {
                    let topic = Topic(name: name, relatedSupervisorIds: selectedSupervisorIds)
                    Task {
                        try persistenceService.createTopic(topic)
                        await MainActor.run {
                            onSaved()
                            isPresented = false
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding(20)
        .background(Color.appMain)
    }
}

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(persistenceService: try! JSONPersistenceService()),
        themeManager: ThemeManager()
    )
}
