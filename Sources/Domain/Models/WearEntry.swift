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

    // MARK: - GRDB Table and Column Mapping

    /// Specifies the exact database table name (all lowercase)
    public static let databaseTableName = "wearentry"

    /// Explicit CodingKeys to map Swift properties to snake_case database columns
    /// Database uses snake_case consistent with all other tables
    public enum CodingKeys: String, CodingKey, ColumnExpression {
        case id
        case watchId = "watch_id"  // Swift: watchId, Database: watch_id
        case date
    }

    // MARK: - GRDB Custom Encoding/Decoding
    // CRITICAL: GRDB by default encodes UUIDs as 16-byte BLOBs, but our watches table uses TEXT!
    // We must explicitly encode as strings to match the foreign key constraint

    /// Encode values to database (convert UUIDs to uppercase strings to match watches table)
    public func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id.uuidString
        container["watch_id"] = watchId.uuidString  // CRITICAL: Must be string, not blob!
        container["date"] = ISO8601DateFormatter().string(from: date)
    }

    /// Decode values from database
    public init(row: Row) throws {
        let idString: String = row["id"]
        let watchIdString: String = row["watch_id"]
        let dateString: String = row["date"]

        guard let id = UUID(uuidString: idString),
              let watchId = UUID(uuidString: watchIdString),
              let date = ISO8601DateFormatter().date(from: dateString) else {
            throw DatabaseError(resultCode: .SQLITE_ERROR, message: "Invalid WearEntry data in row")
        }

        self.id = id
        self.watchId = watchId
        self.date = date
    }
}
