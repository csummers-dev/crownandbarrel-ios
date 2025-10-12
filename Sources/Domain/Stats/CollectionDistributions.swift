import Foundation

public struct CollectionDistributions: Sendable, Equatable {
    public let diameterBins: [String: Int]
    public let thicknessBins: [String: Int]
    public let lugToLugBins: [String: Int]
    public let waterResistanceBins: [String: Int]
}


