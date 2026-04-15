//
//  OneQADayApp.swift
//  OneQADay
//
//  Created by Chanmin Park on 1/28/26.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct OneQADayApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Question.self,
            JournalEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }

    private func configureAppearance() {
        let ink = UIColor(red: 68/255, green: 42/255, blue: 34/255, alpha: 1)
        let muted = UIColor(red: 118/255, green: 96/255, blue: 87/255, alpha: 1)
        let bg = UIColor(red: 254/255, green: 249/255, blue: 242/255, alpha: 1)

        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = bg
        navAppearance.shadowColor = .clear
        navAppearance.titleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont(name: "NewYork-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont(name: "NewYork-Regular", size: 34) ?? UIFont.boldSystemFont(ofSize: 34)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        // Tab bar appearance is controlled per-view via SwiftUI's
        // .toolbarBackground modifiers (see JournalView, CalendarView,
        // SettingsView). iOS 26's Liquid Glass tab bar ignores most
        // UITabBarAppearance settings, so we rely on SwiftUI instead.
    }
}
