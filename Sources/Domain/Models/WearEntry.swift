import Foundation

/// Domain model representing a single wear entry for a watch on a specific date.
public struct WearEntry: Identifiable, Hashable, Codable {
    public let id: UUID
    public let watchId: UUID
    public let date: Date

    public init(id: UUID = UUID(), watchId: UUID, date: Date) {
        self.id = id
        self.watchId = watchId
        self.date = date
    }
}


