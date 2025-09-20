import SwiftUI

/// Watch detail screen.
/// - What: Shows key attributes, wear metrics, and allows editing or marking worn today.
/// - Why: Centralizes per-watch interactions in a clean, readable layout.
/// - How: Uses a simple repository to add wear entries, with error surfaced via alert.
/// Watch detail page showing metadata and wear stats with live updates.
/// - What: Displays model details, computed wear statistics, and a CTA to mark as worn today.
/// - Why: Centralizes per-watch actions; keeps "worn today" status and stats in sync without navigation.
/// - How: Uses repository queries (`existsWearEntry`, `wearEntriesUpTo`) and pull-to-refresh to recompute state.
struct WatchDetailView: View {
    @Environment(\.themeToken) private var themeToken
    @State private var watch: Watch
    @State private var errorMessage: String? = nil
    @State private var isEditing: Bool = false
    @State private var isSavingWear: Bool = false
    @State private var infoMessage: String? = nil
    /// True when a wear entry exists for the current calendar day.
    @State private var isWornToday: Bool = false
    /// Count of wear entries up to and including today (excludes any future-dated entries).
    @State private var pastWearCount: Int = 0
    /// Latest wear date up to and including today (nil if there are no past entries).
    @State private var lastPastWearDate: Date? = nil
    @Environment(\.dismiss) private var dismiss
    private let repository: WatchRepository = WatchRepositoryCoreData()

    init(watch: Watch) {
        self._watch = State(initialValue: watch)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                imageHeader
                header
                stats
                details
            }
            .padding()
        }
        .refreshable {
            // Pull-to-refresh: re-fetch the watch and recompute worn-today + past-only stats.
            await reloadWatch()
            await refreshAllWearState()
            Haptics.detailViewInteraction(.refreshCompleted)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(watch.manufacturer)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { 
                    Haptics.detailViewInteraction(.editInitiated)
                    isEditing = true 
                }
            }
        }
        .sheet(isPresented: $isEditing, onDismiss: { Task { await reloadWatch() } }) {
            NavigationStack { WatchFormView(existingWatch: watch).id(watch.id) }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("watchDeleted"))) { notification in
            if let deletedId = notification.object as? UUID, deletedId == watch.id {
                dismiss()
            }
        }
        // Keep worn-today status and past stats updated when this watch is edited/saved elsewhere
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("watchUpserted"))) { notification in
            if let updatedId = notification.object as? UUID, updatedId == watch.id {
                Task { await refreshAllWearState() }
            }
        }
        .onAppear { Task { await refreshAllWearState() } }
        .overlay(alignment: .bottom) {
            if let msg = infoMessage {
                DetailToastBanner(message: msg)
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
        .safeAreaInset(edge: .bottom) {
            Group {
                if isWornToday {
                    Text("Worn today")
                        .font(.headline)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        #if DEBUG
                        .accessibilityIdentifier("WornTodayLabel")
                        #endif
                } else {
                    Button(action: { 
                        Haptics.detailViewInteraction(.wearMarked)
                        Task { await wearToday() } 
                    }) {
                        Text("Mark as worn today")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSavingWear)
                    .accessibilityLabel("Mark worn today")
                    #if DEBUG
                    .accessibilityIdentifier("WornTodayCTA")
                    #endif
                }
            }
            .padding()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .id(themeToken)
    }

    private var imageHeader: some View {
        VStack {
            WatchImageView(imageAssetId: watch.imageAssetId)
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppColors.brandSilver.opacity(0.6), lineWidth: 0.5)
                )
                .accessibilityLabel("Watch image")
                .onTapGesture {
                    Haptics.detailViewInteraction(.imageTap)
                }
        }
    }

    /// Recomputes whether the watch is worn today.
    /// - Why: Button visibility and CTA label depend on this; must reflect edits and refreshes.
    private func refreshWornTodayStatus() async {
        do {
            let worn = try await repository.existsWearEntry(watchId: watch.id, date: Date())
            await MainActor.run { isWornToday = worn }
        } catch {
            let worn = {
                if let last = watch.lastWornDate { return DateUtils.startOfDay(last) == DateUtils.startOfDay(Date()) }
                return false
            }()
            await MainActor.run { isWornToday = worn }
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
            .foregroundStyle(AppColors.textSecondary)
        }
    }

    /// Wear statistics view using past-only counts and latest past wear date.
    private var stats: some View {
        HStack(spacing: 16) {
            Label("Worn \(pastWearCount) times", systemImage: "figure.walk")
            if let last = lastPastWearDate { Label(DateUtils.mediumString(from: last), systemImage: "clock") }
        }
        .font(.subheadline)
        .foregroundStyle(AppColors.textSecondary)
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

    /// Marks the watch as worn today, with optimistic local UI updates and a success toast.
    private func wearToday() async {
        isSavingWear = true
        defer { isSavingWear = false }
        do {
            try await repository.incrementWear(for: watch.id, on: Date())
            // Update local state immediately so stats reflect without a reload
            watch.timesWorn += 1
            watch.lastWornDate = Date()
            isWornToday = true
            await refreshPastWearStats()
            withAnimation { infoMessage = "Marked worn today" }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Computes the last worn date as the latest wear date up to (and not after) today.
    /// Falls back to `watch.lastWornDate` if additional history isn't available.
    /// Legacy fallback: clamps any future lastWornDate to today for display if needed.
    private var computedLastWornDate: Date? {
        guard let last = watch.lastWornDate else { return nil }
        let todayStart = DateUtils.startOfDay(Date())
        if last > todayStart { return todayStart }
        return last
    }
    /// Reloads the current watch from persistence after edits.
    /// - Why: Ensures image and fields reflect the latest saved state without
    ///   reloading the entire collection.
    /// - How: Uses the repository's `fetchById(_:)` for a targeted refresh.
    /// Reloads the current watch from persistence after edits.
    /// - Why: Ensures image and fields reflect the latest saved state without reloading the whole list.
    private func reloadWatch() async {
        do {
            let repo: WatchRepository = WatchRepositoryCoreData()
            if let updated = try await repo.fetchById(watch.id) {
                self.watch = updated
            }
        } catch {
            // no-op: keep existing data on failure
        }
    }

    /// Refreshes past-only wear stats: counts entries up to and including today and finds the latest past wear date (excluding future dates).
    /// Refreshes past-only wear stats by querying entries up to and including today.
    /// - What: Computes `pastWearCount` and `lastPastWearDate` from persisted entries.
    /// - Why: Requirements exclude future dates from both the count and the latest date.
    private func refreshPastWearStats() async {
        do {
            let entries = try await repository.wearEntriesUpTo(watchId: watch.id, through: Date())
            let todayStart = DateUtils.startOfDay(Date())
            let pastEntries = entries.filter { DateUtils.startOfDay($0.date) <= todayStart }
            let last = pastEntries.last?.date
            await MainActor.run {
                pastWearCount = pastEntries.count
                lastPastWearDate = last
            }
        } catch {
            // Fallback to domain fields if query fails (best effort; still enforce no future date)
            let todayStart = DateUtils.startOfDay(Date())
            let last = (watch.lastWornDate ?? Date.distantPast) > todayStart ? nil : watch.lastWornDate
            await MainActor.run {
                pastWearCount = last == nil ? 0 : max(watch.timesWorn - 0, 0)
                lastPastWearDate = last
            }
        }
    }

    /// Refreshes both worn-today status and past-only stats.
    /// Refreshes derived wear state (worn today + past-only stats).
    private func refreshAllWearState() async {
        await refreshWornTodayStatus()
        await refreshPastWearStats()
    }
}

private struct DetailToastBanner: View {
    enum ToastStyle { case info, success, warning, error }
    let message: String
    var style: ToastStyle = .success

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: style == .success ? "checkmark.circle.fill" : "info.circle.fill")
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


