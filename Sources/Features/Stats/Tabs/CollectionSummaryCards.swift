import SwiftUI

public struct CollectionSummaryCards: View {
    public let totalWatches: Int
    public let uniqueBrands: Int
    public let totalPurchase: Decimal
    public let totalValue: Decimal

    public init(totalWatches: Int, uniqueBrands: Int, totalPurchase: Decimal, totalValue: Decimal) {
        self.totalWatches = totalWatches
        self.uniqueBrands = uniqueBrands
        self.totalPurchase = totalPurchase
        self.totalValue = totalValue
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            summaryRow(label: "Watches", value: "\(totalWatches)")
            summaryRow(label: "Manufacturers", value: "\(uniqueBrands)")
            summaryRow(label: "Total purchased", valueNumber: totalPurchase as NSDecimalNumber)
            summaryRow(label: "Total value", valueNumber: totalValue as NSDecimalNumber)
        }
        .font(.headline)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Collection summary")
        .accessibilityValue("\(totalWatches) watches, \(uniqueBrands) manufacturers, total purchased \(currencyFormatter.string(from: totalPurchase as NSDecimalNumber) ?? ""), total value \(currencyFormatter.string(from: totalValue as NSDecimalNumber) ?? "")")
    }

    private var currencyFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.locale = Locale(identifier: "en_US")
        return nf
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func summaryRow(label: String, valueNumber: NSNumber) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(valueNumber, formatter: currencyFormatter)
                .foregroundStyle(.secondary)
        }
    }
}


