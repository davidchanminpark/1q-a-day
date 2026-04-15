import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = JournalViewModel()
    @Binding var navigateToDate: Date?
    @FocusState private var isAnswerFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Palette.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        header

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
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.Palette.background, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
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
                    .foregroundStyle(Theme.Palette.ink)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("Today's Question")
                .font(Theme.Fonts.cursive(42))
                .foregroundStyle(Theme.Palette.accent)

            Text(viewModel.formattedDate)
                .font(Theme.Fonts.serif(14))
                .italic()
                .foregroundStyle(Theme.Palette.muted)
                .tracking(1.5)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Theme.Spacing.sm)
    }
}

#Preview {
    JournalView(navigateToDate: .constant(nil))
        .modelContainer(for: [Question.self, JournalEntry.self], inMemory: true)
}
