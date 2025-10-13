import SwiftUI
import Charts

struct DistributionDatum: Identifiable {
    let id = UUID()
    let bucket: String
    let count: Int
}

public struct CollectionDistributionsView: View {
    public let distributions: CollectionDistributions

    public init(distributions: CollectionDistributions) {
        self.distributions = distributions
    }

    private func data(from dict: [String: Int]) -> [DistributionDatum] {
        dict.map { DistributionDatum(bucket: $0.key, count: $0.value) }
            .sorted { $0.bucket < $1.bucket }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !distributions.diameterBins.isEmpty {
                chart(title: "Case Diameter (mm)", data: data(from: distributions.diameterBins))
            }
            if !distributions.thicknessBins.isEmpty {
                chart(title: "Thickness (mm)", data: data(from: distributions.thicknessBins))
            }
            if !distributions.lugToLugBins.isEmpty {
                chart(title: "Lug-to-Lug (mm)", data: data(from: distributions.lugToLugBins))
            }
            if !distributions.waterResistanceBins.isEmpty {
                chart(title: "Water Resistance (m)", data: data(from: distributions.waterResistanceBins))
            }
        }
    }

    private func chart(title: String, data: [DistributionDatum]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundStyle(.secondary)
            Chart(data) { item in
                BarMark(
                    x: .value("Bucket", item.bucket),
                    y: .value("Count", item.count)
                )
            }
            .frame(height: 180)
        }
    }
}


