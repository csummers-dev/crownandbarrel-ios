import SwiftUI

public struct RotationHealthCard: View {
    public let balanceScore: Double // 0...1, higher is better
    public let neglectedTop: [NeglectItem]

    public init(balanceScore: Double, neglectedTop: [NeglectItem]) {
        self.balanceScore = balanceScore
        self.neglectedTop = neglectedTop
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rotation Health").font(.headline)

            HStack {
                Text("Score")
                Spacer()
                Text(String(format: "%.0f%%", balanceScore * 100)).foregroundStyle(.secondary)
            }

            if !neglectedTop.isEmpty {
                Text("Suggested next wears").font(.subheadline).foregroundStyle(.secondary)
                ForEach(neglectedTop.prefix(3)) { item in
                    HStack {
                        Text("\(item.watch.manufacturer) \(item.watch.modelName)")
                        Spacer()
                        Text(item.daysSinceLastWear.map { "\($0)d" } ?? "—")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("Great rotation! Keep it up.").foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}


