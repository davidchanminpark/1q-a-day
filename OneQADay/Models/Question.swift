import Foundation
import SwiftData

@Model
final class Question {
    var id: UUID
    var dayOfYear: Int
    var text: String
    var isDefault: Bool

    @Relationship(deleteRule: .cascade, inverse: \JournalEntry.question)
    var entries: [JournalEntry] = []

    init(dayOfYear: Int, text: String, isDefault: Bool = true) {
        self.id = UUID()
        self.dayOfYear = dayOfYear
        self.text = text
        self.isDefault = isDefault
    }
}
