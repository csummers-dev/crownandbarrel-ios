import SwiftUI

public struct ServiceHistorySection: View {
    @Binding var entries: [ServiceHistoryEntry]

    public init(entries: Binding<[ServiceHistoryEntry]>) {
        self._entries = entries
    }

    public var body: some View {
        CollapsibleSection(title: "Service History", initiallyExpanded: false) {
            VStack(spacing: 8) {
                ForEach(entries.indices, id: \.self) { idx in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Entry \(idx + 1)").font(.headline)
                            Spacer()
                            Button(role: .destructive) { entries.remove(at: idx) } label: { Image(systemName: "trash") }
                                .accessibilityLabel("Delete service history entry \(idx + 1)")
                        }
                        DatePicker("Date", selection: Binding(get: { entries[idx].date ?? Date() }, set: { entries[idx].date = $0 }), displayedComponents: .date)
                            .labelsHidden()
                            .opacity(entries[idx].date == nil ? 0.5 : 1.0)
                        Button(entries[idx].date == nil ? "Set Date" : "Clear Date") {
                            if entries[idx].date == nil { entries[idx].date = Date() } else { entries[idx].date = nil }
                        }
                        TextField("Provider", text: Binding(get: { entries[idx].provider ?? "" }, set: { entries[idx].provider = $0.isEmpty ? nil : $0 }))
                        TextField("Work Description", text: Binding(get: { entries[idx].workDescription ?? "" }, set: { entries[idx].workDescription = $0.isEmpty ? nil : $0 }), axis: .vertical)
                            .lineLimit(2, reservesSpace: true)
                        HStack {
                            TextField("Cost Amount", text: Binding(get: { entries[idx].costAmount.map { NSDecimalNumber(decimal: $0).stringValue } ?? "" }, set: { entries[idx].costAmount = Decimal(string: $0) }))
                                .keyboardType(.decimalPad)
                            TextField("Currency", text: Binding(get: { entries[idx].costCurrency ?? "" }, set: { entries[idx].costCurrency = $0.isEmpty ? nil : $0 }))
                                .frame(width: 80)
                        }
                        HStack {
                            DatePicker("Warranty Until", selection: Binding(get: { entries[idx].warrantyUntil ?? Date() }, set: { entries[idx].warrantyUntil = $0 }), displayedComponents: .date)
                                .labelsHidden()
                                .opacity(entries[idx].warrantyUntil == nil ? 0.5 : 1.0)
                            Button(entries[idx].warrantyUntil == nil ? "Set" : "Clear") {
                                if entries[idx].warrantyUntil == nil { entries[idx].warrantyUntil = Date() } else { entries[idx].warrantyUntil = nil }
                            }
                        }
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))
                }
                Button { entries.append(ServiceHistoryEntry()) } label: {
                    Label("Add Service Entry", systemImage: "plus")
                }
                .accessibilityLabel("Add Service Entry")
            }
        }
    }
}


