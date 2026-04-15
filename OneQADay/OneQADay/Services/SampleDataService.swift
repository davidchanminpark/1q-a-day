#if DEBUG
import Foundation
import SwiftData

@MainActor
class SampleDataService {
    private let modelContext: ModelContext
    private let dataService: DataService

    // Curated entries for specific dates — used for screenshots / App Store previews.
    // Key: "month-day", value: (question text, [year: answer])
    private static let curatedEntries: [String: (question: String, answers: [Int: String])] = [
        "4-10": (
            question: "What's something that surprised you recently?",
            answers: [
                2025: "How much I enjoyed being alone on a Saturday — genuinely enjoyed it, not just tolerated it. I had nowhere to be and instead of feeling restless I felt this unusual sense of fullness. I read, made a long lunch, went for a walk with no destination. I think I surprised myself by not needing it to be more than it was.",
                2024: "A stranger held the elevator for me even though I was far away and it clearly cost them two minutes. Such a small thing, but I kept thinking about it. I'd been in a stretch of feeling like the city was indifferent, and that one gesture quietly reset something in me. I was surprised how much weight I'd been carrying about it without realizing.",
                2023: "My own reaction to some news I'd been dreading. I'd built it up so much in my head that when it finally came, I just felt calm. Not numb — calm. I sat with it for a while trying to figure out if I was in denial, but no, I think I'd already done the hard work before I even knew the outcome. That felt like growth I hadn't noticed happening."
            ]
        )
    ]

    private static let sampleAnswers: [String] = [
        "I think about this more than I'd like to admit. Honestly, the answer changes depending on the day, but today I feel pretty clear about it.",
        "This question always takes me back to a specific memory — the summer I was 17, sitting on the back porch, realizing things were about to change forever.",
        "My gut says yes, but experience has taught me to be more cautious. The gap between what I want to believe and what I know to be true is something I'm still navigating.",
        "Three years ago I would have answered this completely differently. It's strange to notice how much my perspective has shifted without me even realizing it.",
        "Honestly, I don't have a clean answer. Part of me leans one way, part of me leans another. Maybe that ambiguity is itself the answer.",
        "The thing I keep coming back to is that it's not about the big moments — it's the small, consistent choices that actually define who I am.",
        "I spent a long time pretending this didn't matter to me. Now I can admit it matters quite a lot.",
        "When I'm at my best, I know exactly what to do here. When I'm tired or overwhelmed, everything gets murky. I want to be the version of myself who stays clear-headed.",
        "My honest answer is that I've been avoiding this. Writing it out helps me see it more directly than I'd like.",
        "I talked about this with a close friend last week, and their perspective shifted something in me. I'm still processing it.",
        "There's a version of this story I've been telling myself that I'm not sure is fully accurate. Something about writing it down makes me question the narrative.",
        "The answer feels obvious when I'm calm. The challenge is remembering it when I'm not.",
        "I want to say I've figured this out, but the truth is I'm still very much in the middle of it.",
        "What strikes me most is how long I let fear drive the decisions I told myself were rational.",
        "I think the honest version of this is harder to say out loud, but here it is: I care about this more than I let on.",
        "Looking back, I handled that situation better than I gave myself credit for. I'm trying to internalize that instead of always defaulting to self-criticism.",
        "The easy answer is the one people expect. The real answer is the one I've been sitting with quietly.",
        "I used to think certainty was a sign of strength. I'm starting to think comfort with uncertainty might be the actual thing.",
        "This is one of those questions where I notice myself crafting an answer that sounds good instead of one that's true. Let me try again: the real answer is I don't know yet.",
        "Today was a good day for this question. I felt unusually clear-headed and the answer came quickly — which itself feels worth noting.",
        "I keep circling back to the same realization: the thing I most want and the thing I'm most afraid of might be the same thing.",
        "At some point I stopped waiting for permission. I'm not sure exactly when, but something shifted and I'm glad it did.",
        "The version of me from five years ago would be surprised by this answer. I think that's a good sign.",
        "I noticed today that I was comparing myself to someone else's pace. That's usually a sign I've lost the thread of what actually matters to me.",
        "Small progress is still progress. I have to remind myself of that more than I'd like to.",
        "The clearest answer I have is: more than I show, less than I fear, and still figuring out what to do with that.",
        "I've been trying to be more honest with myself about this. Today I got a little closer.",
        "What I know for certain is surprisingly small. What I'm learning to trust is growing.",
        "I wrote three different answers and deleted them all. This one is the most honest: I'm still working on it.",
        "The thing that keeps surprising me is how much changes and how much stays exactly the same."
    ]

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.dataService = DataService(modelContext: modelContext)
    }

    func loadThreeYearsOfSampleData() async throws -> Int {
        let cal = Calendar.current
        let today = Date()
        let currentYear = today.year

        var insertedCount = 0

        let yesterday = today.adding(days: -1)

        for yearOffset in 0...3 {
            let year = currentYear - yearOffset

            // Iterate every calendar day in the year
            var components = DateComponents()
            components.year = year
            components.month = 1
            components.day = 1
            guard var cursor = cal.date(from: components) else { continue }

            while cal.component(.year, from: cursor) == year {
                // Don't generate entries beyond yesterday
                if cursor > yesterday { break }

                let month = cursor.month
                let day = cursor.day

                // Skip if entry already exists (match by month+day+year)
                let existingDescriptor = FetchDescriptor<JournalEntry>(
                    predicate: #Predicate { $0.month == month && $0.day == day && $0.year == year }
                )
                let existing = (try? modelContext.fetchCount(existingDescriptor)) ?? 0

                if existing == 0 {
                    let stableIndex = cursor.stableDayOfYear
                    if let question = dataService.getQuestion(for: stableIndex) {
                        let curatedKey = "\(month)-\(day)"
                        let curatedAnswer = Self.curatedEntries[curatedKey]?.answers[year]
                        let curatedQuestion = Self.curatedEntries[curatedKey]?.question
                        let answer = curatedAnswer ?? Self.sampleAnswers.randomElement() ?? "Sample answer."
                        let entry = JournalEntry(
                            date: cursor,
                            answer: answer,
                            questionText: curatedQuestion ?? question.text,
                            question: question
                        )
                        modelContext.insert(entry)
                        insertedCount += 1

                        if insertedCount % 100 == 0 {
                            try? modelContext.save()
                        }
                    }
                }

                cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? cursor.adding(days: 1)
            }
        }

        try? modelContext.save()
        return insertedCount
    }

    func clearAllEntries() throws {
        let descriptor = FetchDescriptor<JournalEntry>()
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        for entry in entries {
            modelContext.delete(entry)
        }
        try? modelContext.save()
    }
}
#endif
