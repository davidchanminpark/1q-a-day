import SwiftUI

struct AnswerEditor: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onTextChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Answer")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            TextEditor(text: $text)
                .focused(isFocused)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .onChange(of: text) { _, _ in
                    onTextChange()
                }

            if text.isEmpty {
                Text("Tap to start writing...")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 12)
                    .padding(.top, -140)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    @Previewable @FocusState var focused: Bool
    AnswerEditor(
        text: .constant(""),
        isFocused: $focused,
        onTextChange: {}
    )
    .padding()
}
