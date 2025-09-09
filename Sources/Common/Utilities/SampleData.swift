import Foundation

/// Generates prototype data for demos and tests (non-production use).
/// - What: Fabricates watches with recognizable manufacturers/models.
/// - Why: Speeds up UI testing and manual verification without manual entry.
/// - How: Creates a predictable sequence cycling through arrays.
public enum SampleData {
    public static func makeWatches(count: Int) -> [Watch] {
        let manufacturers = ["Rolex", "Omega", "Seiko", "Tudor", "Casio", "Citizen"]
        let models = ["Submariner", "Speedmaster", "SKX007", "Black Bay", "G-Shock", "Promaster"]
        return (0..<count).map { idx in
            Watch(
                manufacturer: manufacturers[idx % manufacturers.count],
                model: models[idx % models.count],
                category: .diver,
                movement: .automatic,
                isFavorite: idx % 5 == 0,
                purchasePrice: Decimal(1000 + idx * 10),
                currentValue: Decimal(1200 + idx * 10)
            )
        }
    }
}


