import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var navigateToDate: Date?

    var body: some View {
        TabView(selection: $selectedTab) {
            JournalView(navigateToDate: $navigateToDate)
                .tabItem {
                    Label("Today", systemImage: "book.closed")
                }
                .tag(0)

            CalendarView(navigateToDate: $navigateToDate, selectedTab: $selectedTab)
                .tabItem {
                    Label("Reflections", systemImage: "calendar")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .tint(Theme.Palette.ink)
        .onChange(of: navigateToDate) { _, newDate in
            if newDate != nil {
                selectedTab = 0
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Question.self, JournalEntry.self], inMemory: true)
}
