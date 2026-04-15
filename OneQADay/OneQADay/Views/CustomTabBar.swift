import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    struct TabItem {
        let title: String
        let icon: String
    }

    private let tabs: [TabItem] = [
        TabItem(title: "Today", icon: "book.closed"),
        TabItem(title: "Calendar", icon: "calendar"),
        TabItem(title: "Settings", icon: "gearshape"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                tabButton(at: index)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            Capsule()
                .fill(Theme.Palette.ink)
                .shadow(color: Theme.Palette.ink.opacity(0.15), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 8)
    }

    private func tabButton(at index: Int) -> some View {
        let tab = tabs[index]
        let isSelected = selectedTab == index
        return Button {
            if selectedTab != index {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .regular : .light))
                    .foregroundStyle(isSelected ? Theme.Palette.background : Theme.Palette.background.opacity(0.45))

                Text(tab.title)
                    .font(Theme.Fonts.serif(10))
                    .italic()
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundStyle(isSelected ? Theme.Palette.background : Theme.Palette.background.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(0))
    }
    .background(Theme.Palette.background)
}
