import SwiftUI

struct StartPageView: View {
    @ObservedObject var viewModel: StartPageViewModel
    var onAddSupervisionSession: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "book.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.appInfo)

                VStack(spacing: 8) {
                    Text("Research Supervision Log")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)

                    Text("Capture and review your supervision sessions in one place")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            VStack(spacing: 12) {
                Button(action: { onAddSupervisionSession?() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Supervision Session")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.appInfo)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: [.command])

                Text("Keyboard Shortcut: ⌘N")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Text("Tips")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appText)

                VStack(alignment: .leading, spacing: 8) {
                    tipItem("⌃⇧Q", "Add a new question")
                    tipItem("⌃⇧K", "Add a keyword")
                    tipItem("⌃⇧I", "Add an action item")
                    tipItem("⌃⇧N", "Focus notes editor")
                }
            }
            .padding(16)
            .background(Color.appHighlight.opacity(0.2))
            .cornerRadius(8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appMain)
    }

    private func tipItem(_ shortcut: String, _ description: String) -> some View {
        HStack(spacing: 12) {
            Text(shortcut)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.appInfo)
                .frame(width: 50, alignment: .leading)
            Text(description)
                .font(.caption)
                .foregroundColor(.appText)
            Spacer()
        }
    }
}

#Preview {
    StartPageView(
        viewModel: StartPageViewModel(persistenceService: try! JSONPersistenceService())
    )
}
