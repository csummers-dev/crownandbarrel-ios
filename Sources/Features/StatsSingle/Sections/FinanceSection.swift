import SwiftUI

/// Finance section for the single-page Stats view.
/// Shows portfolio vs cost, spend by year/brand, and liquidity scenario (top 3 by estimated value).
struct FinanceSection: View {
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @State private var finance: FinanceAggregationResult?
    @State private var liquidityItems: [LiquidityScenarioItem] = []

    private let aggregator = StatsAggregator()
    private let repo: WatchRepositoryV2 = WatchRepositoryGRDB()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let errorMessage { Text(errorMessage).foregroundStyle(.red) }

            if let f = finance {
                PortfolioDeltaView(totalPurchase: f.totalPurchase, totalEstimated: f.totalEstimatedValue)
                SpendByPeriodView(byYear: f.spendByYear, byBrand: f.spendByBrand)

                if !liquidityItems.isEmpty {
                    LiquidityScenarioView(items: liquidityItems)
                } else {
                    disclaimerCard("Liquidity scenario is based on top 3 estimated values.")
                }
            } else if isLoading {
                loadingCard("Loading finance…")
            }
        }
        .task { await loadAllTime() }
    }

    private func loadAllTime() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            async let f = aggregator.financeAggregation()
            async let w = repo.fetchAll()
            let (ff, watches) = try await (f, w)
            finance = ff
            liquidityItems = topThreeLiquidity(from: watches)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func topThreeLiquidity(from watches: [WatchV2]) -> [LiquidityScenarioItem] {
        let pairs: [(String, Decimal)] = watches.map { w in
            let name = "\(w.manufacturer) \(w.modelName)"
            if let ev = w.ownership.currentEstimatedValueAmount { return (name, ev) }
            // fallback: use latest valuation value if available
            let latest = w.valuations.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }.first
            return (name, latest?.valueAmount ?? 0)
        }
        return Array(pairs.sorted { $0.1 > $1.1 }.prefix(3)).map { pair in
            LiquidityScenarioItem(id: UUID(), name: pair.0, estimatedValue: pair.1)
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

    private func disclaimerCard(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemBackground)))
    }
}


