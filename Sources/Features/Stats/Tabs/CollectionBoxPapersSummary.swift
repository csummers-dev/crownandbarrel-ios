import SwiftUI

public struct CollectionBoxPapersSummary: View {
    public let counts: [String: Int]

    public init(counts: [String: Int]) {
        self.counts = counts
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Box/Papers Summary").font(.headline).foregroundStyle(.secondary)
            if counts.isEmpty {
                Text("No box/papers info").foregroundStyle(.secondary)
            } else {
                ForEach(counts.sorted(by: { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }), id: \.key) { key, value in
                    HStack {
                        Text(key.capitalized)
                        Spacer()
                        Text("\(value)").foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}


