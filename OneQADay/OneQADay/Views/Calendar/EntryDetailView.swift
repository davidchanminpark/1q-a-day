import SwiftUI
import SwiftData

struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EntryDetailViewModel
    @FocusState private var isAnswerFocused: Bool

    private var isEditable: Bool {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return viewModel.date >= sevenDaysAgo
    }

    init(date: Date) {
        _viewModel = StateObject(wrappedValue: EntryDetailViewModel(date: date))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Palette.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        header

                        if let question = viewModel.question {
                            questionDisplay(question)
                        }

                        if isEditable {
                            AnswerEditor(
                                text: $viewModel.answerText,
                                isFocused: $isAnswerFocused,
                                onTextChange: { viewModel.saveAnswer() }
                            )
                        } else {
                            readOnlyAnswer
                        }

                        if !viewModel.previousEntries.isEmpty {
                            PreviousAnswers(entries: viewModel.previousEntries)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.Palette.background, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(Theme.Palette.muted)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isAnswerFocused = false
                    }
                    .foregroundStyle(Theme.Palette.ink)
                }
            }
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(viewModel.formattedDate)
                .font(Theme.Fonts.cursive(38))
                .foregroundStyle(Theme.Palette.accent)

            Text("your reflection")
                .font(Theme.Fonts.serif(12))
                .italic()
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(Theme.Palette.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Theme.Spacing.sm)
    }

    private var readOnlyAnswer: some View {
        Text(viewModel.answerText)
            .font(Theme.Fonts.typewriter(15))
            .foregroundStyle(Theme.Palette.ink)
            .lineSpacing(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.vertical, Theme.Spacing.sm)
    }

    private func questionDisplay(_ question: Question) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            HStack(spacing: Theme.Spacing.sm) {
                lineSegment
                Image(systemName: "leaf")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.Palette.sage)
                lineSegment
            }

            Text(question.text)
                .font(Theme.Fonts.serif(24, weight: .regular))
                .italic()
                .foregroundStyle(Theme.Palette.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.Spacing.sm)
        }
        .padding(.vertical, Theme.Spacing.lg)
    }

    private var lineSegment: some View {
        Rectangle()
            .fill(Theme.Palette.muted.opacity(0.3))
            .frame(height: 0.5)
            .frame(maxWidth: 60)
    }
}

#Preview {
    EntryDetailView(date: Date())
        .modelContainer(for: [Question.self, JournalEntry.self], inMemory: true)
}
