import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: SidebarViewModel
    @Binding var selectedTopic: Topic?
    @Binding var showSettings: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Topics list
            VStack(alignment: .leading, spacing: 12) {
                Text("Topics")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appText)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.topics) { topic in
                            Button(action: {
                                selectedTopic = topic
                            }) {
                                HStack {
                                    Text(topic.name)
                                        .font(.subheadline)
                                        .foregroundColor(selectedTopic?.id == topic.id ? .appHighlight : .appText)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .background(selectedTopic?.id == topic.id ? Color.appInfo.opacity(0.3) : Color.clear)
                            .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding(.bottom, 12)

            Divider()

            // Settings
            VStack(alignment: .leading, spacing: 8) {
                Button(action: { showSettings = true }) {
                    HStack {
                        Image(systemName: "gear")
                            .font(.subheadline)
                        Text("Settings")
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundColor(.appText)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(showSettings ? Color.appInfo.opacity(0.3) : Color.clear)
                .cornerRadius(4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)

            Spacer()
        }
        .frame(minWidth: 180, maxWidth: 250)
        .background(Color.appSecondary)
        .task {
            await viewModel.loadTopics()
        }
    }
}

class SidebarViewModel: ObservableObject {
    @Published var topics: [Topic] = []
    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }

    @MainActor
    func loadTopics() async {
        do {
            topics = try persistenceService.fetchAllTopics()
        } catch {
            print("Error loading topics: \(error)")
        }
    }
}
