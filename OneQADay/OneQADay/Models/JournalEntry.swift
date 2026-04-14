import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var dayOfYear: Int
    var year: Int
    var month: Int
    var day: Int
    var answer: String
    var questionText: String
    var createdAt: Date
    var updatedAt: Date

    var question: Question?

    init(date: Date, answer: String, questionText: String, question: Question? = nil) {
        let cal = Calendar.current
        self.id = UUID()
        self.date = date
        self.dayOfYear = cal.ordinality(of: .day, in: .year, for: date) ?? 1
        self.year = cal.component(.year, from: date)
        self.month = cal.component(.month, from: date)
        self.day = cal.component(.day, from: date)
        self.answer = answer
        self.questionText = questionText
        self.createdAt = Date()
        self.updatedAt = Date()
        self.question = question
    }
}
