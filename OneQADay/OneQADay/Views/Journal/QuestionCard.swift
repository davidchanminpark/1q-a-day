import SwiftUI

struct QuestionCard: View {
    let question: Question

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            HStack(spacing: Theme.Spacing.sm) {
                lineSegment
                Image(systemName: "leaf")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.Palette.sage)
                lineSegment
            }

            Text(question.text)
                .font(Theme.Fonts.serif(26, weight: .regular))
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
    QuestionCard(
        question: Question(dayOfYear: 1, text: "What are you most looking forward to this year?")
    )
    .padding()
    .background(Theme.Palette.background)
}
