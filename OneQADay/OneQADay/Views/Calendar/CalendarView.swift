import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CalendarViewModel()
    @Binding var navigateToDate: Date?
    @Binding var selectedTab: Int

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                monthNavigation

                weekdayHeader

                calendarGrid

                Spacer()

                streakFooter
            }
            .padding()
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }

    private var monthNavigation: some View {
        HStack {
            Button(action: { viewModel.goToPreviousMonth() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(viewModel.canGoToPreviousMonth ? .primary : .tertiary)
            }
            .disabled(!viewModel.canGoToPreviousMonth)

            Spacer()

            Text(viewModel.monthYearText)
                .font(.headline)

            Spacer()

            Button(action: { viewModel.goToNextMonth() }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(viewModel.canGoToNextMonth ? .primary : .tertiary)
            }
            .disabled(!viewModel.canGoToNextMonth)
        }
        .padding(.horizontal)
    }

    private static let streakMessages: [(Int) -> String] = [
        { n in "You've been writing for \(n) day\(n == 1 ? "" : "s") straight. Good job." },
        { n in "That's \(n) day\(n == 1 ? "" : "s") in a row. Keep it going." },
        { n in "\(n) day\(n == 1 ? "" : "s") and counting. You're building something real." },
        { n in "A \(n)-day streak. Future you will be grateful." },
        { n in "You've shown up \(n) day\(n == 1 ? "" : "s") in a row. That's not nothing." },
        { n in "\(n) consecutive day\(n == 1 ? "" : "s") of reflection. Nice work." },
        { n in "Day \(n) of your streak. Don't break the chain." },
        { n in "You've written every day for \(n) day\(n == 1 ? "" : "s"). Impressive." },
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
        // Use today's day-of-year to pick a message so it's stable within a day
        let index = Date().dayOfYear
        if streak == 0 {
            return Self.emptyStreakMessages[index % Self.emptyStreakMessages.count]
        } else {
            return Self.streakMessages[index % Self.streakMessages.count](streak)
        }
    }

    private var streakFooter: some View {
        VStack(spacing: 4) {
            Text(streakMessage)
                .font(.subheadline)
                .foregroundStyle(viewModel.currentStreak == 0 ? .secondary : .primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            // Empty cells for days before the first of the month
            ForEach(0..<(viewModel.firstWeekday - 1), id: \.self) { _ in
                Color.clear
                    .frame(height: 44)
            }

            // Days of the month
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
}

#Preview {
    CalendarView(navigateToDate: .constant(nil), selectedTab: .constant(1))
        .modelContainer(for: [Question.self, JournalEntry.self], inMemory: true)
}
