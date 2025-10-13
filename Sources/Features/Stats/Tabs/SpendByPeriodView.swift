import SwiftUI
import Charts

struct YearSpendDatum: Identifiable { let id = UUID(); let year: Int; let amount: Double }
struct BrandSpendDatum: Identifiable { let id = UUID(); let brand: String; let amount: Double }

public struct SpendByPeriodView: View {
    public let byYear: [Int: Decimal]
    public let byBrand: [String: Decimal]

    public init(byYear: [Int: Decimal], byBrand: [String: Decimal]) {
        self.byYear = byYear
        self.byBrand = byBrand
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !byYear.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Spend by Year").font(.headline).foregroundStyle(.secondary)
                    Chart(yearData.sorted { $0.year < $1.year }) { item in
                        BarMark(x: .value("Year", item.year), y: .value("USD", item.amount))
                    }
                    .frame(height: 180)
                }
            }

            if !byBrand.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Spend by Brand (Top)").font(.headline).foregroundStyle(.secondary)
                    Chart(brandTopN) { item in
                        BarMark(x: .value("USD", item.amount), y: .value("Brand", item.brand))
                    }
                    .chartYAxis { AxisMarks(position: .leading) }
                    .frame(height: min(CGFloat(max(180, brandTopN.count * 24)), 320))
                }
            }
        }
    }

    private var yearData: [YearSpendDatum] {
        byYear.map { YearSpendDatum(year: $0.key, amount: NSDecimalNumber(decimal: $0.value).doubleValue) }
    }

    private var brandTopN: [BrandSpendDatum] {
        Array(byBrand
            .sorted { l, r in l.value == r.value ? l.key < r.key : l.value > r.value }
            .prefix(8)
        ).map { BrandSpendDatum(brand: $0.key, amount: NSDecimalNumber(decimal: $0.value).doubleValue) }
    }
}


