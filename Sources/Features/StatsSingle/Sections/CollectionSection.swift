import SwiftUI

/// Collection section for the single-page Stats view.
/// Shows summary, composition, distributions, acquisition timeline, service overview, and box/papers.
struct CollectionSection: View {
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @State private var tallies: CollectionCompositionTallies?
    @State private var finance: FinanceAggregationResult?
    // Acquisition timeline removed per request
    @State private var distributions: CollectionDistributions?
    @State private var serviceStatuses: [ServiceStatus] = []
    @State private var boxPapersCounts: [String: Int] = [:]

    private let aggregator = StatsAggregator()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }

            if let finance, let tallies {
                CollectionSummaryCards(
                    totalWatches: tallies.brandCounts.values.reduce(0, +),
                    uniqueBrands: tallies.brandCounts.keys.count,
                    totalPurchase: finance.totalPurchase,
                    totalValue: finance.totalEstimatedValue
                )
            } else if isLoading {
                loadingCard("Loading collection summary…")
            }

            if let t = tallies, !t.brandCounts.isEmpty || !t.movementTypeCounts.isEmpty || !t.complicationCounts.isEmpty || !t.caseMaterialCounts.isEmpty {
                CollectionCompositionCharts(tallies: t)
            } else if isLoading {
                loadingCard("Loading composition charts…")
            }

            if let d = distributions {
                CollectionDistributionsView(distributions: d)
            } else if isLoading {
                loadingCard("Loading distributions…")
            }

            // Acquisition timeline removed per request

            // Service overview removed per request

            if !boxPapersCounts.isEmpty {
                CollectionBoxPapersSummary(counts: boxPapersCounts)
            }
        }
        .task { await loadAllTime() }
    }

    private func loadAllTime() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            async let t = aggregator.collectionTallies()
            async let f = aggregator.financeAggregation()
            async let d = aggregator.collectionDistributions()
            async let s = aggregator.serviceOverview()
            async let bp = aggregator.boxPapersCounts()
            let (tTallies, tFinance, tDist, tService, tBP) = try await (t, f, d, s, bp)
            tallies = tTallies
            finance = tFinance
            distributions = tDist
            serviceStatuses = tService
            boxPapersCounts = tBP
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


