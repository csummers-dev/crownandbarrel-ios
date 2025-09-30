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
    @State private var watchesById: [UUID: WatchV2] = [:]
    private let repository: WatchRepositoryV2 = WatchRepositoryGRDB()

    var body: some View {
        VStack(spacing: 0) {
            // Native iOS calendar; fixed height to ensure the divider stays at the bottom of the calendar
            // Use the same tint as the "Add worn" action so header arrows and month selector match.
            // Why: `UICalendarView` caches tint on its internal header buttons when created.
            // How: We both set `.tint(AppColors.accent)` and tag the view with the `themeToken`
            //      so the UIKit view is recreated when the theme changes. We also reapply tint
            //      in the UIViewRepresentable's `updateUIView` to handle mid-session changes.
            UICalendarRepresentable(selectedDate: $selectedDate, themeToken: themeToken)
                .frame(height: 420)
                .tint(AppColors.accent)
                // Force recreation on theme change so header chevrons rebuild with new tint
                .id(themeToken + "-calendar")
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
            Haptics.calendarInteraction(.dateSelection)
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

    /// Entries section below the calendar.
    /// - What: Hosts either an empty-state CTA or a `List` of worn entries for the selected date.
    /// - Why: We must ensure the container paints the theme's primary background and that each
    ///        row renders as a rounded card on the theme's secondary background, avoiding any
    ///        UIKit system table backgrounds (especially in dark mode).
    /// - How:
    ///   - Place a full-bleed `AppColors.background` behind the `List` using a `ZStack`.
    ///   - Hide the `List`'s scroll content background and provide per-row `listRowBackground`
    ///     with a rounded `secondaryBackground` fill.
    ///   - Paint the outer container with `AppColors.background` so no system color bleeds through
    ///     when empty or populated.
    private var entriesSection: some View {
        VStack(spacing: 0) {
            if entries.isEmpty {
                emptyStateView
            } else {
                populatedStateView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.background)
        .accessibilityIdentifier("CalendarEntriesContainer")
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.sm) {
            Button(action: { isPresentingPicker = true }) {
                Text("No watches worn this day. Add one?")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
    
    private var populatedStateView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Spacer()
                Button("Add worn") { 
                    Haptics.calendarInteraction(.wearEntryAdded)
                    isPresentingPicker = true 
                }
                .accessibilityIdentifier("Add worn")
                .buttonStyle(.bordered)
            }
            
            ZStack(alignment: .top) {
                AppColors.background.ignoresSafeArea()
                List(entries) { entry in
                    entryRow(entry: entry)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .listRowInsets(EdgeInsets(top: AppSpacing.xxs, leading: AppSpacing.md, bottom: AppSpacing.xxs, trailing: AppSpacing.md))
                .listSectionSeparator(.hidden, edges: .all)
                .listRowSeparator(.hidden, edges: .all)
                .id(themeToken + "-entries-list")
            }
        }
        .padding(.horizontal)
    }
    
    private func entryRow(entry: WearEntry) -> some View {
        Group {
            if let watch = watchesById[entry.watchId] {
                HStack(spacing: 8) {
                    // Use first photo if available, otherwise show placeholder
                    if let firstPhoto = watch.photos.first {
                        WatchImageView(imageAssetId: firstPhoto.id.uuidString)
                            .frame(width: 18, height: 18)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    } else {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppColors.secondaryBackground)
                            .frame(width: 18, height: 18)
                    }
                    HStack(spacing: 4) {
                        Text(watch.manufacturer).fontWeight(.semibold).foregroundStyle(AppColors.textPrimary)
                        if !watch.modelName.isEmpty {
                            Text("- \(watch.modelName)").foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
                .accessibilityLabel("\(watch.manufacturer) \(watch.modelName)")
                .accessibilityIdentifier("CalendarEntryCard")
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs)
                .listRowBackground(
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.large)
                            .fill(AppColors.secondaryBackground)
                    }
                    .padding(.vertical, AppSpacing.xxs)
                )
                .listRowSeparator(.hidden, edges: .all)
            } else {
                Text("Unknown watch").foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xxs)
                    .listRowBackground(
                        ZStack {
                            RoundedRectangle(cornerRadius: AppRadius.large)
                                .fill(AppColors.secondaryBackground)
                        }
                        .padding(.vertical, AppSpacing.xxs)
                    )
                    .listRowSeparator(.hidden, edges: .all)
                    .accessibilityIdentifier("CalendarEntryCard")
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
            var map: [UUID: WatchV2] = [:]
            for w in all { map[w.id] = w }
            watchesById = map
        } catch { /* Non-fatal; entries list will show fallback text */ }
    }
}

// MARK: - UIKit wrapper
/// SwiftUI wrapper for `UICalendarView` with explicit retinting on theme changes.
/// - What: Hosts the calendar and bridges selection back to SwiftUI.
/// - Why: `UICalendarView`'s header chevrons (UIButton) may not update tint color when only
///        SwiftUI `Color` changes; we must reassert tint or recreate the header on theme change.
/// - How: Pass a `themeToken` to force SwiftUI identity changes; in `updateUIView`, set
///        `tintColor` and retint the header subview.
private struct UICalendarRepresentable: UIViewRepresentable {
    @Binding var selectedDate: Date
    // What: Theme token forces SwiftUI to re-render the representable when theme changes
    // Why: Ensures UIKit view re-applies accent tint for navigation arrows immediately
    // How: Pass token down; updateUIView reapplies tint
    var themeToken: String = ""

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.availableDateRange = DateInterval(start: Date(timeIntervalSince1970: 0), end: Date.distantFuture)
        view.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        // Ensure month navigation chevrons and header controls use the themed accent color
        view.tintColor = UIColor(AppColors.accent)
        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // What: Reassert tint on theme changes.
        // Why: Some UIKit subviews cache `tintColor` at creation; directly resetting both the
        //      calendar and its header ensures the month chevrons immediately adopt the new accent.
        // How: Set `tintColor` and ask the header to relayout.
        uiView.tintColor = UIColor(AppColors.accent)
        if let header = uiView.subviews.first(where: { NSStringFromClass(type(of: $0)).contains("UICalendarHeaderView") }) {
            header.tintColor = UIColor(AppColors.accent)
            header.setNeedsLayout()
        }
    }

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
struct WatchPicker: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    var onComplete: (() -> Void)? = nil
    @State private var watches: [WatchV2] = []
    @State private var errorMessage: String? = nil
    @State private var unlockedAchievement: Achievement? = nil
    @State private var showUnlockNotification: Bool = false
    
    private let repository: WatchRepositoryV2 = WatchRepositoryGRDB()
    private let achievementRepository: AchievementRepository = AchievementRepositoryGRDB()
    
    private var evaluator: AchievementEvaluator {
        AchievementEvaluator(
            achievementRepository: achievementRepository,
            watchRepository: repository
        )
    }

    var body: some View {
        NavigationStack {
            List(watches) { watch in
                Button(action: { Task { await mark(watch: watch) } }) {
                    HStack {
                        Text(watch.manufacturer)
                        Text(watch.modelName).foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle("Add worn")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .task { await load() }
            .alert("Error", isPresented: .constant(errorMessage != nil)) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .achievementUnlockNotification(achievement: unlockedAchievement, isPresented: $showUnlockNotification)
        }
    }

    private func load() async { 
        do { 
            watches = try await repository.fetchAll() 
        } catch { 
            errorMessage = error.localizedDescription 
        } 
    }
    private func mark(watch: WatchV2) async {
        do {
            print("📅 Attempting to mark watch as worn: \(watch.id)")
            print("📅 Watch: \(watch.manufacturer) \(watch.modelName)")
            print("📅 Date: \(date)")
            
            // Verify watch exists in database
            let fetchedWatch = try repository.fetch(id: watch.id)
            if fetchedWatch == nil {
                print("❌ Watch not found in database!")
                errorMessage = "Watch not found. Please save the watch first."
                return
            }
            
            print("📅 Watch exists, incrementing wear")
            try await repository.incrementWear(for: watch.id, on: date)
            print("📅 Wear incremented successfully")
            
            // Evaluate achievements after logging wear
            let newlyUnlockedIds = try await evaluator.evaluateOnWearLogged(watchId: watch.id, date: date)
            
            // Show notification for first unlocked achievement
            if let firstUnlockedId = newlyUnlockedIds.first,
               let achievement = try await achievementRepository.fetchDefinition(id: firstUnlockedId) {
                unlockedAchievement = achievement
                showUnlockNotification = true
            }
            
            dismiss()
            onComplete?()
        }
        catch { 
            print("❌ Error marking watch as worn: \(error)")
            errorMessage = error.localizedDescription 
        }
    }
}


