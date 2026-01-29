//
//  OneQADayApp.swift
//  OneQADay
//
//  Created by Chanmin Park on 1/28/26.
//

import SwiftUI
import SwiftData

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

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
