import SwiftUI

public struct TopEventsCards: View {
    public let items: [TopEventItem]

    public init(items: [TopEventItem]) { self.items = items }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Top 5 Events").font(.headline).foregroundStyle(.secondary)
            if items.isEmpty {
                Text("No events yet").foregroundStyle(.secondary)
            } else {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).font(.subheadline)
                        HStack {
                            Text(item.detail).foregroundStyle(.secondary)
                            if let d = item.date { Text(" · \(format(d))").foregroundStyle(.secondary) }
                        }
                        Divider()
                    }
                }
            }
        }
    }

    private func format(_ date: Date) -> String {
        let df = DateFormatter(); df.dateStyle = .medium; return df.string(from: date)
    }
}


