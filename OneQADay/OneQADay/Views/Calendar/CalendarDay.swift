import SwiftUI

struct CalendarDay: View {
    let day: Int
    let isToday: Bool
    let hasEntry: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                Text("\(day)")
                    .font(Theme.Fonts.serif(16, weight: isToday ? .semibold : .regular))
                    .foregroundStyle(isToday ? Theme.Palette.background : Theme.Palette.ink)

                Circle()
                    .fill(hasEntry ? (isToday ? Theme.Palette.background : Theme.Palette.accent) : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(isToday ? Theme.Palette.accent : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 16) {
        CalendarDay(day: 15, isToday: false, hasEntry: false, onTap: {})
        CalendarDay(day: 16, isToday: true, hasEntry: false, onTap: {})
        CalendarDay(day: 17, isToday: false, hasEntry: true, onTap: {})
        CalendarDay(day: 18, isToday: true, hasEntry: true, onTap: {})
    }
    .padding()
    .background(Theme.Palette.background)
}
