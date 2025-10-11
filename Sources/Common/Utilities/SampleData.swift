import Foundation

/// Generates prototype data for demos and tests (non-production use).
/// - What: Fabricates watches with recognizable manufacturers/models.
/// - Why: Speeds up UI testing and manual verification without manual entry.
/// - How: Creates a predictable sequence cycling through arrays.
public enum SampleData {
    public static func makeWatches(count: Int) -> [WatchV2] {
        let manufacturers = ["Rolex", "Omega", "Seiko", "Tudor", "Casio", "Citizen"]
        let models = ["Submariner", "Speedmaster", "SKX007", "Black Bay", "G-Shock", "Promaster"]
        return (0..<count).map { idx in
            WatchV2(
                manufacturer: manufacturers[idx % manufacturers.count],
                modelName: models[idx % models.count],
                movement: MovementSpec(type: .automatic),
                ownership: WatchOwnership(
                    purchasePriceAmount: Decimal(1_000 + idx * 10),
                    currentEstimatedValueAmount: Decimal(1_200 + idx * 10)
                )
            )
        }
    }
}
