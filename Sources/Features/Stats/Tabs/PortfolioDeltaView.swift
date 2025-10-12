import SwiftUI

public struct PortfolioDeltaView: View {
    public let totalPurchase: Decimal
    public let totalEstimated: Decimal

    public init(totalPurchase: Decimal, totalEstimated: Decimal) {
        self.totalPurchase = totalPurchase
        self.totalEstimated = totalEstimated
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Portfolio vs Cost").font(.headline).foregroundStyle(.secondary)
            row("Total purchased", totalPurchase as NSDecimalNumber)
            row("Estimated value", totalEstimated as NSDecimalNumber)
            let delta = (totalEstimated as NSDecimalNumber).decimalValue - (totalPurchase as NSDecimalNumber).decimalValue
            let pct = (totalPurchase == 0) ? nil : (NSDecimalNumber(decimal: delta).doubleValue / NSDecimalNumber(decimal: totalPurchase).doubleValue)
            row("Delta", (delta as NSDecimalNumber))
            if let pct { labeled("Return", String(format: "%.1f%%", pct * 100)) }
        }
    }

    private func row(_ label: String, _ number: NSNumber) -> some View {
        HStack { Text(label); Spacer(); Text(number, formatter: currency) .foregroundStyle(.secondary) }
    }

    private func labeled(_ label: String, _ value: String) -> some View {
        HStack { Text(label); Spacer(); Text(value).foregroundStyle(.secondary) }
    }

    private var currency: NumberFormatter {
        let nf = NumberFormatter(); nf.numberStyle = .currency; nf.locale = Locale(identifier: "en_US"); return nf
    }
}


