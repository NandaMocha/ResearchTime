import SwiftUI

struct SessionListItemView: View {
    let session: SupervisionSession
    let supervisorName: String
    var onEdit: (() -> Void)?
    var onHide: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title and supervisor
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title.isEmpty ? "Untitled Session" : session.title)
                        .font(.headline)
                        .foregroundColor(.appText)

                    Text("Supervisor: \(supervisorName)")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                Spacer()
                Menu {
                    Button("Edit Session", action: { onEdit?() })
                    Button("Hide Session", role: .destructive, action: { onHide?() })
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.appInfo)
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
            }

            // Date and time
            Text(session.dateTime.formattedDateAndTime)
                .font(.caption)
                .foregroundColor(.appTextSecondary)

            // Keywords (tags)
            if !session.keywords.isEmpty {
                TagView(tags: session.keywords)
            }

            // Question and action item counts
            HStack(spacing: 16) {
                Label(
                    countLabel(session.questions.count, singular: "question", plural: "questions"),
                    systemImage: "questionmark.circle"
                )
                .font(.caption2)
                .foregroundColor(.appInfo)

                Label(
                    countLabel(session.actionItems.count, singular: "item", plural: "items"),
                    systemImage: "checkmark.circle"
                )
                .font(.caption2)
                .foregroundColor(.appInfo)
            }

            // Notes preview
            if !session.notesRichText.isEmpty {
                Text(session.notesRichText.prefix(100) + (session.notesRichText.count > 100 ? "…" : ""))
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(Color.appSecondary.opacity(0.3))
        .cornerRadius(8)
        .onTapGesture {
            onEdit?()
        }
    }

    private func countLabel(_ count: Int, singular: String, plural: String) -> String {
        if count == 0 {
            return "0 \(plural)"
        } else if count == 1 {
            return "1 \(singular)"
        } else {
            return "\(count) \(plural)"
        }
    }
}

#Preview {
    SessionListItemView(
        session: SupervisionSession(
            title: "Thesis Review Discussion",
            supervisorId: UUID(),
            topicId: UUID(),
            keywords: ["literature", "methodology"],
            questions: [Question(), Question()],
            actionItems: [ActionItem(), ActionItem(), ActionItem()],
            notesRichText: "Discussed the thesis outline and reviewed recent literature findings. Supervisor suggested some additional sources to explore."
        ),
        supervisorName: "Prof. Dr. Smith"
    )
    .padding()
    .background(Color.appMain)
    .environment(\.colorScheme, .dark)
}
