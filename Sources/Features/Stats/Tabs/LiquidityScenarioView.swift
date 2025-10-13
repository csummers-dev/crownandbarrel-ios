import SwiftUI

public struct LiquidityScenarioItem: Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let estimatedValue: Decimal
}

public struct LiquidityScenarioView: View {
    public let items: [LiquidityScenarioItem]
    public let total: Decimal

    public init(items: [LiquidityScenarioItem]) {
        self.items = items
        self.total = items.reduce(Decimal(0)) { $0 + $1.estimatedValue }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Liquidity Scenario (Top 3)").font(.headline).foregroundStyle(.secondary)
            ForEach(items) { item in
                HStack { Text(item.name); Spacer(); Text(item.estimatedValue as NSDecimalNumber, formatter: currency).foregroundStyle(.secondary) }
            }
            Divider().padding(.vertical, 4)
            HStack { Text("Proceeds"); Spacer(); Text(total as NSDecimalNumber, formatter: currency).foregroundStyle(.secondary) }
        }
    }

    private var currency: NumberFormatter { let nf = NumberFormatter(); nf.numberStyle = .currency; nf.locale = Locale(identifier: "en_US"); return nf }
}


