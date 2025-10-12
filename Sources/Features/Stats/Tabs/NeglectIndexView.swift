import SwiftUI

public struct NeglectIndexView: View {
    public let items: [NeglectItem]

    public init(items: [NeglectItem]) {
        self.items = items
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Neglected Watches").font(.headline).foregroundStyle(.secondary)
            if items.isEmpty {
                Text("None").foregroundStyle(.secondary)
            } else {
                ForEach(items.prefix(10)) { item in
                    HStack {
                        Text("\(item.watch.manufacturer) \(item.watch.modelName)")
                        Spacer()
                        Text(item.daysSinceLastWear.map { "\($0)d" } ?? "—")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(item.watch.manufacturer) \(item.watch.modelName)")
                    .accessibilityValue(item.daysSinceLastWear.map { "\($0) days since last wear" } ?? "No wear recorded")
                }
            }
        }
    }
}


