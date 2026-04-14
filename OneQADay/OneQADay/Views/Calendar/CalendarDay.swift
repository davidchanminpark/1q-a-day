import SwiftUI

struct CalendarDay: View {
    let day: Int
    let isToday: Bool
    let hasEntry: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isToday ? .white : .primary)

                Circle()
                    .fill(hasEntry ? (isToday ? .white : Color.green) : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(isToday ? Color.blue : Color.clear)
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
}
