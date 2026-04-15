import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Palette.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        header

                        aboutSection

                        #if DEBUG
                        developerSection
                        #endif
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.Palette.background, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("Settings")
                .font(Theme.Fonts.cursive(38))
                .foregroundStyle(Theme.Palette.accent)

            Text("Preferences & tools")
                .font(Theme.Fonts.serif(12))
                .italic()
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(Theme.Palette.muted)
        }
        .padding(.top, Theme.Spacing.sm)
    }

    // MARK: - About

    private var aboutSection: some View {
        section(title: "About") {
            row(label: "Version", value: "\(appVersion) (\(buildNumber))")
        }
    }

    // MARK: - Developer (DEBUG)

    #if DEBUG
    @State private var isLoadingSampleData = false
    @State private var showLoadConfirmation = false
    @State private var showClearConfirmation = false
    @State private var alertMessage: String?

    private var developerSection: some View {
        section(title: "Developer") {
            VStack(spacing: 0) {
                actionRow(
                    title: "Load 3 Years of Sample Data",
                    systemImage: "square.and.arrow.down",
                    isLoading: isLoadingSampleData
                ) {
                    showLoadConfirmation = true
                }
                .disabled(isLoadingSampleData)

                divider

                actionRow(
                    title: "Clear All Journal Entries",
                    systemImage: "trash",
                    tint: .red
                ) {
                    showClearConfirmation = true
                }
            }
            .padding(.vertical, Theme.Spacing.sm)
            .confirmationDialog(
                "Load Sample Data",
                isPresented: $showLoadConfirmation,
                titleVisibility: .visible
            ) {
                Button("Load Sample Data") { loadSampleData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will add journal entries for the past 3 years. Existing entries won't be overwritten.")
            }
            .confirmationDialog(
                "Clear All Entries",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Entries", role: .destructive) { clearAllEntries() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all journal entries.")
            }
            .alert("Done", isPresented: .init(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button("OK") { alertMessage = nil }
            } message: {
                Text(alertMessage ?? "")
            }

            Text("Debug build only — not visible in release.")
                .font(Theme.Fonts.serif(11))
                .italic()
                .foregroundStyle(Theme.Palette.muted)
                .padding(.top, Theme.Spacing.xs)
                .padding(.horizontal, Theme.Spacing.md)
        }
    }

    private func loadSampleData() {
        isLoadingSampleData = true
        let service = SampleDataService(modelContext: modelContext)
        Task {
            let count = (try? await service.loadThreeYearsOfSampleData()) ?? 0
            isLoadingSampleData = false
            alertMessage = "Added \(count) sample entries."
        }
    }

    private func clearAllEntries() {
        let service = SampleDataService(modelContext: modelContext)
        try? service.clearAllEntries()
        alertMessage = "All journal entries cleared."
    }
    #endif

    // MARK: - Building blocks

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Fonts.serif(12))
                .italic()
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(Theme.Palette.muted)
                .padding(.horizontal, Theme.Spacing.md)

            VStack(spacing: 0) {
                content()
            }
            .background(Theme.Palette.surface)
            .overlay(
                Rectangle()
                    .stroke(Theme.Palette.muted.opacity(0.15), lineWidth: 0.5)
            )
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.Fonts.serif(15))
                .foregroundStyle(Theme.Palette.ink)
            Spacer()
            Text(value)
                .font(Theme.Fonts.typewriter(13))
                .foregroundStyle(Theme.Palette.muted)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.md)
    }

    private func actionRow(
        title: String,
        systemImage: String,
        tint: Color? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 14))
                    .foregroundStyle(tint ?? Theme.Palette.accent)
                    .frame(width: 20)

                Text(title)
                    .font(Theme.Fonts.serif(15))
                    .foregroundStyle(tint ?? Theme.Palette.ink)

                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(Theme.Palette.accent)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.md)
            .contentShape(Rectangle())
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.Palette.muted.opacity(0.15))
            .frame(height: 0.5)
            .padding(.horizontal, Theme.Spacing.md)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Question.self, JournalEntry.self], inMemory: true)
}
