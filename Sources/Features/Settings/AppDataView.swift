import SwiftUI
import UniformTypeIdentifiers

/// AppDataView centralizes data-management operations such as backup/export,
/// restore/import (replace-only), and destructive delete-all actions.
/// - What: Provides buttons and flows to export a `.crownandbarrel` archive, import
///   one to fully replace on-device data, seed debug data, and delete all.
/// - Why: Consolidating these capabilities improves discoverability and keeps
///   risky actions behind explicit user intent and confirmations.
/// - How: Uses async functions backed by `BackupRepositoryFile` and
///   `WatchRepositoryCoreData`. Export returns a temporary URL which is then
///   passed to a `FileDocument` for the system share/export sheet. Import uses
///   `.fileImporter` and calls `importBackup(replace: true)` to enforce
///   replace-only semantics as requested. Delete all is gated by a two-step
///   confirmation dialog.

/// App Data screen for backup/export, import/restore, and destructive delete operations.
/// - What: Provides export/import flows and a debug-only seed sample data action.
/// - Why: Centralizes risky actions behind explicit user intent with confirmations and clear messaging.
/// - How: Uses repository abstractions and system file presenters; shows lightweight toasts for success.
struct AppDataView: View {
    @Environment(\.themeToken) private var themeToken
    /// Transient error message presented in an alert when operations fail.
    @State private var errorMessage: String? = nil
    /// Controls presentation of the file exporter once an export URL is ready.
    @State private var isExporting: Bool = false
    /// Holds the exported file URL to be handed to the exporter.
    @State private var exportURL: URL? = nil
    /// Controls presentation of the importer sheet.
    @State private var isImporting: Bool = false
    /// First confirmation step for destructive delete.
    @State private var confirmDeleteStep1: Bool = false
    /// Second confirmation step for destructive delete.
    @State private var confirmDeleteStep2: Bool = false
    /// Concrete repository handling archive creation and import.
    private let backup: BackupRepository = BackupRepositoryFile()
    /// Concrete repository for seeding sample data during debug.
    private let repo: WatchRepository = WatchRepositoryCoreData()
    @State private var infoMessage: String? = nil

    var body: some View {
        Form {
            headerRow("Backup")
            Section {
                Button("Export backup") { 
                    Haptics.dataInteraction(.exportInitiated)
                    Task { await export() } 
                }
                    .fileExporter(
                        isPresented: $isExporting,
                        document: exportDoc,
                        contentType: archiveUTType,
                        defaultFilename: "CrownAndBarrelBackup"
                    ) { _ in }
                    .listRowBackground(AppColors.background)
                #if DEBUG
                Button("Load sample data") { 
                    Haptics.dataInteraction(.seedDataInitiated)
                    Task { await seedSampleData() } 
                }
                    .listRowBackground(AppColors.background)
                #endif
            } header: { EmptyView() }
            headerRow("Restore")
            Section {
                Button("Import backup") { 
                    Haptics.dataInteraction(.importInitiated)
                    isImporting = true 
                }
                    .listRowBackground(AppColors.background)
            } header: { EmptyView() }
            headerRow("Danger zone")
            Section {
                Button(role: .destructive) { 
                    Haptics.dataInteraction(.deleteInitiated)
                    confirmDeleteStep1 = true 
                } label: { Text("Delete all data") }
                    .listRowBackground(AppColors.background)
            } header: { EmptyView() }
        }
        .listSectionSeparator(.hidden, edges: .all)
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .listStyle(.insetGrouped)
        .listSectionSpacing(.custom(0))
        .contentMargins(.top, -8, for: .scrollContent)
        .id(themeToken + "-appdata-form")
        .navigationTitle("App Data")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("App Data")
                    .font(AppTypography.titleCompact)
                    .foregroundStyle(AppColors.accent)
            }
        }
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Error", isPresented: .constant(errorMessage != nil)) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [UTType(filenameExtension: "crownandbarrel") ?? .data], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first { Task { await importBackup(url) } }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .overlay(alignment: .bottom) {
            if let msg = infoMessage {
                AppDataToastBanner(message: msg)
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.35, dampingFraction: 0.9), value: infoMessage)
            }
        }
        .onChange(of: infoMessage) { _, newValue in
            guard newValue != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { infoMessage = nil }
            }
        }
        .confirmationDialog("Delete all data?", isPresented: $confirmDeleteStep1, titleVisibility: .visible) {
            Button("Yes, continue", role: .destructive) { confirmDeleteStep2 = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes all collection data.")
        }
        .confirmationDialog("Are you absolutely sure?", isPresented: $confirmDeleteStep2, titleVisibility: .visible) {
            Button("Delete everything", role: .destructive) { Task { await deleteAll() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    /// Wraps the export URL into a `FileDocument` that the exporter can write.
    private var exportDoc: ExportedFile? { exportURL.map(ExportedFile.init(url:)) }
    /// Resolved UTType for our backup archive
    private var archiveUTType: UTType { UTType(filenameExtension: "crownandbarrel") ?? .data }

    /// Triggers backup export via repository and presents the exporter sheet.
    private func export() async {
        do { exportURL = try await backup.exportBackup(); isExporting = true }
        catch { errorMessage = error.localizedDescription }
    }

    /// Imports a previously exported archive. Uses replace-only semantics to
    /// prevent merges, honoring the product decision to keep data authoritative
    /// to the backup.
    private func importBackup(_ url: URL) async {
        do { try await backup.importBackup(from: url, replace: true) }
        catch { errorMessage = error.localizedDescription }
    }

    /// Seeds a handful of watches in debug to speed up UI iteration and tests.
    private func seedSampleData() async {
        do {
            for watch in SampleData.makeWatches(count: 8) { try await repo.upsert(watch) }
            await MainActor.run { withAnimation { infoMessage = "Sample data loaded" } }
        } catch { errorMessage = error.localizedDescription }
    }

    /// Deletes all persisted data after a two-step confirmation.
    private func deleteAll() async {
        do { try await backup.deleteAll() }
        catch { errorMessage = error.localizedDescription }
    }
}

private struct AppDataToastBanner: View {
    let message: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColors.accent)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(radius: 4)
        .accessibilityLabel(message)
    }
}

// MARK: - Settings-style header row (plain row above native section)
private extension AppDataView {
    func headerRow(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.none)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, -6)
        .listRowSeparator(.hidden)
        .listRowBackground(AppColors.background)
    }
}

/// A lightweight `FileDocument` wrapper that hands an existing file URL to the
/// system exporter without loading large data blobs into memory.
private struct ExportedFile: FileDocument {
    static var readableContentTypes: [UTType] { [] }
    let url: URL
    init(url: URL) { self.url = url }
    init(configuration: ReadConfiguration) throws { self.url = URL(fileURLWithPath: "") }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { try FileWrapper(url: url, options: .immediate) }
}


