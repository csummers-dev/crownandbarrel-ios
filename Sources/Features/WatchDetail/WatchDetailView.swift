import SwiftUI

/// Watch detail screen.
/// - What: Shows key attributes, wear metrics, and allows editing or marking worn today.
/// - Why: Centralizes per-watch interactions in a clean, readable layout.
/// - How: Uses a simple repository to add wear entries, with error surfaced via alert.

struct WatchDetailView: View {
    let watch: Watch
    @State private var errorMessage: String? = nil
    @State private var isEditing: Bool = false
    @State private var isSavingWear: Bool = false
    private let repository: WatchRepository = WatchRepositoryCoreData()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                stats
                details
            }
            .padding()
        }
        .navigationTitle(watch.manufacturer)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack { WatchFormView(existingWatch: watch) }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: { Task { await wearToday() } }) {
                Text("Worn today")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(isSavingWear)
            .accessibilityLabel("Mark worn today")
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(watch.model ?? "")
                .font(.title2)
            HStack(spacing: 8) {
                if let category = watch.category { Label(category.rawValue.capitalized, systemImage: "tag") }
                if let movement = watch.movement { Label(movement.rawValue.capitalized, systemImage: "gear") }
                if watch.isFavorite { Image(systemName: "star.fill").foregroundStyle(.yellow) }
            }
            .foregroundStyle(.secondary)
        }
    }

    private var stats: some View {
        HStack(spacing: 16) {
            Label("\(watch.timesWorn) worn", systemImage: "figure.walk")
            if let last = watch.lastWornDate { Label(DateUtils.mediumString(from: last), systemImage: "clock") }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let serial = watch.serialNumber, !serial.isEmpty { Label(serial, systemImage: "number") }
            if let reference = watch.referenceNumber, !reference.isEmpty { Label(reference, systemImage: "number") }
            if let purchase = watch.purchaseDate { Label("Purchased: \(DateUtils.mediumString(from: purchase))", systemImage: "cart") }
            if let price = watch.purchasePrice { Label("Purchase price: \(price as NSDecimalNumber)", systemImage: "dollarsign.circle") }
            if let value = watch.currentValue { Label("Value: \(value as NSDecimalNumber)", systemImage: "banknote") }
            if let notes = watch.notes, !notes.isEmpty {
                Text(notes).padding(.top, 6)
            }
        }
        .font(.body)
    }

    private func wearToday() async {
        isSavingWear = true
        defer { isSavingWear = false }
        do {
            try await repository.incrementWear(for: watch.id, on: Date())
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


