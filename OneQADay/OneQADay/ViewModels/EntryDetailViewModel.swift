import Foundation
import SwiftData
import Combine

@MainActor
class EntryDetailViewModel: ObservableObject {
    let date: Date
    @Published var question: Question?
    @Published var entry: JournalEntry?
    @Published var answerText: String = ""
    @Published var previousEntries: [JournalEntry] = []

    private var dataService: DataService?
    private var saveTask: Task<Void, Never>?

    var formattedDate: String { date.formatted }

    init(date: Date) {
        self.date = date
    }

    func setup(modelContext: ModelContext) {
        self.dataService = DataService(modelContext: modelContext)
        load()
    }

    func load() {
        guard let dataService else { return }
        question = dataService.getQuestion(for: date.stableDayOfYear)
        entry = dataService.getEntry(for: date)
        answerText = entry?.answer ?? ""
        previousEntries = dataService.getPreviousYearEntries(for: date)
    }

    func saveAnswer() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            guard let dataService, let question else { return }
            if !answerText.isEmpty {
                entry = dataService.createOrUpdateEntry(for: date, answer: answerText, question: question)
            }
        }
    }
}
