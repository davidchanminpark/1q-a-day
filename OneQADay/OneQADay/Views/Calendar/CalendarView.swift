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

    private var streakFooter: some View {
        VStack(spacing: 4) {
            Text("The Streak")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            if viewModel.currentStreak == 0 {
                Text("I wish you had been writing journal entries")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("\(viewModel.currentStreak) day\(viewModel.currentStreak == 1 ? "" : "s")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
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
