import SwiftUI

/// Wearing section for the single-page Stats view.
/// Shows most/least worn, rotation balance, neglect index (90D), streaks, full-history heatmap, and weekday/weekend.
struct WearingSection: View {
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @State private var rankings: [WearingRankItem] = []
    @State private var neglect: [NeglectItem] = []
    @State private var streaks: StreaksResult?
    // Heatmap removed
    @State private var weekdayWeekend: WeekdayWeekendBreakdown?

    private let aggregator = StatsAggregator()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let errorMessage { Text(errorMessage).foregroundStyle(.red) }

            // Most/Least Worn (by unique days)
            if !rankings.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Most Worn").font(.headline).foregroundStyle(.secondary)
                    ForEach(Array(rankings.prefix(10))) { item in
                        HStack {
                            Text("\(item.watch.manufacturer) \(item.watch.modelName)")
                            Spacer()
                            Text("\(item.daysWorn) d").foregroundStyle(.secondary)
                        }
                    }
                    Divider().padding(.vertical, 4)
                    Text("Least Worn").font(.headline).foregroundStyle(.secondary)
                    let least = rankings.suffix(10)
                    ForEach(Array(least)) { item in
                        HStack {
                            Text("\(item.watch.manufacturer) \(item.watch.modelName)")
                            Spacer()
                            Text("\(item.daysWorn) d").foregroundStyle(.secondary)
                        }
                    }
                }
            } else if isLoading { loadingCard("Loading wearing lists…") }

            // Rotation Balance removed per request

            // Neglect Index (last 90 days)
            if !neglect.isEmpty {
                NeglectIndexView(items: neglect)
            } else if isLoading { loadingCard("Computing neglect index…") }

            // Streaks
            if let streaks {
                StreaksView(streaks: streaks)
            } else if isLoading { loadingCard("Computing streaks…") }

            // Heatmap removed per request

            // Weekday vs Weekend
            if let weekdayWeekend {
                WeekdayWeekendBreakdownView(breakdown: weekdayWeekend)
            }
        }
        .task { await loadAllTime() }
    }

    private func loadAllTime() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            // All-time window for rankings/streaks/weekday (rotation and heatmap removed)
            async let r = aggregator.wearingRankings(start: nil, end: nil)
            async let s = aggregator.streaks()
            async let wd = aggregator.weekdayWeekendBreakdown(start: nil, end: nil)

            // Neglect: last 90 days
            let cal = Calendar.current
            let end = cal.startOfDay(for: Date())
            let start90 = cal.date(byAdding: .day, value: -89, to: end)
            async let neg = aggregator.neglectIndex(start: start90, end: end)

            let (rr, rs, rwd, rn) = try await (r, s, wd, neg)
            rankings = rr
            streaks = rs
            weekdayWeekend = rwd
            neglect = rn
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


