import SwiftUI

struct AnswerEditor: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onTextChange: () -> Void

    var wordLimit: Int = 200
    var characterLimit: Int = 1500

    private let minLines: Int = 6
    private let fontSize: CGFloat = 15

    // AmericanTypewriter at 15pt has a natural line height of ~20pt.
    // extraSpacing is added via .lineSpacing(), giving a total slot of 32pt.
    private let fontLineHeight: CGFloat = 20
    private let extraSpacing: CGFloat = 12
    private var lineHeight: CGFloat { fontLineHeight + extraSpacing }

    // Distance from ZStack top to where the first text row begins
    // (SwiftUI .padding(.top, 2) + UITextView default inset ~8pt).
    private let textTopInset: CGFloat = 10

    private var wordCount: Int {
        text.split(whereSeparator: \.isWhitespace).count
    }

    private var isAtLimit: Bool { wordCount >= wordLimit }

    var body: some View {
        VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
            ZStack(alignment: .topLeading) {
                ruledPaper

                TextEditor(text: $text)
                    .focused(isFocused)
                    .font(Theme.Fonts.typewriter(fontSize))
                    .foregroundStyle(Theme.Palette.ink)
                    .lineSpacing(extraSpacing)
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
                        .font(Theme.Fonts.typewriter(fontSize))
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
            // First line sits at the bottom of the first text row:
            // textTopInset (UIKit inset) + fontLineHeight (content height of row 0)
            let firstLineY = textTopInset + fontLineHeight
            for i in 0..<max(lineCount, minLines) {
                let y = firstLineY + CGFloat(i) * lineHeight
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
