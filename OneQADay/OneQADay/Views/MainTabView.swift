import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var isKeyboardVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                JournalView()
                    .tag(0)
                    .toolbar(.hidden, for: .tabBar)

                CalendarView()
                    .tag(1)
                    .toolbar(.hidden, for: .tabBar)

                SettingsView()
                    .tag(2)
                    .toolbar(.hidden, for: .tabBar)
            }

            if !isKeyboardVisible {
                CustomTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isKeyboardVisible)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Question.self, JournalEntry.self], inMemory: true)
}
