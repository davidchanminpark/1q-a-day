import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CalendarViewModel()
    @Binding var navigateToDate: Date?
    @Binding var selectedTab: Int

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Palette.background.ignoresSafeArea()

                VStack(spacing: Theme.Spacing.lg) {
                    header

                    monthNavigation

                    weekdayHeader

                    calendarGrid

                    Spacer()

                    streakFooter
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.md)
            }
            .navigationTitle("Reflections")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("Reflections")
                .font(Theme.Fonts.cursive(38))
                .foregroundStyle(Theme.Palette.accent)

            Text("A record of your days")
                .font(Theme.Fonts.serif(12))
                .italic()
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(Theme.Palette.muted)
        }
        .padding(.top, Theme.Spacing.sm)
    }

    private var monthNavigation: some View {
        HStack {
            Button(action: { viewModel.goToPreviousMonth() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(viewModel.canGoToPreviousMonth ? Theme.Palette.ink : Theme.Palette.muted.opacity(0.3))
            }
            .disabled(!viewModel.canGoToPreviousMonth)

            Spacer()

            Text(viewModel.monthYearText)
                .font(Theme.Fonts.serif(22))
                .italic()
                .foregroundStyle(Theme.Palette.ink)

            Spacer()

            Button(action: { viewModel.goToNextMonth() }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(viewModel.canGoToNextMonth ? Theme.Palette.ink : Theme.Palette.muted.opacity(0.3))
            }
            .disabled(!viewModel.canGoToNextMonth)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.top, Theme.Spacing.sm)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(weekdays.enumerated()), id: \.offset) { _, day in
                Text(day)
                    .font(Theme.Fonts.serif(11))
                    .italic()
                    .tracking(1)
                    .foregroundStyle(Theme.Palette.muted)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<(viewModel.firstWeekday - 1), id: \.self) { _ in
                Color.clear.frame(height: 44)
            }

            ForEach(1...viewModel.daysInMonth, id: \.self) { day in
                CalendarDay(
                    day: day,
                    isToday: viewModel.isToday(day: day),
                    hasEntry: viewModel.hasEntry(day: day)
                ) {
                    if let date = viewModel.selectDate(day: day) {
                        navigateToDate = date
                    }
                }
            }
        }
    }

    // MARK: - Streak messages

    private static let streakMessages: [(Int) -> String] = [
        { n in "You've been writing for \(n) day\(n == 1 ? "" : "s") straight. Good work." },
        { n in "That's \(n) day\(n == 1 ? "" : "s") in a row. Keep it going." },
        { n in "\(n) day\(n == 1 ? "" : "s") and counting. You're building something real." },
        { n in "A \(n)-day streak. Future you will be grateful." },
        { n in "You've shown up \(n) day\(n == 1 ? "" : "s") in a row. That's not nothing." },
        { n in "\(n) consecutive day\(n == 1 ? "" : "s") of reflection. Quiet, steady work." },
        { n in "Day \(n) of your streak. Don't break the chain." },
        { n in "You've written every day for \(n) day\(n == 1 ? "" : "s"). Lovely." },
    ]

    private static let emptyStreakMessages: [String] = [
        "I wish you had been writing journal entries.",
        "No streak yet — today is a good day to start.",
        "Your streak is waiting to begin.",
        "Every great streak starts with a single entry.",
        "No days in a row yet. Write something today.",
    ]

    private var streakMessage: String {
        let streak = viewModel.currentStreak
        let index = Date().dayOfYear
        if streak == 0 {
            return Self.emptyStreakMessages[index % Self.emptyStreakMessages.count]
        } else {
            return Self.streakMessages[index % Self.streakMessages.count](streak)
        }
    }

    private var streakFooter: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                line
                Image(systemName: "sparkle")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.Palette.sage)
                line
            }

            Text(streakMessage)
                .font(Theme.Fonts.serif(15))
                .italic()
                .foregroundStyle(Theme.Palette.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, Theme.Spacing.md)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
    }

    private var line: some View {
        Rectangle()
            .fill(Theme.Palette.muted.opacity(0.3))
            .frame(height: 0.5)
            .frame(maxWidth: 50)
    }
}

#Preview {
    CalendarView(navigateToDate: .constant(nil), selectedTab: .constant(1))
        .modelContainer(for: [Question.self, JournalEntry.self], inMemory: true)
}
