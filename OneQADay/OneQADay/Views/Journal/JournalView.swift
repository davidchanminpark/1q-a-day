import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = JournalViewModel()
    @Binding var navigateToDate: Date?
    @FocusState private var isAnswerFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    dateNavigation

                    if let question = viewModel.currentQuestion {
                        QuestionCard(
                            question: question,
                            isEditing: viewModel.isEditingQuestion,
                            editedText: $viewModel.editedQuestionText,
                            onRefresh: { viewModel.refreshQuestion() },
                            onEdit: { viewModel.startEditingQuestion() },
                            onSaveEdit: { viewModel.saveEditedQuestion() },
                            onCancelEdit: { viewModel.cancelEditingQuestion() }
                        )
                    }

                    AnswerEditor(
                        text: $viewModel.answerText,
                        isFocused: $isAnswerFocused,
                        onTextChange: { viewModel.saveAnswer() }
                    )

                    if !viewModel.previousEntries.isEmpty {
                        PreviousAnswers(entries: viewModel.previousEntries)
                    }
                }
                .padding()
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
            .onChange(of: navigateToDate) { _, newDate in
                if let date = newDate {
                    viewModel.goToDate(date)
                    navigateToDate = nil
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isAnswerFocused = false
                    }
                }
            }
        }
    }

    private var dateNavigation: some View {
        Text(viewModel.formattedDate)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
    }
}

#Preview {
    JournalView(navigateToDate: .constant(nil))
        .modelContainer(for: [Question.self, JournalEntry.self], inMemory: true)
}
