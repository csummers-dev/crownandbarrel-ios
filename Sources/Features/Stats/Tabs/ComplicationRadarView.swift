import SwiftUI

public struct ComplicationRadarView: View {
    public let counts: [String: Int]

    public init(counts: [String: Int]) {
        self.counts = counts
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Complication Radar").font(.headline).foregroundStyle(.secondary)
            GeometryReader { geo in
                ZStack {
                    // Axes
                    ForEach(0..<labels.count, id: \.self) { idx in
                        let angle = angleFor(index: idx, total: labels.count)
                        Path { p in
                            p.move(to: center(in: geo.size))
                            p.addLine(to: point(at: angle, radius: radius(in: geo.size), size: geo.size))
                        }
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    }

                    // Polygon
                    Path { p in
                        for (i, label) in labels.enumerated() {
                            let value = Double(values[label] ?? 0)
                            let r = radius(in: geo.size) * CGFloat(value / maxValue)
                            let pt = point(at: angleFor(index: i, total: labels.count), radius: r, size: geo.size)
                            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                        }
                        p.closeSubpath()
                    }
                    .fill(Color.green.opacity(0.3))
                    .overlay(
                        Path { p in
                            for (i, label) in labels.enumerated() {
                                let value = Double(values[label] ?? 0)
                                let r = radius(in: geo.size) * CGFloat(value / maxValue)
                                let pt = point(at: angleFor(index: i, total: labels.count), radius: r, size: geo.size)
                                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                            }
                            p.closeSubpath()
                        }
                        .stroke(Color.green, lineWidth: 2)
                    )

                    // Labels
                    ForEach(Array(labels.enumerated()), id: \.0) { idx, label in
                        let angle = angleFor(index: idx, total: labels.count)
                        let pt = point(at: angle, radius: radius(in: geo.size) + 12, size: geo.size)
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .position(pt)
                    }
                }
            }
            .frame(height: 240)
        }
    }

    // MARK: - Internals
    private var values: [String: Int] {
        counts
    }
    private var labels: [String] {
        Array(counts.keys).sorted()
    }
    private var maxValue: Double {
        max(1.0, Double(counts.values.max() ?? 1))
    }
    private func center(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width / 2, y: size.height / 2)
    }
    private func radius(in size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.35
    }
    private func angleFor(index: Int, total: Int) -> CGFloat {
        // Start at -90 degrees (top), distribute clockwise
        let step = 2 * Double.pi / Double(max(1, total))
        return CGFloat(-Double.pi / 2 + Double(index) * step)
    }
    private func point(at angle: CGFloat, radius: CGFloat, size: CGSize) -> CGPoint {
        let c = center(in: size)
        return CGPoint(x: c.x + cos(angle) * radius, y: c.y + sin(angle) * radius)
    }
}


