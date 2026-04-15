import Foundation
import SwiftData

@MainActor
class DataService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Questions

    func initializeQuestionsIfNeeded() {
        let descriptor = FetchDescriptor<Question>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        // Shuffle questions within each monthly bucket so each user gets a
        // unique but permanently fixed ordering.
        let monthRanges: [ClosedRange<Int>] = [
            1...31,    // January
            32...59,   // February (28 days; leap day handled separately below)
            60...90,   // March
            91...120,  // April
            121...151, // May
            152...181, // June
            182...212, // July
            213...243, // August
            244...273, // September
            274...304, // October
            305...334, // November
            335...365  // December
        ]

        let allQuestions = DefaultQuestions.questions
        for range in monthRanges {
            var bucket = Array(allQuestions[(range.lowerBound - 1)...(range.upperBound - 1)])
            bucket.shuffle()
            for (offset, day) in range.enumerated() {
                let question = Question(dayOfYear: day, text: bucket[offset], isDefault: true)
                modelContext.insert(question)
            }
        }

        // Feb 29 (slot 366): shuffle it into the February bucket so the leap
        // day question is drawn from the same pool, just randomly assigned.
        var febLeapBucket = Array(allQuestions[31...59]) // all 29 Feb questions
        febLeapBucket.shuffle()
        let leapDayQuestion = Question(dayOfYear: 366, text: febLeapBucket[0], isDefault: true)
        modelContext.insert(leapDayQuestion)

        try? modelContext.save()
    }

    func getQuestion(for dayOfYear: Int) -> Question? {
        var descriptor = FetchDescriptor<Question>(
            predicate: #Predicate { $0.dayOfYear == dayOfYear }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    func updateQuestion(_ question: Question, text: String) {
        question.text = text
        question.isDefault = false
        try? modelContext.save()
    }

    func assignRandomQuestion(for dayOfYear: Int) -> Question? {
        guard let question = getQuestion(for: dayOfYear) else { return nil }

        let allQuestions = DefaultQuestions.questions
        let randomText = allQuestions.randomElement() ?? question.text
        question.text = randomText
        question.isDefault = false
        try? modelContext.save()
        return question
    }

    // MARK: - Journal Entries

    func getEntry(for date: Date) -> JournalEntry? {
        let month = date.month
        let day = date.day
        let year = date.year

        var descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate { $0.month == month && $0.day == day && $0.year == year }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    func createOrUpdateEntry(for date: Date, answer: String, question: Question) -> JournalEntry {
        if let existingEntry = getEntry(for: date) {
            existingEntry.answer = answer
            existingEntry.updatedAt = Date()
            try? modelContext.save()
            return existingEntry
        } else {
            let entry = JournalEntry(
                date: date,
                answer: answer,
                questionText: question.text,
                question: question
            )
            modelContext.insert(entry)
            try? modelContext.save()
            return entry
        }
    }

    func getPreviousYearEntries(for date: Date) -> [JournalEntry] {
        let month = date.month
        let day = date.day
        let currentYear = date.year

        var descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate { $0.month == month && $0.day == day && $0.year != currentYear },
            sortBy: [SortDescriptor(\.year, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getEntriesForMonth(year: Int, month: Int) -> [JournalEntry] {
        let calendar = Calendar.current
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = month
        startComponents.day = 1

        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            return []
        }

        let startDayOfYear = startDate.dayOfYear
        let endDayOfYear = endDate.adding(days: -1).dayOfYear

        var descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate { entry in
                entry.year == year && entry.dayOfYear >= startDayOfYear && entry.dayOfYear <= endDayOfYear
            }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getDaysWithEntries(year: Int, month: Int) -> Set<Int> {
        let entries = getEntriesForMonth(year: year, month: month)
        let calendar = Calendar.current

        var days = Set<Int>()
        for entry in entries {
            if let date = Date.from(dayOfYear: entry.dayOfYear, year: entry.year) {
                let day = calendar.component(.day, from: date)
                days.insert(day)
            }
        }
        return days
    }

    func deleteEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }

    func getCurrentStreak() -> Int {
        var streak = 0
        var checkDate = Date().adding(days: -1)
        while getEntry(for: checkDate) != nil {
            streak += 1
            checkDate = checkDate.adding(days: -1)
        }
        return streak
    }
}
