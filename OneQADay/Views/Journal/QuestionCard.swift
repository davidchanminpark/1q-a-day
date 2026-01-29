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
        VStack(spacing: 16) {
            if isEditing {
                editingView
            } else {
                displayView
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var displayView: some View {
        VStack(spacing: 16) {
            Text(question.text)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            HStack(spacing: 20) {
                Button(action: onRefresh) {
                    Label("New Question", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)

                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var editingView: some View {
        VStack(spacing: 16) {
            TextField("Enter your question", text: $editedText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)

            HStack(spacing: 20) {
                Button("Cancel", action: onCancelEdit)
                    .buttonStyle(.bordered)

                Button("Save", action: onSaveEdit)
                    .buttonStyle(.borderedProminent)
            }
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
}
