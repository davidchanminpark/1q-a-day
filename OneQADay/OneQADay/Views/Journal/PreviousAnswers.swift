import SwiftUI

struct PreviousAnswers: View {
    let entries: [JournalEntry]
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text("From Years Past")
                        .font(Theme.Fonts.serif(16))
                        .italic()
                        .tracking(1.5)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.Palette.muted)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.Palette.muted)
                }
            }

            if isExpanded {
                VStack(spacing: Theme.Spacing.lg) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        PreviousAnswerRow(entry: entry)
                        if index < entries.count - 1 {
                            divider
                        }
                    }
                }
            }
        }
        .padding(.vertical, Theme.Spacing.lg)
        .padding(.top, Theme.Spacing.lg)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.Palette.muted.opacity(0.25))
                .frame(height: 0.5)
        }
    }

    private var divider: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Rectangle().fill(Theme.Palette.muted.opacity(0.2)).frame(height: 0.5).frame(maxWidth: 40)
            Image(systemName: "circle.fill")
                .font(.system(size: 3))
                .foregroundStyle(Theme.Palette.muted.opacity(0.4))
            Rectangle().fill(Theme.Palette.muted.opacity(0.2)).frame(height: 0.5).frame(maxWidth: 40)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PreviousAnswerRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(String(entry.year))
                .font(Theme.Fonts.cursive(28))
                .foregroundStyle(Theme.Palette.accent)

            Text(entry.questionText)
                .font(Theme.Fonts.serif(13))
                .italic()
                .foregroundStyle(Theme.Palette.muted)
                .lineLimit(2)

            Text(entry.answer)
                .font(Theme.Fonts.typewriter(14))
                .foregroundStyle(Theme.Palette.ink)
                .lineSpacing(4)
                .lineLimit(4)
                .padding(.top, Theme.Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PreviousAnswers(entries: [])
        .padding()
        .background(Theme.Palette.background)
}
