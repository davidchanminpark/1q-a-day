import Foundation
import SwiftData
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var daysWithEntries: Set<Int> = []
    @Published var selectedDate: Date?

    private var dataService: DataService?

    var monthYearText: String {
        currentMonth.monthYearFormatted
    }

    var daysInMonth: Int {
        currentMonth.numberOfDaysInMonth
    }

    var firstWeekday: Int {
        currentMonth.firstWeekdayOfMonth
    }

    var year: Int {
        currentMonth.year
    }

    var month: Int {
        currentMonth.month
    }

    var canGoToPreviousMonth: Bool {
        let today = Date()
        return !(year == today.year && month == 1)
    }

    var canGoToNextMonth: Bool {
        let today = Date()
        return !(year == today.year && month == today.month)
    }

    var currentStreak: Int {
        dataService?.getCurrentStreak() ?? 0
    }

    func setup(modelContext: ModelContext) {
        self.dataService = DataService(modelContext: modelContext)
        loadMonthData()
    }

    func loadMonthData() {
        guard let dataService = dataService else { return }
        daysWithEntries = dataService.getDaysWithEntries(year: year, month: month)
    }

    func goToPreviousMonth() {
        guard canGoToPreviousMonth else { return }
        currentMonth = currentMonth.adding(months: -1)
        loadMonthData()
    }

    func goToNextMonth() {
        guard canGoToNextMonth else { return }
        currentMonth = currentMonth.adding(months: 1)
        loadMonthData()
    }

    func selectDate(day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)
    }

    func isToday(day: Int) -> Bool {
        let today = Date()
        return today.year == year && today.month == month && today.day == day
    }

    func hasEntry(day: Int) -> Bool {
        daysWithEntries.contains(day)
    }
}
