import SwiftUI

struct TagView: View {
    let tags: [String]
    var onRemove: ((String) -> Void)? = nil
    let maxTagsToShow = 3

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(tags.prefix(maxTagsToShow)), id: \.self) { tag in
                tagItem(tag)
            }

            if tags.count > maxTagsToShow {
                Text("+\(tags.count - maxTagsToShow)")
                    .font(.caption)
                    .foregroundColor(.appInfo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appHighlight.opacity(0.3))
                    .cornerRadius(4)
            }
        }
    }

    private func tagItem(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .foregroundColor(.appInfo)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.appHighlight.opacity(0.3))
        .cornerRadius(4)
    }
}

struct TagInputView: View {
    @Binding var tags: [String]
    @State private var currentInput: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Keywords")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appText)

            // Tags display
            if !tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(.white)
                            Button(action: {
                                tags.removeAll { $0 == tag }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appInfo)
                        .cornerRadius(4)
                    }
                }
            }

            // Input field
            TextField("Add keyword (comma to add)", text: $currentInput)
                .focused($isFocused)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    addTag()
                }
                .onChange(of: currentInput) { oldValue, newValue in
                    if newValue.contains(",") {
                        let tag = newValue.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)
                        if !tag.isEmpty {
                            tags.append(tag)
                        }
                        currentInput = ""
                    }
                }
        }
    }

    private func addTag() {
        let tag = currentInput.trimmingCharacters(in: .whitespaces)
        if !tag.isEmpty && !tags.contains(tag) {
            tags.append(tag)
            currentInput = ""
        }
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 300
        var height: CGFloat = 0
        var currentLineWidth: CGFloat = 0
        var currentLineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let totalWidth = currentLineWidth + size.width + (currentLineWidth > 0 ? spacing : 0)

            if totalWidth > maxWidth && currentLineWidth > 0 {
                height += currentLineHeight + spacing
                currentLineWidth = size.width
                currentLineHeight = size.height
            } else {
                currentLineWidth = totalWidth
                currentLineHeight = max(currentLineHeight, size.height)
            }
        }

        height += currentLineHeight
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var currentLineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > bounds.maxX && x > bounds.minX {
                y += currentLineHeight + spacing
                x = bounds.minX
                currentLineHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedSize(CGSize(width: size.width, height: size.height))
            )

            x += size.width + spacing
            currentLineHeight = max(currentLineHeight, size.height)
        }
    }
}
