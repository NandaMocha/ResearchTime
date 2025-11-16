import SwiftUI

struct SupervisorDetailView: View {
    @ObservedObject var viewModel: SupervisorListViewModel
    let supervisor: Supervisor
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var editedPhone = ""
    @State private var editedDepartment = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(supervisor.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        if let department = supervisor.department {
                            Text(department)
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        }
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

            Divider()
                .frame(height: 1)
                .foregroundColor(.appBorder)

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
                                    SessionListItemView(
                                        session: session,
                                        supervisorName: supervisor.name
                                    )
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
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await viewModel.loadSessionsForSupervisor(supervisor)
        }
    }

    private var detailView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let email = supervisor.email {
                infoRow(label: "Email", value: email)
            }
            if let phone = supervisor.phone {
                infoRow(label: "Phone", value: phone)
            }
            if let department = supervisor.department {
                infoRow(label: "Department", value: department)
            }
        }
        .padding(16)
    }

    private var editingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Name")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)
                TextField("Name", text: $editedName)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Email")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)
                TextField("Email (optional)", text: $editedEmail)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Phone")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)
                TextField("Phone (optional)", text: $editedPhone)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Department")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)
                TextField("Department (optional)", text: $editedDepartment)
                    .textFieldStyle(.roundedBorder)
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

    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.appTextSecondary)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.appText)
        }
    }

    private func startEditing() {
        editedName = supervisor.name
        editedEmail = supervisor.email ?? ""
        editedPhone = supervisor.phone ?? ""
        editedDepartment = supervisor.department ?? ""
        isEditing = true
    }

    private func saveChanges() {
        // Validate required fields
        guard !editedName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Supervisor name cannot be empty"
            showErrorAlert = true
            return
        }

        // Validate email format if provided
        if !editedEmail.isEmpty {
            let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
            let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
            guard emailPredicate.evaluate(with: editedEmail) else {
                errorMessage = "Invalid email format"
                showErrorAlert = true
                return
            }
        }

        var updated = supervisor
        updated.name = editedName
        updated.email = editedEmail.isEmpty ? nil : editedEmail
        updated.phone = editedPhone.isEmpty ? nil : editedPhone
        updated.department = editedDepartment.isEmpty ? nil : editedDepartment

        Task { @MainActor in
            do {
                try await viewModel.updateSupervisor(updated)
                isEditing = false
            } catch {
                errorMessage = "Failed to update supervisor: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    Group {
        if let service = try? JSONPersistenceService() {
            SupervisorDetailView(
                viewModel: SupervisorListViewModel(persistenceService: service),
                supervisor: Supervisor(name: "Prof. Dr. Smith", email: "smith@university.edu", department: "Computer Science")
            )
        } else {
            Text("Failed to create JSONPersistenceService for preview.")
        }
    }
}
