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
            List {
                aboutSection

                #if DEBUG
                developerSection
                #endif
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Sections

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: "\(appVersion) (\(buildNumber))")
        }
    }

    #if DEBUG
    @State private var isLoadingSampleData = false
    @State private var showLoadConfirmation = false
    @State private var showClearConfirmation = false
    @State private var alertMessage: String?

    private var developerSection: some View {
        Section {
            Button {
                showLoadConfirmation = true
            } label: {
                HStack {
                    Label("Load 3 Years of Sample Data", systemImage: "square.and.arrow.down")
                    Spacer()
                    if isLoadingSampleData {
                        ProgressView()
                    }
                }
            }
            .disabled(isLoadingSampleData)
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

            Button(role: .destructive) {
                showClearConfirmation = true
            } label: {
                Label("Clear All Journal Entries", systemImage: "trash")
            }
            .confirmationDialog(
                "Clear All Entries",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Entries", role: .destructive) { clearAllEntries() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all journal entries. This cannot be undone.")
            }
        } header: {
            Label("Developer", systemImage: "hammer")
        } footer: {
            Text("Debug build only — not visible in release.")
        }
        .alert("Done", isPresented: .init(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK") { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
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
}

#Preview {
    SettingsView()
        .modelContainer(for: [Question.self, JournalEntry.self], inMemory: true)
}
