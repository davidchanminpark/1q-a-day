import SwiftUI

struct AnswerEditor: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onTextChange: () -> Void

    var wordLimit: Int = 200
    var characterLimit: Int = 1500

    private let lineHeight: CGFloat = 28
    private let minLines: Int = 6

    private var wordCount: Int {
        text.split(whereSeparator: \.isWhitespace).count
    }

    private var isAtLimit: Bool { wordCount >= wordLimit }

    var body: some View {
        VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
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
                    .onChange(of: text) { oldValue, newValue in
                        let newWordCount = newValue.split(whereSeparator: \.isWhitespace).count
                        if newWordCount > wordLimit || newValue.count > characterLimit {
                            text = oldValue
                        } else {
                            onTextChange()
                        }
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

            Text("\(wordCount) / \(wordLimit)")
                .font(Theme.Fonts.typewriter(12))
                .foregroundStyle(isAtLimit ? Theme.Palette.accent : Theme.Palette.muted.opacity(0.6))
                .animation(.easeInOut(duration: 0.2), value: isAtLimit)
        }
    }

    private var ruledPaper: some View {
        Canvas { context, size in
            let lineCount = Int(size.height / lineHeight) + 1
            let ruleColor = Theme.Palette.rule
            for i in 0..<max(lineCount, minLines) {
                let y = CGFloat(i + 1) * lineHeight - 0.25
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(ruleColor), lineWidth: 0.5)
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
