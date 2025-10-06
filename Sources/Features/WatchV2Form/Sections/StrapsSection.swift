import SwiftUI

public struct StrapsSection: View {
    @Binding var entries: [StrapInventoryItem]

    public init(entries: Binding<[StrapInventoryItem]>) {
        self._entries = entries
    }

    public var body: some View {
        CollapsibleSection(title: "Straps Inventory", initiallyExpanded: false) {
            VStack(spacing: 8) {
                ForEach(entries.indices, id: \.self) { idx in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Strap \(idx + 1)").font(.headline)
                            Spacer()
                            Button(role: .destructive) { entries.remove(at: idx) } label: { Image(systemName: "trash") }
                                .accessibilityLabel("Delete strap \(idx + 1)")
                        }
                        EnumPickerWithOther(title: "Type",
                                            selection: Binding(get: { entries[idx].type }, set: { entries[idx].type = $0 }),
                                            options: [.bracelet, .leather, .rubber, .silicone, .fabricNATO, .fkm, .integrated],
                                            display: { $0.asString() },
                                            otherFromString: { .other($0) },
                                            isOther: { if case .other = $0 { return true } else { return false } })
                        TextField("Material", text: Binding(get: { entries[idx].material ?? "" }, set: { entries[idx].material = $0.isEmpty ? nil : $0 }))
                        TextField("Color", text: Binding(get: { entries[idx].color ?? "" }, set: { entries[idx].color = $0.isEmpty ? nil : $0 }))
                        HStack {
                            Stepper(value: Binding(get: { entries[idx].widthMM ?? 0 }, set: { entries[idx].widthMM = $0 == 0 ? nil : Int($0) }), in: 0...40) { Text("Width (mm): \(entries[idx].widthMM.map(String.init) ?? "—")") }
                            EnumPickerWithOther(title: "Clasp",
                                                selection: Binding(get: { entries[idx].claspType }, set: { entries[idx].claspType = $0 }),
                                                options: [.pinBuckle, .deployant, .folding, .butterfly, .microAdjust],
                                                display: { $0.asString() },
                                                otherFromString: { .other($0) },
                                                isOther: { if case .other = $0 { return true } else { return false } })
                        }
                        Toggle("Quick Release", isOn: Binding(get: { entries[idx].quickRelease }, set: { entries[idx].quickRelease = $0 }))
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))
                }
                Button { entries.append(StrapInventoryItem()) } label: { Label("Add Strap", systemImage: "plus") }
                    .accessibilityLabel("Add Strap")
            }
        }
    }
}


