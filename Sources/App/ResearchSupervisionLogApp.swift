import SwiftUI
import AppKit

@main
struct ResearchSupervisionLogApp: App {
    @StateObject private var themeManager = ThemeManager()
    @State private var persistenceService: JSONPersistenceService?
    @State private var initializationError: String?

    var body: some Scene {
        WindowGroup {
            Group {
                if let persistenceService = persistenceService {
                    ContentView(persistenceService: persistenceService)
                        .environmentObject(themeManager)
                        .preferredColorScheme(colorScheme)
                } else if let error = initializationError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text("Failed to Initialize")
                            .font(.headline)
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                        Button("Quit") {
                            NSApplication.shared.terminate(nil)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.controlBackgroundColor))
                } else {
                    VStack {
                        ProgressView()
                        Text("Initializing...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.controlBackgroundColor))
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .onAppear {
            initializePersistence()
        }
    }

    private var colorScheme: ColorScheme? {
        switch themeManager.appearanceMode {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    private func initializePersistence() {
        do {
            persistenceService = try JSONPersistenceService()
        } catch {
            initializationError = error.localizedDescription
        }
    }
}
