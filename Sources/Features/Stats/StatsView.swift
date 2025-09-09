import SwiftUI
import Charts

struct StatsView: View {
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
        }
        .navigationTitle("Stats")
        .task { await load() }
        .alert("Error", isPresented: .constant(errorMessage != nil)) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
    }

    private var summaryCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Watches: \(watches.count)", systemImage: "watch.case")
            Label("Manufacturers: \(Set(watches.map { $0.manufacturer }).count)", systemImage: "factory")
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
            ForEach(watches.sorted(by: { $0.timesWorn > $1.timesWorn }).prefix(5)) { w in
                Text("\(w.manufacturer) \(w.model ?? "") — \(w.timesWorn)x")
            }
            Divider().padding(.vertical, 8)
            Text("Least worn")
                .font(.title3)
            ForEach(watches.sorted(by: { $0.timesWorn < $1.timesWorn }).prefix(5)) { w in
                Text("\(w.manufacturer) \(w.model ?? "") — \(w.timesWorn)x")
            }
        }
    }

    private var charts: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most worn (Top 5)").font(.title3)
            Chart(watches.sorted(by: { $0.timesWorn > $1.timesWorn }).prefix(5)) { w in
                BarMark(
                    x: .value("Times", w.timesWorn),
                    y: .value("Watch", "\(w.manufacturer) \(w.model ?? "")")
                )
            }
            .frame(height: 220)

            Divider().padding(.vertical, 8)
            Text("Least worn (Top 5)").font(.title3)
            Chart(watches.sorted(by: { $0.timesWorn < $1.timesWorn }).prefix(5)) { w in
                BarMark(
                    x: .value("Times", w.timesWorn),
                    y: .value("Watch", "\(w.manufacturer) \(w.model ?? "")")
                )
            }
            .frame(height: 220)
        }
    }

    private func load() async {
        do { watches = try await repository.fetchAll() }
        catch { errorMessage = error.localizedDescription }
    }
}


