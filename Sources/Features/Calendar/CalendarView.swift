import SwiftUI
import UIKit

/// Calendar screen showing wear entries by day.
/// - What: Renders a native iOS calendar and a list of entries for the selected date, with an action to add worn entries.
/// - Why: A calendar is a natural mental model for tracking usage over time.
/// - How: Wraps `UICalendarView` in a `UIViewRepresentable` and wires selection via a Coordinator.

struct CalendarView: View {
    @Environment(\.themeToken) private var themeToken
    @State private var selectedDate: Date = Date()
    @State private var entries: [WearEntry] = []
    @State private var errorMessage: String? = nil
    @State private var isPresentingPicker: Bool = false
    /// Top padding between the calendar's bottom divider and the entries section.
    /// Using 4pt (xs) maintains visible separation without overlapping the last calendar week.
    @State private var contentTopPadding: CGFloat = AppSpacing.xs
    @State private var watchesById: [UUID: Watch] = [:]
    private let repository: WatchRepository = WatchRepositoryCoreData()

    var body: some View {
        VStack(spacing: 0) {
            // Native iOS calendar; fixed height to ensure the divider stays at the bottom of the calendar
            // Use the same tint as the "Add worn" action so header arrows and month selector match.
            UICalendarRepresentable(selectedDate: $selectedDate)
                .frame(height: 420)
                .tint(AppColors.accent)
            Divider()
            entriesSection
                .padding(.top, contentTopPadding)
        }
        .background(AppColors.background.ignoresSafeArea())
        .foregroundStyle(AppColors.textPrimary)
        .navigationTitle("Calendar")
        // Initial data load: watches map (for row labels/images) and entries for today
        .task {
            await loadWatches()
            await loadEntries()
        }
        .onChange(of: selectedDate) { newDate, _ in
            // Keep the divider spacing tight (4pt) and reload for the new date
            withAnimation(.easeInOut(duration: 0.2)) {
                contentTopPadding = AppSpacing.xs
            }
            Task { await loadEntries() }
        }
        // Present the add-worn picker; on completion, refresh immediately so the list updates
        .sheet(isPresented: $isPresentingPicker) { WatchPicker(date: selectedDate, onComplete: {
            Task {
                await loadWatches()
                await loadEntries()
            }
        }) }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
        .id(themeToken)
    }

    private var entriesSection: some View {
        Group {
            if entries.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Button(action: { isPresentingPicker = true }) {
                        Text("No watches worn this day. Add one?")
                            .font(.headline)
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Spacer()
                        Button("Add worn") { isPresentingPicker = true }
                            .accessibilityIdentifier("Add worn")
                            .buttonStyle(.bordered)
                    }
                    // Compact rows: thumbnail + "Manufacturer - Model". Manufacturer bolded per spec.
                    List(entries) { entry in
                        if let w = watchesById[entry.watchId] {
                            HStack(spacing: 8) {
                                WatchImageView(imageAssetId: w.imageAssetId)
                                    .frame(width: 18, height: 18)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                                HStack(spacing: 4) {
                                    Text(w.manufacturer).fontWeight(.semibold).foregroundStyle(AppColors.textPrimary)
                                    if let model = w.model, !model.isEmpty {
                                        Text("- \(model)").foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                            }
                            .accessibilityLabel("\(w.manufacturer) \(w.model ?? "")")
                        } else {
                            Text("Unknown watch").foregroundStyle(AppColors.textPrimary)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listRowBackground(AppColors.background)
                    .background(AppColors.background)
                    .listRowSeparatorTint(AppColors.separator)
                }
                .padding(.horizontal)
            }
        }
    }

    private func loadEntries() async {
        do { entries = try await repository.wearEntries(on: selectedDate) }
        catch { errorMessage = error.localizedDescription }
    }

    private func loadWatches() async {
        do {
            let all = try await repository.fetchAll()
            var map: [UUID: Watch] = [:]
            for w in all { map[w.id] = w }
            watchesById = map
        } catch { /* Non-fatal; entries list will show fallback text */ }
    }
}

// MARK: - UIKit wrapper
private struct UICalendarRepresentable: UIViewRepresentable {
    @Binding var selectedDate: Date

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.availableDateRange = DateInterval(start: Date(timeIntervalSince1970: 0), end: Date.distantFuture)
        view.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    /// Bridges selection changes back to SwiftUI state.
    final class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate {
        var parent: UICalendarRepresentable
        init(_ parent: UICalendarRepresentable) { self.parent = parent }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let components = dateComponents, let date = components.date else { return }
            parent.selectedDate = date
        }
    }
}

// MARK: - Watch picker for adding worn entries
private struct WatchPicker: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    var onComplete: (() -> Void)? = nil
    @State private var watches: [Watch] = []
    @State private var errorMessage: String? = nil
    private let repository: WatchRepository = WatchRepositoryCoreData()

    var body: some View {
        NavigationStack {
            List(watches) { watch in
                Button(action: { Task { await mark(watch: watch) } }) {
                    HStack {
                        Text(watch.manufacturer)
                        Text(watch.model ?? "").foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle("Add worn")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .task { await load() }
            .alert("Error", isPresented: .constant(errorMessage != nil)) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
        }
    }

    private func load() async { do { watches = try await repository.fetchAll() } catch { errorMessage = error.localizedDescription } }
    private func mark(watch: Watch) async {
        do {
            try await repository.incrementWear(for: watch.id, on: date)
            dismiss()
            onComplete?()
        }
        catch { errorMessage = error.localizedDescription }
    }
}


