import SwiftUI

struct ContentView: View {
    @StateObject private var persistenceService: JSONPersistenceService
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var sidebarVM: SidebarViewModel
    @StateObject private var topicListVM: TopicListViewModel
    @StateObject private var startPageVM: StartPageViewModel
    @StateObject private var supervisorListVM: SupervisorListViewModel
    @StateObject private var settingsVM: SettingsViewModel

    @State private var selectedTopic: Topic?
    @State private var showNewSupervisionForm = false
    @State private var showSettings = false
    @State private var sidebarCollapsed = false

    init(persistenceService: JSONPersistenceService) {
        _persistenceService = StateObject(wrappedValue: persistenceService)
        _sidebarVM = StateObject(wrappedValue: SidebarViewModel(persistenceService: persistenceService))
        _topicListVM = StateObject(wrappedValue: TopicListViewModel(persistenceService: persistenceService))
        _startPageVM = StateObject(wrappedValue: StartPageViewModel(persistenceService: persistenceService))
        _supervisorListVM = StateObject(wrappedValue: SupervisorListViewModel(persistenceService: persistenceService))
        _settingsVM = StateObject(wrappedValue: SettingsViewModel(persistenceService: persistenceService))
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Sidebar
                if !sidebarCollapsed {
                    SidebarView(
                        viewModel: sidebarVM,
                        selectedTopic: $selectedTopic,
                        showSettings: $showSettings
                    )
                    .transition(.move(edge: .leading))
                }

                VStack(spacing: 0) {
                    // Toolbar
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Button(action: { withAnimation { sidebarCollapsed.toggle() } }) {
                                Image(systemName: sidebarCollapsed ? "sidebar.right" : "sidebar.left")
                                    .font(.body)
                                    .foregroundColor(.appInfo)
                            }
                            .buttonStyle(.plain)

                            Text("Research Supervision Log")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.appText)

                            Spacer()

                            Button(action: { showNewSupervisionForm = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Session")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.appInfo)
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .keyboardShortcut("n", modifiers: [.command])
                        }
                        .padding(12)
                        .background(Color.appSecondary)
                    }

                    // Main content
                    Group {
                        if showSettings {
                            SettingsView(
                                viewModel: settingsVM,
                                themeManager: themeManager
                            )
                        } else if let topic = selectedTopic {
                            TopicDetailView(
                                viewModel: topicListVM,
                                topic: topic
                            )
                        } else {
                            StartPageView(
                                viewModel: startPageVM,
                                onAddSupervisionSession: { showNewSupervisionForm = true }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color.appMain)
            }
            .background(Color.appMain)
            .environmentObject(themeManager)

            // Modal sheet for new supervision form
            if showNewSupervisionForm {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showNewSupervisionForm = false
                        }

                    SupervisionFormView(
                        viewModel: SupervisionFormViewModel(persistenceService: persistenceService),
                        isPresented: $showNewSupervisionForm
                    )
                }
            }
        }
    }
}

#Preview {
    if let service = try? JSONPersistenceService() {
        ContentView(persistenceService: service)
            .preferredColorScheme(.dark)
    } else {
        Text("Failed to create JSONPersistenceService for preview.")
    }
}
