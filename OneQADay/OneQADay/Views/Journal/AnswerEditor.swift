import SwiftUI

struct AnswerEditor: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onTextChange: () -> Void

    private let lineHeight: CGFloat = 28
    private let minLines: Int = 6

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Ruled paper background
            ruledPaper

            TextEditor(text: $text)
                .focused(isFocused)
                .font(Theme.Fonts.typewriter(15))
                .foregroundStyle(Theme.Palette.ink)
                .lineSpacing(lineHeight - 18)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, Theme.Spacing.xs)
                .padding(.top, 2)
                .frame(minHeight: CGFloat(minLines) * lineHeight)
                .onChange(of: text) { _, _ in
                    onTextChange()
                }

            if text.isEmpty {
                Text("tap to begin your entry…")
                    .font(Theme.Fonts.typewriter(15))
                    .italic()
                    .foregroundStyle(Theme.Palette.muted.opacity(0.5))
                    .padding(.horizontal, Theme.Spacing.sm + 4)
                    .padding(.top, 10)
                    .allowsHitTesting(false)
            }
        }
    }

    private var ruledPaper: some View {
        GeometryReader { geo in
            let lines = Int(geo.size.height / lineHeight)
            VStack(spacing: 0) {
                ForEach(0..<max(lines, minLines), id: \.self) { _ in
                    ZStack(alignment: .bottom) {
                        Color.clear.frame(height: lineHeight)
                        Rectangle()
                            .fill(Theme.Palette.rule)
                            .frame(height: 0.5)
                    }
                }
            }
        }
        .frame(minHeight: CGFloat(minLines) * lineHeight)
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
    .background(Theme.Palette.background)
}
