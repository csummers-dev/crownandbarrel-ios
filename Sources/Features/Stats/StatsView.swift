import SwiftUI
import Charts

/// Stats screen summarizing collection metrics and visualizing wear frequency.
/// - What: Shows aggregate stats, top-most/least worn lists, and two pie charts.
/// - Why: Gives users a quick understanding of their collection usage and distribution.
/// - How: Loads watches from repository; derives top-N slices; renders pies via `SectorMark` with
///        a metallic-inspired palette from `AppColors.chartPalette`.
struct StatsView: View {
    @Environment(\.themeToken) private var themeToken
    @State private var watches: [WatchV2] = []
    @State private var errorMessage: String? = nil
    @State private var achievements: [(achievement: Achievement, state: AchievementState?)] = []
    @State private var unlockedAchievement: Achievement? = nil
    @State private var showUnlockNotification: Bool = false
    @AppStorage("showLockedAchievements") private var showLockedAchievements: Bool = true
    
    private let repository: WatchRepositoryV2 = WatchRepositoryGRDB()
    private let achievementRepository: AchievementRepository = AchievementRepositoryGRDB()
    private lazy var evaluator: AchievementEvaluator = AchievementEvaluator(
        achievementRepository: achievementRepository,
        watchRepository: repository
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                summaryCards
                topMostLeast
                charts
                
                Divider().padding(.vertical, 8)
                
                achievementsSection
            }
            .padding()
            .foregroundStyle(AppColors.textPrimary)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Stats")
        .task { await load() }
        .refreshable {
            await load()
            Haptics.statsInteraction(.refreshCompleted)
        }
        .alert("Error", isPresented: Binding.constant(errorMessage != nil)) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
        .achievementUnlockNotification(achievement: unlockedAchievement, isPresented: $showUnlockNotification)
        .id(themeToken)
    }

    private var summaryCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Watches: \(watches.count)", systemImage: "applewatch")
                .onTapGesture {
                    Haptics.statsInteraction(.dataPointTapped)
                }
            Label("Manufacturers: \(Set(watches.map { $0.manufacturer }).count)", systemImage: "building.2")
                .onTapGesture {
                    Haptics.statsInteraction(.dataPointTapped)
                }
            let totalPurchase = watches.compactMap { $0.ownership.purchasePriceAmount }.reduce(Decimal(0), +)
            let totalValue = watches.compactMap { $0.ownership.currentEstimatedValueAmount }.reduce(Decimal(0), +)
            Label("Total purchased: \(totalPurchase as NSDecimalNumber)", systemImage: "cart")
                .onTapGesture {
                    Haptics.statsInteraction(.dataPointTapped)
                }
            Label("Total value: \(totalValue as NSDecimalNumber)", systemImage: "banknote")
                .onTapGesture {
                    Haptics.statsInteraction(.dataPointTapped)
                }
        }
        .font(.headline)
    }

    private var topMostLeast: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Most worn")
                .font(.title3)
                .foregroundStyle(AppColors.textSecondary)
                .onTapGesture {
                    Haptics.statsInteraction(.listHeaderTapped)
                }
            ForEach(Array(watches.prefix(5))) { w in
                Text("\(w.manufacturer) \(w.modelName)")
                    .onTapGesture {
                        Haptics.statsInteraction(.watchListItemTapped)
                    }
            }
            Divider().padding(.vertical, 8)
            Text("Least worn")
                .font(.title3)
                .foregroundStyle(AppColors.textSecondary)
                .onTapGesture {
                    Haptics.statsInteraction(.listHeaderTapped)
                }
            ForEach(Array(watches.prefix(5))) { w in
                Text("\(w.manufacturer) \(w.modelName)")
                    .onTapGesture {
                        Haptics.statsInteraction(.watchListItemTapped)
                    }
            }
        }
    }

    private var charts: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most worn (Top 5)").font(.title3).foregroundStyle(AppColors.textSecondary)
            PieChart(data: Array(watches.prefix(5)).map { ($0.displayName, 1.0) })
                .frame(height: 220)
                .onTapGesture {
                    Haptics.statsInteraction(.chartTapped)
                }

            Divider().padding(.vertical, 8)
            Text("Least worn (Top 5)").font(.title3).foregroundStyle(AppColors.textSecondary)
            PieChart(data: Array(watches.prefix(5)).map { ($0.displayName, 1.0) })
                .frame(height: 220)
                .onTapGesture {
                    Haptics.statsInteraction(.chartTapped)
                }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.title3)
                    .foregroundStyle(AppColors.textSecondary)
                
                Spacer()
                
                Toggle("Show locked", isOn: $showLockedAchievements)
                    .labelsHidden()
            }
            
            if filteredAchievements.isEmpty {
                Text("No achievements to display")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.vertical)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filteredAchievements, id: \.achievement.id) { item in
                            AchievementCard(
                                achievement: item.achievement,
                                state: item.state
                            )
                            .frame(width: 180)
                        }
                    }
                }
            }
        }
    }
    
    private var filteredAchievements: [(achievement: Achievement, state: AchievementState?)] {
        if showLockedAchievements {
            return achievements
        } else {
            return achievements.filter { $0.state?.isUnlocked == true }
        }
    }
    
    private func load() async {
        do {
            watches = try repository.list(sortedBy: .manufacturerLineModel, filters: WatchFilters())
            
            // Initialize achievement states if needed
            try await achievementRepository.initializeUserStates()
            
            // Load achievements with states
            achievements = try await achievementRepository.fetchAchievementsWithStates()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension WatchV2 {
    var displayName: String { "\(manufacturer) \(modelName)" }
}

/// A simple pie chart using Swift Charts `SectorMark`.
/// - What: Maps labeled numeric data to colored sectors with a trailing legend.
/// - Why: Pie charts provide a direct sense of proportion for top-N categories.
/// - How: Assigns colors cyclically from `AppColors.chartPalette`; uses full pies (no inner radius).
private struct PieChart: View {
    let data: [(label: String, value: Double)]

    var items: [PieDatum] {
        let palette = AppColors.chartPalette
        return data.enumerated().map { index, tuple in
            PieDatum(label: tuple.label, value: tuple.value, color: palette[index % palette.count])
        }
    }

    struct PieDatum: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let color: Color
    }

    var body: some View {
        Chart(items) { item in
            SectorMark(
                angle: .value("Value", item.value),
                innerRadius: .ratio(0.0),
                outerRadius: .ratio(1.0)
            )
            .foregroundStyle(item.color)
        }
        .chartLegend(position: .trailing, spacing: 8)
    }
}


