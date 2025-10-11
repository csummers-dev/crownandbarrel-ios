import SwiftUI

public struct ValuationsSection: View {
    @Binding var entries: [ValuationEntry]

    public init(entries: Binding<[ValuationEntry]>) {
        self._entries = entries
    }

    public var body: some View {
        CollapsibleSection(title: "Valuations", initiallyExpanded: false) {
            VStack(spacing: 8) {
                ForEach(entries.indices, id: \.self) { idx in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Valuation \(idx + 1)").font(.headline)
                            Spacer()
                            Button(role: .destructive) { entries.remove(at: idx) } label: { Image(systemName: "trash") }
                                .accessibilityLabel("Delete valuation \(idx + 1)")
                        }
                        DatePicker("Date", selection: Binding(get: { entries[idx].date ?? Date() }, set: { entries[idx].date = $0 }), displayedComponents: .date)
                            .labelsHidden()
                            .opacity(entries[idx].date == nil ? 0.5 : 1.0)
                        Button(entries[idx].date == nil ? "Set Date" : "Clear Date") {
                            if entries[idx].date == nil { entries[idx].date = Date() } else { entries[idx].date = nil }
                        }
                        EnumPickerWithOther(title: "Source",
                                            selection: Binding(get: { entries[idx].source }, set: { entries[idx].source = $0 }),
                                            options: [.insurer, .appraisal, .marketEst, .auctionComp],
                                            display: { $0.asString() },
                                            otherFromString: { .other($0) },
                                            isOther: { if case .other = $0 { return true } else { return false } })
                        HStack {
                            TextField("Amount", text: Binding(get: { entries[idx].valueAmount.map { NSDecimalNumber(decimal: $0).stringValue } ?? "" }, set: { entries[idx].valueAmount = Decimal(string: $0) }))
                                .keyboardType(.decimalPad)
                            TextField("Currency", text: Binding(get: { entries[idx].valueCurrency ?? "" }, set: { entries[idx].valueCurrency = $0.isEmpty ? nil : $0 }))
                                .frame(width: 80)
                        }
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))
                }
                Button { entries.append(ValuationEntry()) } label: { Label("Add Valuation", systemImage: "plus") }
                    .accessibilityLabel("Add Valuation")
            }
        }
    }
}
