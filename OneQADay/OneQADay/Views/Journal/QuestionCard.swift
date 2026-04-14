import SwiftUI

struct QuestionCard: View {
    let question: Question
    let isEditing: Bool
    @Binding var editedText: String
    let onRefresh: () -> Void
    let onEdit: () -> Void
    let onSaveEdit: () -> Void
    let onCancelEdit: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            if isEditing {
                editingView
            } else {
                displayView
            }
        }
        .padding(.vertical, Theme.Spacing.lg)
    }

    private var displayView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Decorative separator
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

            HStack(spacing: Theme.Spacing.lg) {
                iconButton(systemImage: "arrow.clockwise", label: "New", action: onRefresh)
                iconButton(systemImage: "pencil", label: "Edit", action: onEdit)
            }
            .padding(.top, Theme.Spacing.xs)
        }
    }

    private var editingView: some View {
        VStack(spacing: Theme.Spacing.md) {
            TextField("Enter your question", text: $editedText, axis: .vertical)
                .font(Theme.Fonts.serif(20))
                .italic()
                .foregroundStyle(Theme.Palette.ink)
                .multilineTextAlignment(.center)
                .lineLimit(3...6)
                .padding(Theme.Spacing.md)
                .background(Theme.Palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Theme.Palette.muted.opacity(0.3), lineWidth: 0.5)
                )

            HStack(spacing: Theme.Spacing.lg) {
                textButton("Cancel", isPrimary: false, action: onCancelEdit)
                textButton("Save", isPrimary: true, action: onSaveEdit)
            }
        }
    }

    private var lineSegment: some View {
        Rectangle()
            .fill(Theme.Palette.muted.opacity(0.3))
            .frame(height: 0.5)
            .frame(maxWidth: 60)
    }

    private func iconButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 11))
                Text(label)
                    .font(Theme.Fonts.serif(12))
                    .italic()
                    .tracking(1)
                    .textCase(.uppercase)
            }
            .foregroundStyle(Theme.Palette.muted)
        }
    }

    private func textButton(_ title: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.serif(14))
                .italic()
                .tracking(1.5)
                .textCase(.uppercase)
                .foregroundStyle(isPrimary ? Theme.Palette.background : Theme.Palette.ink)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .background(isPrimary ? Theme.Palette.accent : Color.clear)
                .overlay(
                    Rectangle()
                        .stroke(Theme.Palette.ink.opacity(isPrimary ? 0 : 0.4), lineWidth: 0.5)
                )
        }
    }
}

#Preview {
    QuestionCard(
        question: Question(dayOfYear: 1, text: "What are you most looking forward to this year?"),
        isEditing: false,
        editedText: .constant(""),
        onRefresh: {},
        onEdit: {},
        onSaveEdit: {},
        onCancelEdit: {}
    )
    .padding()
    .background(Theme.Palette.background)
}
