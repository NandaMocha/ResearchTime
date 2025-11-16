import SwiftUI

struct SupervisionFormView: View {
    @ObservedObject var viewModel: SupervisionFormViewModel
    @Binding var isPresented: Bool
    @FocusState private var focusedField: FormField?
    @State private var showFilePicker = false

    enum FormField {
        case keywords
        case notes
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Text(viewModel.isEditMode ? "Edit Supervision Session" : "New Supervision Session")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.appTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
            .background(Color.appSecondary)

            // Form content
            ScrollView {
                VStack(spacing: 20) {
                    // Date & Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date & Time")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                        DatePicker(
                            "",
                            selection: $viewModel.session.dateTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        .tint(.appInfo)
                    }

                    // Supervisor
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Supervisor *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                        HStack(spacing: 8) {
                            Picker("Supervisor", selection: $viewModel.session.supervisorId) {
                                Text("Select a supervisor").tag(nil as UUID?)
                                ForEach(viewModel.supervisors) { supervisor in
                                    Text(supervisor.name).tag(supervisor.id as UUID?)
                                }
                            }
                            .frame(maxWidth: .infinity)

                            Button(action: { viewModel.showAddSupervisor = true }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.appInfo)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if viewModel.showAddSupervisor {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Supervisor Name")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                            TextField("Name", text: $viewModel.newSupervisorName)
                                .textFieldStyle(.roundedBorder)
                            HStack {
                                Button("Cancel") { viewModel.showAddSupervisor = false }
                                    .buttonStyle(.bordered)
                                Button("Add") {
                                    Task {
                                        try await viewModel.addNewSupervisor()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(12)
                        .background(Color.appSecondary.opacity(0.5))
                        .cornerRadius(6)
                    }

                    // Topic
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Research Topic *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                        HStack(spacing: 8) {
                            Picker("Topic", selection: $viewModel.session.topicId) {
                                Text("Select a topic").tag(nil as UUID?)
                                ForEach(viewModel.topics) { topic in
                                    Text(topic.name).tag(topic.id as UUID?)
                                }
                            }
                            .frame(maxWidth: .infinity)

                            Button(action: { viewModel.showAddTopic = true }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.appInfo)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if viewModel.showAddTopic {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Topic Name")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                            TextField("Name", text: $viewModel.newTopicName)
                                .textFieldStyle(.roundedBorder)

                            Text("Related Supervisors (optional)")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(viewModel.supervisors) { supervisor in
                                    Toggle(supervisor.name, isOn: Binding(
                                        get: { viewModel.selectedSupervisors.contains(supervisor.id) },
                                        set: { isSelected in
                                            if isSelected {
                                                viewModel.selectedSupervisors.append(supervisor.id)
                                            } else {
                                                viewModel.selectedSupervisors.removeAll { $0 == supervisor.id }
                                            }
                                        }
                                    ))
                                }
                            }

                            HStack {
                                Button("Cancel") { viewModel.showAddTopic = false }
                                    .buttonStyle(.bordered)
                                Button("Add") {
                                    Task {
                                        try await viewModel.addNewTopic()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(12)
                        .background(Color.appSecondary.opacity(0.5))
                        .cornerRadius(6)
                    }

                    // Session Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session Title")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                        TextField("e.g., Thesis outline review", text: $viewModel.session.title)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Keywords
                    TagInputView(tags: $viewModel.session.keywords)
                        .focused($focusedField, equals: .keywords)

                    // Questions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Questions")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.appText)
                            Spacer()
                            Button(action: { viewModel.addQuestion() }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.appInfo)
                            }
                            .buttonStyle(.plain)
                        }

                        if viewModel.session.questions.isEmpty {
                            Text("No questions yet")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        } else {
                            ForEach(Array(viewModel.session.questions.enumerated()), id: \.element.id) { index, _ in
                                QuestionItemView(
                                    question: $viewModel.session.questions[index],
                                    onRemove: { viewModel.removeQuestion(at: index) }
                                )
                            }
                        }
                    }

                    // Action Items
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Action Items")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.appText)
                            Spacer()
                            Button(action: { viewModel.addActionItem() }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.appInfo)
                            }
                            .buttonStyle(.plain)
                        }

                        if viewModel.session.actionItems.isEmpty {
                            Text("No action items yet")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        } else {
                            ForEach(Array(viewModel.session.actionItems.enumerated()), id: \.element.id) { index, _ in
                                ActionItemView(
                                    actionItem: $viewModel.session.actionItems[index],
                                    onRemove: { viewModel.removeActionItem(at: index) }
                                )
                            }
                        }
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                        RichTextEditorView(
                            text: $viewModel.session.notesRichText,
                            placeholder: "Type your supervision notes here…"
                        )
                        .focused($focusedField, equals: .notes)
                    }

                    // Recording File
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recording File")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                        HStack {
                            Text(viewModel.session.recordingPath ?? "No file selected")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                                .lineLimit(1)
                            Spacer()
                            Button(action: { showFilePicker = true }) {
                                Text("Choose")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    Spacer()
                        .frame(height: 20)
                }
                .padding(20)
            }

            // Footer with buttons
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Save") {
                        Task {
                            try await viewModel.saveSession()
                            await MainActor.run {
                                isPresented = false
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(16)
            }
            .background(Color.appSecondary.opacity(0.3))
        }
        .frame(minWidth: 600, minHeight: 800)
        .background(Color.appMain)
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.audio, .video, .item],
            onCompletion: { result in
                switch result {
                case .success(let url):
                    viewModel.session.recordingPath = url.path
                case .failure(let error):
                    print("Error selecting file: \(error)")
                }
            }
        )
        .task {
            await viewModel.loadData()
        }
    }
}

struct QuestionItemView: View {
    @Binding var question: Question
    var onRemove: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Question")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Button(action: { onRemove?() }) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }

            TextField("Question text", text: $question.questionText)
                .textFieldStyle(.roundedBorder)

            TextField("Answer (optional)", text: Binding(
                get: { question.answerText ?? "" },
                set: { question.answerText = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)
        }
        .padding(12)
        .background(Color.appSecondary.opacity(0.3))
        .cornerRadius(6)
    }
}

struct ActionItemView: View {
    @Binding var actionItem: ActionItem
    var onRemove: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Action Item")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Button(action: { onRemove?() }) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }

            TextField("Action item text", text: $actionItem.itemText)
                .textFieldStyle(.roundedBorder)

            TextField("Notes (optional)", text: Binding(
                get: { actionItem.notes ?? "" },
                set: { actionItem.notes = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)
        }
        .padding(12)
        .background(Color.appSecondary.opacity(0.3))
        .cornerRadius(6)
    }
}

extension View {
    func borderBottom(height: CGFloat, color: Color) -> some View {
        VStack(spacing: 0) {
            self
            Divider().frame(height: height).foregroundColor(color)
        }
    }
}
