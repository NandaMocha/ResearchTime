//
//  ResearchTimeApp.swift
//  ResearchTime
//
//  Created by Nanda Mochammad on 16/11/25.
//

import SwiftUI

@main
struct ResearchTimeApp: App {
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
