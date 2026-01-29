import Foundation
import SwiftData

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

    func setup(modelContext: ModelContext) {
        self.dataService = DataService(modelContext: modelContext)
        loadMonthData()
    }

    func loadMonthData() {
        guard let dataService = dataService else { return }
        daysWithEntries = dataService.getDaysWithEntries(year: year, month: month)
    }

    func goToPreviousMonth() {
        currentMonth = currentMonth.adding(months: -1)
        loadMonthData()
    }

    func goToNextMonth() {
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
