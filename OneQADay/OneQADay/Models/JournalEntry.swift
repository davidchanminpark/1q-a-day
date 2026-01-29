import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var dayOfYear: Int
    var year: Int
    var answer: String
    var questionText: String
    var createdAt: Date
    var updatedAt: Date

    var question: Question?

    init(date: Date, answer: String, questionText: String, question: Question? = nil) {
        self.id = UUID()
        self.date = date
        self.dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        self.year = Calendar.current.component(.year, from: date)
        self.answer = answer
        self.questionText = questionText
        self.createdAt = Date()
        self.updatedAt = Date()
        self.question = question
    }
}
