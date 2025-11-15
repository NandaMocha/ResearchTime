import SwiftUI

enum AppearanceMode: String, Codable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var label: String {
        switch self {
        case .system:
            return "System Default"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var appearanceMode: AppearanceMode = .system {
        didSet {
            saveAppearanceMode()
            updateAppearance()
        }
    }

    private let appearanceModeKey = "AppearanceMode"

    init() {
        loadAppearanceMode()
        updateAppearance()
    }

    private func loadAppearanceMode() {
        if let savedMode = UserDefaults.standard.string(forKey: appearanceModeKey),
           let mode = AppearanceMode(rawValue: savedMode) {
            appearanceMode = mode
        }
    }

    private func saveAppearanceMode() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceModeKey)
    }

    private func updateAppearance() {
        NSAppearance.current = makeAppearance()
    }

    private func makeAppearance() -> NSAppearance {
        switch appearanceMode {
        case .system:
            return NSAppearance(named: .aqua) ?? .current
        case .light:
            return NSAppearance(named: .aqua) ?? .current
        case .dark:
            return NSAppearance(named: .darkAqua) ?? .current
        }
    }
}

// MARK: - Color Palette
extension Color {
    static let appMain = Color(red: 0.188, green: 0.212, blue: 0.278)      // #313647
    static let appSecondary = Color(red: 0.263, green: 0.337, blue: 0.388) // #435663
    static let appInfo = Color(red: 0.639, green: 0.690, blue: 0.529)      // #A3B087
    static let appHighlight = Color(red: 1.0, green: 0.973, blue: 0.831)   // #FFF8D4

    static let appText = Color(white: 0.95)
    static let appTextSecondary = Color(white: 0.7)
    static let appBorder = Color(white: 0.2)

    static let appLightMain = Color(red: 0.95, green: 0.95, blue: 0.96)
    static let appLightSecondary = Color(red: 0.98, green: 0.98, blue: 0.99)
    static let appLightText = Color(white: 0.1)
    static let appLightTextSecondary = Color(white: 0.35)
}
