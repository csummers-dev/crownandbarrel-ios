import Foundation

/// Composition tallies across the collection.
public struct CollectionCompositionTallies: Sendable, Equatable {
    public let brandCounts: [String: Int]
    public let movementTypeCounts: [String: Int]
    public let complicationCounts: [String: Int]
    public let caseMaterialCounts: [String: Int]
}


