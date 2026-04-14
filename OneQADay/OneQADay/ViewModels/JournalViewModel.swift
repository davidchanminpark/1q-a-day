import Foundation
import SwiftData
import Combine

@MainActor
class JournalViewModel: ObservableObject {
    @Published var currentDate: Date = Date()
    @Published var currentQuestion: Question?
    @Published var currentEntry: JournalEntry?
    @Published var answerText: String = ""
    @Published var previousEntries: [JournalEntry] = []
    @Published var isEditingQuestion: Bool = false
    @Published var editedQuestionText: String = ""

    private var dataService: DataService?
    private var saveTask: Task<Void, Never>?

    var formattedDate: String {
        currentDate.formatted
    }

    func setup(modelContext: ModelContext) {
        self.dataService = DataService(modelContext: modelContext)
        dataService?.initializeQuestionsIfNeeded()
        loadCurrentDay()
    }

    func loadCurrentDay() {
        guard let dataService = dataService else { return }

        let dayOfYear = currentDate.stableDayOfYear
        currentQuestion = dataService.getQuestion(for: dayOfYear)
        currentEntry = dataService.getEntry(for: currentDate)
        answerText = currentEntry?.answer ?? ""
        previousEntries = dataService.getPreviousYearEntries(for: currentDate)
    }

    func goToDate(_ date: Date) {
        currentDate = date
        loadCurrentDay()
    }

    func saveAnswer() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce

            guard !Task.isCancelled else { return }
            guard let dataService = dataService,
                  let question = currentQuestion else { return }

            if !answerText.isEmpty {
                currentEntry = dataService.createOrUpdateEntry(
                    for: currentDate,
                    answer: answerText,
                    question: question
                )
            }
        }
    }

    func refreshQuestion() {
        guard let dataService = dataService else { return }

        let dayOfYear = currentDate.stableDayOfYear
        currentQuestion = dataService.assignRandomQuestion(for: dayOfYear)
    }

    func startEditingQuestion() {
        editedQuestionText = currentQuestion?.text ?? ""
        isEditingQuestion = true
    }

    func saveEditedQuestion() {
        guard let dataService = dataService,
              let question = currentQuestion else { return }

        dataService.updateQuestion(question, text: editedQuestionText)
        isEditingQuestion = false
    }

    func cancelEditingQuestion() {
        isEditingQuestion = false
        editedQuestionText = ""
    }
}
