import SwiftUI

@main
struct ResearchSupervisionLogApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(colorScheme)
        }
        .windowStyle(.hiddenTitleBar)
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
}
