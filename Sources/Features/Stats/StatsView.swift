import SwiftUI
import Charts

/// Stats screen summarizing collection metrics and visualizing wear frequency.
/// - What: Shows aggregate stats, top-most/least worn lists, and two pie charts.
/// - Why: Gives users a quick understanding of their collection usage and distribution.
/// - How: Loads watches from repository; derives top-N slices; renders pies via `SectorMark` with
///        a metallic-inspired palette from `AppColors.chartPalette`.
struct StatsView: View {
    @Environment(\.themeToken) private var themeToken
    @State private var watches: [Watch] = []
    @State private var errorMessage: String? = nil
    private let repository: WatchRepository = WatchRepositoryCoreData()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                summaryCards
                topMostLeast
                charts
            }
            .padding()
            .foregroundStyle(AppColors.textPrimary)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Stats")
        .task { await load() }
        .alert("Error", isPresented: Binding.constant(errorMessage != nil)) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
        .id(themeToken)
    }

    private var summaryCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Watches: \(watches.count)", systemImage: "applewatch")
            Label("Manufacturers: \(Set(watches.map { $0.manufacturer }).count)", systemImage: "building.2")
            let totalPurchase = watches.compactMap { $0.purchasePrice }.reduce(Decimal(0), +)
            let totalValue = watches.compactMap { $0.currentValue }.reduce(Decimal(0), +)
            Label("Total purchased: \(totalPurchase as NSDecimalNumber)", systemImage: "cart")
            Label("Total value: \(totalValue as NSDecimalNumber)", systemImage: "banknote")
        }
        .font(.headline)
    }

    private var topMostLeast: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Most worn")
                .font(.title3)
                .foregroundStyle(AppColors.textSecondary)
            ForEach(watches.sorted(by: { $0.timesWorn > $1.timesWorn }).prefix(5)) { w in
                Text("\(w.manufacturer) \(w.model ?? "") — \(w.timesWorn)x")
            }
            Divider().padding(.vertical, 8)
            Text("Least worn")
                .font(.title3)
                .foregroundStyle(AppColors.textSecondary)
            ForEach(watches.sorted(by: { $0.timesWorn < $1.timesWorn }).prefix(5)) { w in
                Text("\(w.manufacturer) \(w.model ?? "") — \(w.timesWorn)x")
            }
        }
    }

    private var charts: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most worn (Top 5)").font(.title3).foregroundStyle(AppColors.textSecondary)
            PieChart(data: watches.sorted(by: { $0.timesWorn > $1.timesWorn }).prefix(5).map { ($0.displayName, Double($0.timesWorn)) })
                .frame(height: 220)

            Divider().padding(.vertical, 8)
            Text("Least worn (Top 5)").font(.title3).foregroundStyle(AppColors.textSecondary)
            PieChart(data: watches.sorted(by: { $0.timesWorn < $1.timesWorn }).prefix(5).map { ($0.displayName, Double($0.timesWorn)) })
                .frame(height: 220)
        }
    }

    private func load() async {
        do { watches = try await repository.fetchAll() }
        catch { errorMessage = error.localizedDescription }
    }
}

private extension Watch {
    var displayName: String { "\(manufacturer) \(model ?? "")" }
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


