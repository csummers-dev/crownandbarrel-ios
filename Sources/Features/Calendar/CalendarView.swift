import SwiftUI
import UIKit

/// Calendar screen showing wear entries by day.
/// - What: Renders a native iOS calendar and a list of entries for the selected date, with an action to add worn entries.
/// - Why: A calendar is a natural mental model for tracking usage over time.
/// - How: Wraps `UICalendarView` in a `UIViewRepresentable` and wires selection via a Coordinator.

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var entries: [WearEntry] = []
    @State private var errorMessage: String? = nil
    @State private var isPresentingPicker: Bool = false
    private let repository: WatchRepository = WatchRepositoryCoreData()

    var body: some View {
        VStack(spacing: 0) {
            UICalendarRepresentable(selectedDate: $selectedDate)
                .frame(height: 340)
            Divider()
            entriesSection
        }
        .navigationTitle("Calendar")
        .task { await loadEntries() }
        .onChange(of: selectedDate) { newDate, _ in
            Task { await loadEntries() }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add worn") { isPresentingPicker = true }
            }
        }
        .sheet(isPresented: $isPresentingPicker) { WatchPicker(date: selectedDate) }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private var entriesSection: some View {
        List(entries) { entry in
            Text(DateUtils.mediumString(from: entry.date))
        }
        .listStyle(.plain)
    }

    private func loadEntries() async {
        do { entries = try await repository.wearEntries(on: selectedDate) }
        catch { errorMessage = error.localizedDescription }
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
    @State private var watches: [Watch] = []
    @State private var errorMessage: String? = nil
    private let repository: WatchRepository = WatchRepositoryCoreData()

    var body: some View {
        NavigationStack {
            List(watches) { watch in
                Button(action: { Task { await mark(watch: watch) } }) {
                    HStack {
                        Text(watch.manufacturer)
                        Text(watch.model ?? "").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add worn")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .task { await load() }
            .alert("Error", isPresented: .constant(errorMessage != nil)) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
        }
    }

    private func load() async { do { watches = try await repository.fetchAll() } catch { errorMessage = error.localizedDescription } }
    private func mark(watch: Watch) async {
        do { try await repository.incrementWear(for: watch.id, on: date); dismiss() }
        catch { errorMessage = error.localizedDescription }
    }
}


