import Foundation
import GRDB

/// Domain model representing a single wear entry for a watch on a specific date.
public struct WearEntry: Identifiable, Hashable, Codable, FetchableRecord, PersistableRecord {
    public let id: UUID
    public let watchId: UUID
    public let date: Date

    public init(id: UUID = UUID(), watchId: UUID, date: Date) {
        self.id = id
        self.watchId = watchId
        self.date = date
    }
    
    // MARK: - GRDB Column Mapping
    
    /// Explicit CodingKeys to map Swift properties to snake_case database columns
    /// Database uses snake_case consistent with all other tables
    public enum CodingKeys: String, CodingKey, ColumnExpression {
        case id
        case watchId = "watch_id"  // Swift: watchId, Database: watch_id
        case date
    }
}


