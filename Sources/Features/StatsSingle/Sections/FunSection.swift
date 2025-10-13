import SwiftUI

/// Fun section for the single-page Stats view.
/// Rotation Health, Brand Bingo, Complication Radar, Top Events, Neglected Nudge, Achievements.
struct FunSection: View {
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @State private var rotation30: RotationBalanceResult?
    @State private var neglect30: [NeglectItem] = []
    @State private var brands: [String] = []
    @State private var complicationCounts: [String: Int] = [:]
    @State private var topEvents: [TopEventItem] = []
    @State private var neglectedNudge: [NeglectedNudgeSuggestion] = []
    @State private var achievements: [(achievement: Achievement, state: AchievementState?)] = []

    private let aggregator = StatsAggregator()
    private let achievementRepository: AchievementRepository = AchievementRepositoryGRDB()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let errorMessage { Text(errorMessage).foregroundStyle(.red) }

            // Rotation health + tips (30D)
            if let rotation30 {
                RotationHealthCard(
                    balanceScore: rotation30.balanceScore,
                    neglectedTop: neglect30.filter { $0.isNeglectedInRange }
                )
            } else if isLoading { loadingCard("Computing rotation health…") }

            // Brand Bingo removed per request

            // Complication Radar remains
            if !complicationCounts.isEmpty { ComplicationRadarView(counts: complicationCounts) }

            // Top Events
            if !topEvents.isEmpty { TopEventsCards(items: topEvents) }

            // Neglected Nudge (suggest dates)
            if !neglectedNudge.isEmpty { NeglectedNudgeView(suggestions: neglectedNudge) }

            // Achievements strip
            if !achievements.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(achievements, id: \.achievement.id) { item in
                            AchievementCard(achievement: item.achievement, state: item.state)
                                .frame(width: 180)
                        }
                    }
                }
            }
        }
        .task { await loadFun() }
    }

    private func loadFun() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            // 30D for rotation health/neglect
            let cal = Calendar.current
            let end = cal.startOfDay(for: Date())
            let start30 = cal.date(byAdding: .day, value: -29, to: end)
            async let rot = aggregator.rotationBalance(start: start30, end: end)
            async let neg = aggregator.neglectIndex(start: start30, end: end)

            // Tallies for brands/complications
            async let t = aggregator.collectionTallies()

            // Events and achievements
            async let events = aggregator.topEvents()
            // Initialize user states best-effort; ignore result type warnings by awaiting inline
            _ = try? await achievementRepository.initializeUserStates()
            async let aList = achievementRepository.fetchAchievementsWithStates()

            let (r, n, tallies, evts, ach) = try await (rot, neg, t, events, aList)
            rotation30 = r
            neglect30 = n
            brands = Array(tallies.brandCounts.keys)
            complicationCounts = tallies.complicationCounts
            topEvents = evts

            // Build nudge suggestions: next few days for top neglected
            let picks = n.filter { $0.isNeglectedInRange }.prefix(5)
            let tomorrow = cal.date(byAdding: .day, value: 1, to: end)!
            neglectedNudge = Array(picks.enumerated().map { idx, item in
                NeglectedNudgeSuggestion(
                    watchName: "\(item.watch.manufacturer) \(item.watch.modelName)",
                    suggestedDate: cal.date(byAdding: .day, value: idx, to: tomorrow)!
                )
            })

            achievements = ach
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadingCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ProgressView()
            Text(text).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}


