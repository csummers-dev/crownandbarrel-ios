import Foundation

public struct WearingRankItem: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let watch: WatchV2
    public let daysWorn: Int
    public let lastWornDateInRange: Date?
}


