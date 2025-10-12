import SwiftUI
import Charts

public struct CompositionDatum: Identifiable {
    public let id = UUID()
    let label: String
    let value: Int
}

public struct CompositionBarChart: View {
    public let title: String
    public let data: [CompositionDatum]

    public init(title: String, data: [CompositionDatum]) {
        self.title = title
        self.data = data
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Chart(data) { item in
                BarMark(
                    x: .value("Count", item.value),
                    y: .value("Label", item.label)
                )
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: min(CGFloat(max(180, data.count * 24)), 320))
        }
    }
}

public struct CollectionCompositionCharts: View {
    public let tallies: CollectionCompositionTallies

    public init(tallies: CollectionCompositionTallies) {
        self.tallies = tallies
    }

    private func topN(from dict: [String: Int], limit: Int = 8) -> [CompositionDatum] {
        Array(dict
            .filter { !$0.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted { lhs, rhs in lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value }
            .prefix(limit)
        ).map { CompositionDatum(label: $0.key, value: $0.value) }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !tallies.brandCounts.isEmpty {
                CompositionBarChart(title: "Brands (Top)", data: topN(from: tallies.brandCounts))
            }
            if !tallies.movementTypeCounts.isEmpty {
                CompositionBarChart(title: "Movement Types", data: topN(from: tallies.movementTypeCounts))
            }
            if !tallies.complicationCounts.isEmpty {
                CompositionBarChart(title: "Complications (Top)", data: topN(from: tallies.complicationCounts))
            }
            if !tallies.caseMaterialCounts.isEmpty {
                CompositionBarChart(title: "Case Materials", data: topN(from: tallies.caseMaterialCounts))
            }
        }
    }
}


