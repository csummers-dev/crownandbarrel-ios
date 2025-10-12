import Foundation

public struct NeglectItem: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let watch: WatchV2
    public let daysSinceLastWear: Int?
    public let isNeglectedInRange: Bool
}


