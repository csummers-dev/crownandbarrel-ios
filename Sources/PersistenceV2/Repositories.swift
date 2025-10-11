import Foundation
import GRDB
import OSLog
import ZIPFoundation

public protocol WatchRepositoryV2: Sendable {
    func create(_ watch: WatchV2) throws
    func update(_ watch: WatchV2) throws
    func delete(id: UUID) throws
    func fetch(id: UUID) throws -> WatchV2?
    func list(sortedBy: WatchSort, filters: WatchFilters) throws -> [WatchV2]

    // Wear entry methods
    func wearEntries(on date: Date) async throws -> [WearEntry]
    func incrementWear(for watchId: UUID, on date: Date) async throws
    func fetchAll() async throws -> [WatchV2]

    // Achievement-related queries
    func totalWatchCount() async throws -> Int
    func totalWearCount() async throws -> Int
    func wearCountForWatch(watchId: UUID) async throws -> Int
    func lastWornDate(watchId: UUID) async throws -> Date?
    func uniqueBrandsCount() async throws -> Int
    func currentStreak() async throws -> Int
    func allWearEntries() async throws -> [WearEntry]
    func wearEntriesForWatch(watchId: UUID) async throws -> [WearEntry]
    func uniqueDaysWithEntries() async throws -> Int
    func firstWearDate() async throws -> Date?
    func firstWatchDate() async throws -> Date?
}

public enum WatchSort {
    case manufacturerLineModel
    case updatedAtDesc
}

public struct WatchFilters: Sendable {
    public var searchText: String?
    public var manufacturer: String?
    public var line: String?
    public var movementType: String?
    public var waterResistanceMin: Int?
    public var waterResistanceMax: Int?
    public var tags: [String] = []
    public var condition: String?
    public var countryOfOrigin: String?
    public var purchaseDateStart: Date?
    public var purchaseDateEnd: Date?
    public var hasPhotos: Bool?

    public init() {}
}

public final class WatchRepositoryGRDB: WatchRepositoryV2 {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue = AppDatabase.shared.dbQueue) {
        self.dbQueue = dbQueue
    }

    /// Ensures foreign keys are enabled for every database operation
    private func ensureForeignKeysEnabled(_ db: Database) throws {
        try db.execute(sql: "PRAGMA foreign_keys=ON;")
        let foreignKeysEnabled = try Bool.fetchOne(db, sql: "PRAGMA foreign_keys") ?? false
        if !foreignKeysEnabled {
            print("⚠️ CRITICAL: Foreign keys are still disabled after PRAGMA foreign_keys=ON!")
        }
    }

    // MARK: - CRUD

    public func create(_ watch: WatchV2) throws {
        try dbQueue.write { db in
            // Ensure foreign keys are enabled for data integrity
            try ensureForeignKeysEnabled(db)

            try insertWatch(db: db, watch: watch)
            try upsertChildren(db: db, watchId: watch.id, watch: watch)
            try updateHasPhotosFlag(db: db, watchId: watch.id)
        }
    }

    public func update(_ watch: WatchV2) throws {
        try dbQueue.write { db in
            // Ensure foreign keys are enabled for data integrity
            try ensureForeignKeysEnabled(db)

            try updateWatch(db: db, watch: watch)
            try deleteChildren(db: db, watchId: watch.id)
            try upsertChildren(db: db, watchId: watch.id, watch: watch)
            try updateHasPhotosFlag(db: db, watchId: watch.id)
        }
    }

    public func delete(id: UUID) throws {
        try dbQueue.write { db in
            // Ensure foreign keys are enabled for data integrity
            try ensureForeignKeysEnabled(db)

            _ = try Row.fetchOne(db, sql: "DELETE FROM watches WHERE id = ?", arguments: [id.uuidString])
        }
    }

    public func fetch(id: UUID) throws -> WatchV2? {
        try dbQueue.read { db in
            guard let row = try Row.fetchOne(db, sql: "SELECT * FROM watches WHERE id = ?", arguments: [id.uuidString]) else { return nil }
            return try self.inflateAggregate(db: db, row: row)
        }
    }

    public func list(sortedBy: WatchSort = .manufacturerLineModel, filters: WatchFilters = .init()) throws -> [WatchV2] {
        try dbQueue.read { db in
            var sql = "SELECT * FROM watches"
            var args: [DatabaseValueConvertible] = []
            var clauses: [String] = []

            // Search functionality - search across multiple fields
            if let search = filters.searchText, !search.isEmpty {
                let searchPattern = "%\(search)%"
                clauses.append("""
                    (manufacturer LIKE ? OR
                     line LIKE ? OR
                     model_name LIKE ? OR
                     reference_number LIKE ? OR
                     nickname LIKE ? OR
                     serial_number LIKE ? OR
                     notes LIKE ? OR
                     tags_json LIKE ?)
                    """)
                args.append(contentsOf: [searchPattern, searchPattern, searchPattern, searchPattern, searchPattern, searchPattern, searchPattern, searchPattern])
            }

            if let m = filters.manufacturer { clauses.append("manufacturer = ?"); args.append(m) }
            if let l = filters.line { clauses.append("line = ?"); args.append(l) }
            if let mt = filters.movementType { clauses.append("movement_type = ?"); args.append(mt) }
            if let c = filters.condition { clauses.append("ownership_condition = ?"); args.append(c) }
            if let coo = filters.countryOfOrigin { clauses.append("country_of_origin = ?"); args.append(coo) }
            if let minWR = filters.waterResistanceMin { clauses.append("water_resistance_m >= ?"); args.append(minWR) }
            if let maxWR = filters.waterResistanceMax { clauses.append("water_resistance_m <= ?"); args.append(maxWR) }
            if let hp = filters.hasPhotos { clauses.append("has_photos = ?"); args.append(hp ? 1 : 0) }
            if let start = filters.purchaseDateStart { clauses.append("ownership_date_acquired >= ?"); args.append(ISO8601.string(from: start)) }
            if let end = filters.purchaseDateEnd { clauses.append("ownership_date_acquired <= ?"); args.append(ISO8601.string(from: end)) }
            if !filters.tags.isEmpty {
                for tag in filters.tags {
                    clauses.append("tags_json LIKE ?")
                    args.append("%\"\(tag)\"%")
                }
            }

            if !clauses.isEmpty {
                sql += " WHERE " + clauses.joined(separator: " AND ")
            }

            switch sortedBy {
            case .manufacturerLineModel: sql += " ORDER BY manufacturer, line, model_name"
            case .updatedAtDesc: sql += " ORDER BY updated_at DESC"
            }

            let rows = try Row.fetchAll(db, sql: sql, arguments: StatementArguments(args))
            return try rows.map { try self.inflateAggregate(db: db, row: $0) }
        }
    }

    // MARK: - Internals

    private func insertWatch(db: Database, watch: WatchV2) throws {
        try db.execute(sql: """
            INSERT INTO watches (
              id, created_at, updated_at, manufacturer, line, model_name, reference_number, nickname,
              serial_number, production_year, country_of_origin, limited_edition_number, notes,
              tags_json, case_json, dial_json, crystal_json, movement_type, movement_json,
              water_resistance_m, water_json, strap_current_json, ownership_condition, ownership_date_acquired, ownership_json, has_photos
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
        """,
        arguments: [
            watch.id.uuidString,
            ISO8601.string(from: watch.createdAt),
            ISO8601.string(from: watch.updatedAt),
            watch.manufacturer,
            watch.line,
            watch.modelName,
            watch.referenceNumber,
            watch.nickname,
            watch.serialNumber,
            watch.productionYear,
            watch.countryOfOrigin,
            watch.limitedEditionNumber,
            watch.notes,
            try encodeJSON(watch.tags),
            try encodeJSON(watch.watchCase),
            try encodeJSON(watch.dial),
            try encodeJSON(watch.crystal),
            watch.movement.type?.rawValue,
            try encodeJSON(watch.movement),
            watch.water.waterResistanceM,
            try encodeJSON(watch.water),
            try encodeJSON(watch.strapCurrent),
            watch.ownership.condition?.asString(),
            watch.ownership.dateAcquired.map(ISO8601.string(from:)),
            try encodeJSON(watch.ownership)
        ])
    }

    private func updateWatch(db: Database, watch: WatchV2) throws {
        try db.execute(sql: """
            UPDATE watches SET
              created_at = ?,
              updated_at = ?,
              manufacturer = ?, line = ?, model_name = ?, reference_number = ?, nickname = ?,
              serial_number = ?, production_year = ?, country_of_origin = ?, limited_edition_number = ?, notes = ?,
              tags_json = ?, case_json = ?, dial_json = ?, crystal_json = ?, movement_type = ?, movement_json = ?,
              water_resistance_m = ?, water_json = ?, strap_current_json = ?, ownership_condition = ?, ownership_date_acquired = ?, ownership_json = ?
            WHERE id = ?
        """,
        arguments: [
            ISO8601.string(from: watch.createdAt),
            ISO8601.string(from: watch.updatedAt),
            watch.manufacturer,
            watch.line,
            watch.modelName,
            watch.referenceNumber,
            watch.nickname,
            watch.serialNumber,
            watch.productionYear,
            watch.countryOfOrigin,
            watch.limitedEditionNumber,
            watch.notes,
            try encodeJSON(watch.tags),
            try encodeJSON(watch.watchCase),
            try encodeJSON(watch.dial),
            try encodeJSON(watch.crystal),
            watch.movement.type?.rawValue,
            try encodeJSON(watch.movement),
            watch.water.waterResistanceM,
            try encodeJSON(watch.water),
            try encodeJSON(watch.strapCurrent),
            watch.ownership.condition?.asString(),
            watch.ownership.dateAcquired.map(ISO8601.string(from:)),
            try encodeJSON(watch.ownership),
            watch.id.uuidString
        ])
    }

    private func upsertChildren(db: Database, watchId: UUID, watch: WatchV2) throws {
        for p in watch.photos {
            try db.execute(sql: """
                INSERT INTO watch_photos (id, watch_id, local_identifier, is_primary, position)
                VALUES (?, ?, ?, ?, ?)
            """, arguments: [p.id.uuidString, watchId.uuidString, p.localIdentifier, p.isPrimary ? 1 : 0, p.position])
        }
        for s in watch.serviceHistory {
            try db.execute(sql: """
                INSERT INTO service_history (id, watch_id, date, provider, work_description, cost_amount, cost_currency, warranty_until)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, arguments: [
                s.id.uuidString, watchId.uuidString,
                s.date.map(ISO8601.string(from:)), s.provider, s.workDescription,
                s.costAmount.map { NSDecimalNumber(decimal: $0).doubleValue }, s.costCurrency,
                s.warrantyUntil.map(ISO8601.string(from:))
            ])
        }
        for v in watch.valuations {
            try db.execute(sql: """
                INSERT INTO valuations (id, watch_id, date, source, value_amount, value_currency)
                VALUES (?, ?, ?, ?, ?, ?)
            """, arguments: [
                v.id.uuidString, watchId.uuidString,
                v.date.map(ISO8601.string(from:)), v.source?.asString(),
                v.valueAmount.map { NSDecimalNumber(decimal: $0).doubleValue }, v.valueCurrency
            ])
        }
        for st in watch.straps {
            try db.execute(sql: """
                INSERT INTO straps_inventory (id, watch_id, type, material, color, width_mm, clasp_type, quick_release)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, arguments: [
                st.id.uuidString, watchId.uuidString,
                st.type?.asString(), st.material, st.color, st.widthMM, st.claspType?.asString(), st.quickRelease ? 1 : 0
            ])
        }
    }

    private func deleteChildren(db: Database, watchId: UUID) throws {
        try db.execute(sql: "DELETE FROM watch_photos WHERE watch_id = ?", arguments: [watchId.uuidString])
        try db.execute(sql: "DELETE FROM service_history WHERE watch_id = ?", arguments: [watchId.uuidString])
        try db.execute(sql: "DELETE FROM valuations WHERE watch_id = ?", arguments: [watchId.uuidString])
        try db.execute(sql: "DELETE FROM straps_inventory WHERE watch_id = ?", arguments: [watchId.uuidString])
    }

    private func updateHasPhotosFlag(db: Database, watchId: UUID) throws {
        let count = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM watch_photos WHERE watch_id = ?", arguments: [watchId.uuidString]) ?? 0
        try db.execute(sql: "UPDATE watches SET has_photos = ? WHERE id = ?", arguments: [count > 0 ? 1 : 0, watchId.uuidString])
    }

    private func inflateAggregate(db: Database, row: Row) throws -> WatchV2 {
        let id = UUID(uuidString: row["id"]) ?? UUID()
        let createdAt = ISO8601.date(from: row["created_at"]) ?? Date()
        let updatedAt = ISO8601.date(from: row["updated_at"]) ?? Date()

        // Decode JSON value objects
        let tags: [String] = try decodeJSON(row["tags_json"]) ?? []
        let watchCase: WatchCase = try decodeJSON(row["case_json"]) ?? WatchCase()
        let dial: WatchDial = try decodeJSON(row["dial_json"]) ?? WatchDial()
        let crystal: WatchCrystal = try decodeJSON(row["crystal_json"]) ?? WatchCrystal()
        var movement: MovementSpec = try decodeJSON(row["movement_json"]) ?? MovementSpec()
        if let rawType: String = row["movement_type"], let typed = MovementType(rawValue: rawType) { movement.type = typed }
        var water: WatchWater = try decodeJSON(row["water_json"]) ?? WatchWater()
        if let wrm: Int = row["water_resistance_m"] { water.waterResistanceM = wrm }
        let strap: WatchStrapCurrent = try decodeJSON(row["strap_current_json"]) ?? WatchStrapCurrent()
        var ownership: WatchOwnership = try decodeJSON(row["ownership_json"]) ?? WatchOwnership()
        ownership.condition = (row["ownership_condition"] as String?).map { OwnershipCondition.fromString($0) }
        ownership.dateAcquired = (row["ownership_date_acquired"] as String?).flatMap(ISO8601.date(from:))

        // Children
        let photos = try Row.fetchAll(db, sql: "SELECT * FROM watch_photos WHERE watch_id = ? ORDER BY position", arguments: [id.uuidString]).map { r -> WatchPhoto in
            WatchPhoto(
                id: UUID(uuidString: r["id"]) ?? UUID(),
                localIdentifier: r["local_identifier"],
                isPrimary: (r["is_primary"] as Int) == 1,
                position: r["position"]
            )
        }
        let serviceHistory = try Row.fetchAll(db, sql: "SELECT * FROM service_history WHERE watch_id = ? ORDER BY date DESC NULLS LAST", arguments: [id.uuidString]).map { r -> ServiceHistoryEntry in
            ServiceHistoryEntry(
                id: UUID(uuidString: r["id"]) ?? UUID(),
                date: (r["date"] as String?).flatMap(ISO8601.date(from:)),
                provider: r["provider"],
                workDescription: r["work_description"],
                costAmount: (r["cost_amount"] as Double?).map { Decimal($0) },
                costCurrency: r["cost_currency"],
                warrantyUntil: (r["warranty_until"] as String?).flatMap(ISO8601.date(from:))
            )
        }
        let valuations = try Row.fetchAll(db, sql: "SELECT * FROM valuations WHERE watch_id = ? ORDER BY date DESC NULLS LAST", arguments: [id.uuidString]).map { r -> ValuationEntry in
            ValuationEntry(
                id: UUID(uuidString: r["id"]) ?? UUID(),
                date: (r["date"] as String?).flatMap(ISO8601.date(from:)),
                source: (r["source"] as String?).map { ValuationSource.fromString($0) },
                valueAmount: (r["value_amount"] as Double?).map { Decimal($0) },
                valueCurrency: r["value_currency"]
            )
        }
        let straps = try Row.fetchAll(db, sql: "SELECT * FROM straps_inventory WHERE watch_id = ?", arguments: [id.uuidString]).map { r -> StrapInventoryItem in
            StrapInventoryItem(
                id: UUID(uuidString: r["id"]) ?? UUID(),
                type: (r["type"] as String?).map { StrapType.fromString($0) },
                material: r["material"],
                color: r["color"],
                widthMM: r["width_mm"],
                claspType: (r["clasp_type"] as String?).map { ClaspType.fromString($0) },
                quickRelease: (r["quick_release"] as Int) == 1
            )
        }

        return WatchV2(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            manufacturer: row["manufacturer"],
            line: row["line"],
            modelName: row["model_name"],
            referenceNumber: row["reference_number"],
            nickname: row["nickname"],
            serialNumber: row["serial_number"],
            productionYear: row["production_year"],
            countryOfOrigin: row["country_of_origin"],
            limitedEditionNumber: row["limited_edition_number"],
            notes: row["notes"],
            tags: WatchValidation.normalizeTags(tags),
            watchCase: watchCase,
            dial: dial,
            crystal: crystal,
            movement: movement,
            water: water,
            strapCurrent: strap,
            ownership: ownership,
            photos: WatchValidation.enforcePrimaryPhotoInvariant(photos),
            serviceHistory: serviceHistory,
            valuations: valuations,
            straps: straps
        )
    }

    // MARK: - Wear Entry Methods

    public func wearEntries(on date: Date) async throws -> [WearEntry] {
        try await dbQueue.read { db in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            return try WearEntry
                .filter(Column("date") >= startOfDay && Column("date") < endOfDay)
                .fetchAll(db)
        }
    }

    public func incrementWear(for watchId: UUID, on date: Date) async throws {
        let logger = Logger(subsystem: "com.crownandbarrel", category: "WearEntry")

        try await dbQueue.write { db in
            logger.info("🔍 incrementWear called for watchId: \(watchId.uuidString)")

            // CRITICAL: Always enable foreign keys at the start of every write operation
            // This ensures data integrity regardless of the prepareDatabase block
            try self.ensureForeignKeysEnabled(db)

            // Check foreign keys status for logging
            let foreignKeysEnabled = try Bool.fetchOne(db, sql: "PRAGMA foreign_keys") ?? false
            logger.info("🔍 Foreign keys enabled: \(foreignKeysEnabled)")

            // Verify watch exists
            let watchExists = try Bool.fetchOne(db, sql: "SELECT COUNT(*) > 0 FROM watches WHERE id = ?", arguments: [watchId.uuidString]) ?? false
            logger.info("🔍 Watch exists in DB: \(watchExists)")

            if !watchExists {
                logger.error("❌ Watch does not exist in database!")
                throw AppError.repository("Watch not found in database. ID: \(watchId.uuidString)")
            }

            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)

            logger.info("🔍 Checking for existing entry on: \(startOfDay.description)")

            // Check if entry already exists for this watch on this date (raw SQL for clarity)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let existingCount = try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM wearentry WHERE watch_id = ? AND date >= ? AND date < ?",
                arguments: [watchId.uuidString, ISO8601.string(from: startOfDay), ISO8601.string(from: endOfDay)]
            ) ?? 0
            logger.info("🔍 Existing entry count: \(existingCount)")

            if existingCount == 0 {
                // Create new wear entry
                let entry = WearEntry(watchId: watchId, date: startOfDay)
                logger.info("🔍 Attempting to insert wear entry: id=\(entry.id.uuidString), watchId=\(entry.watchId.uuidString)")

                do {
                    // Double-check foreign keys are enabled before insertion
                    try self.ensureForeignKeysEnabled(db)

                    try entry.insert(db)
                    logger.info("✅ Wear entry inserted successfully")
                } catch {
                    logger.error("❌ Insert failed: \(error.localizedDescription)")
                    // Log additional debugging info
                    let foreignKeysStatus = try? Bool.fetchOne(db, sql: "PRAGMA foreign_keys") ?? false
                    logger.error("❌ Foreign keys status at failure: \(foreignKeysStatus ?? false)")
                    throw error
                }
            } else {
                logger.info("ℹ️ Wear entry already exists, skipping insert")
            }
        }
    }

    public func fetchAll() async throws -> [WatchV2] {
        try list(sortedBy: .manufacturerLineModel, filters: WatchFilters())
    }

    // MARK: - Achievement-Related Queries

    public func totalWatchCount() async throws -> Int {
        try await dbQueue.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM watches") ?? 0
        }
    }

    public func totalWearCount() async throws -> Int {
        try await dbQueue.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM wearentry") ?? 0
        }
    }

    public func wearCountForWatch(watchId: UUID) async throws -> Int {
        try await dbQueue.read { db in
            try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM wearentry WHERE watch_id = ?",
                arguments: [watchId.uuidString]
            ) ?? 0
        }
    }

    public func lastWornDate(watchId: UUID) async throws -> Date? {
        try await dbQueue.read { db in
            // Get the most recent wear entry for this watch
            let entries = try WearEntry
                .filter(WearEntry.CodingKeys.watchId == watchId.uuidString)
                .order(WearEntry.CodingKeys.date.desc)
                .limit(1)
                .fetchAll(db)

            return entries.first?.date
        }
    }

    public func uniqueBrandsCount() async throws -> Int {
        try await dbQueue.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(DISTINCT manufacturer) FROM watches") ?? 0
        }
    }

    public func currentStreak() async throws -> Int {
        let allEntries = try await allWearEntries()
        guard !allEntries.isEmpty else { return 0 }

        // Sort entries by date descending (most recent first)
        let sortedEntries = allEntries.sorted { $0.date > $1.date }

        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        // Group entries by day
        var daySet = Set<Date>()
        for entry in sortedEntries {
            let day = calendar.startOfDay(for: entry.date)
            daySet.insert(day)
        }

        // Count consecutive days from today backwards
        while daySet.contains(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }

        return streak
    }

    public func allWearEntries() async throws -> [WearEntry] {
        try await dbQueue.read { db in
            try WearEntry.order(Column("date").desc).fetchAll(db)
        }
    }

    public func wearEntriesForWatch(watchId: UUID) async throws -> [WearEntry] {
        try await dbQueue.read { db in
            try WearEntry
                .filter(Column("watch_id") == watchId)
                .order(Column("date").desc)
                .fetchAll(db)
        }
    }

    public func uniqueDaysWithEntries() async throws -> Int {
        try await dbQueue.read { db in
            // Count distinct calendar days (ignoring time component)
            try Int.fetchOne(db, sql: """
                SELECT COUNT(DISTINCT DATE(date)) FROM wearentry
            """) ?? 0
        }
    }

    public func firstWearDate() async throws -> Date? {
        try await dbQueue.read { db in
            guard let dateString = try String.fetchOne(
                db,
                sql: "SELECT MIN(date) FROM wearentry"
            ) else {
                return nil
            }
            return ISO8601.date(from: dateString)
        }
    }

    public func firstWatchDate() async throws -> Date? {
        try await dbQueue.read { db in
            guard let dateString = try String.fetchOne(
                db,
                sql: "SELECT MIN(created_at) FROM watches"
            ) else {
                return nil
            }
            return ISO8601.date(from: dateString)
        }
    }
}

// MARK: - JSON helpers

private func encodeJSON<T: Encodable>(_ value: T) throws -> String {
    let data = try JSONEncoder().encode(value)
    return String(data: data, encoding: .utf8) ?? "{}"
}

private func decodeJSON<T: Decodable>(_ raw: String?) throws -> T? {
    guard let raw, let data = raw.data(using: .utf8) else { return nil }
    return try JSONDecoder().decode(T.self, from: data)
}

// MARK: - Backup Repository Implementation

public final class BackupRepositoryGRDB: BackupRepository {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue = AppDatabase.shared.dbQueue) {
        self.dbQueue = dbQueue
    }

    public func exportBackup() async throws -> URL {
        // Create temporary directory for backup
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Export database
        let dbFile = tempDir.appendingPathComponent("database.sqlite")
        try FileManager.default.copyItem(at: AppDatabase.shared.dbPath, to: dbFile)

        // Create ZIP archive
        let archiveURL = FileManager.default.temporaryDirectory.appendingPathComponent("backup-\(Date().timeIntervalSince1970).crownandbarrel")
        try FileManager.default.zipItem(at: tempDir, to: archiveURL)

        // Clean up temp directory
        try FileManager.default.removeItem(at: tempDir)

        return archiveURL
    }

    public func importBackup(from url: URL, replace: Bool) async throws {
        guard replace else {
            throw AppError.backupImportFailed("Replace must be true")
        }

        // Extract backup
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        try FileManager.default.unzipItem(at: url, to: tempDir)

        // Find database file
        let dbFile = tempDir.appendingPathComponent("database.sqlite")
        guard FileManager.default.fileExists(atPath: dbFile.path) else {
            throw AppError.backupImportFailed("Database file not found in backup")
        }

        // Replace current database
        try FileManager.default.removeItem(at: AppDatabase.shared.dbPath)
        try FileManager.default.copyItem(at: dbFile, to: AppDatabase.shared.dbPath)

        // Clean up temp directory
        try FileManager.default.removeItem(at: tempDir)
    }

    public func deleteAll() async throws {
        try await dbQueue.write { db in
            // Delete all data in correct order (children before parents due to FK constraints)
            try db.execute(sql: "DELETE FROM user_achievement_state")
            try db.execute(sql: "DELETE FROM wearentry")
            try db.execute(sql: "DELETE FROM watch_photos")
            try db.execute(sql: "DELETE FROM service_history")
            try db.execute(sql: "DELETE FROM valuations")
            try db.execute(sql: "DELETE FROM straps_inventory")
            try db.execute(sql: "DELETE FROM watches")
        }
    }
}
