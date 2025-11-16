import SwiftUI
import AppKit

struct RichTextEditorView: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .font(.body)
                    .foregroundColor(.appTextSecondary)
                    .padding(8)
                    .allowsHitTesting(false)
            }

            // Rich text editor with formatting toolbar
            VStack(spacing: 0) {
                RichTextToolbar(text: $text)

                RichTextViewRepresentable(text: $text)
                    .frame(minHeight: 200)
            }
        }
        .border(Color.appBorder, width: 1)
        .cornerRadius(6)
    }
}

struct RichTextToolbar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Group {
                Button(action: { applyBold() }) {
                    Image(systemName: "bold")
                        .font(.system(size: 12, weight: .semibold))
                }
                Button(action: { applyItalic() }) {
                    Image(systemName: "italic")
                        .font(.system(size: 12, weight: .semibold))
                }
                Button(action: { applyUnderline() }) {
                    Image(systemName: "underline")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.appInfo)

            Divider()

            Group {
                Button(action: { insertBulletList() }) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 12, weight: .semibold))
                }
                Button(action: { insertNumberedList() }) {
                    Image(systemName: "list.number")
                        .font(.system(size: 12, weight: .semibold))
                }
                Button(action: { insertChecklist() }) {
                    Image(systemName: "checklist")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.appInfo)

            Spacer()
        }
        .padding(8)
        .background(Color.appSecondary.opacity(0.5))
    }

    private func applyBold() {
        // Placeholder for formatting logic
    }

    private func applyItalic() {
        // Placeholder for formatting logic
    }

    private func applyUnderline() {
        // Placeholder for formatting logic
    }

    private func insertBulletList() {
        text += "\n• "
    }

    private func insertNumberedList() {
        text += "\n1. "
    }

    private func insertChecklist() {
        text += "\n☐ "
    }
}

struct RichTextViewRepresentable: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.string = text
        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.allowsUndo = true
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        if nsView.string != text {
            nsView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text = textView.string
        }
    }
}
