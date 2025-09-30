import Foundation
import GRDB

public final class AppDatabase {
    public static let shared = try! AppDatabase()

    public let dbQueue: DatabaseQueue
    public let dbPath: URL

    private init() throws {
        let url = try AppDatabase.databaseURL()
        var config = Configuration()
        config.prepareDatabase { db in
            // Use WAL for better concurrency and crash resilience
            try db.execute(sql: "PRAGMA journal_mode=WAL;")
            try db.execute(sql: "PRAGMA foreign_keys=ON;")
        }
        dbPath = url
        dbQueue = try DatabaseQueue(path: url.path, configuration: config)
        try migrator.migrate(dbQueue)
    }

    private static func databaseURL() throws -> URL {
        let fm = FileManager.default
        let base = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = base.appendingPathComponent("CrownAndBarrel", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("crownandbarrel.db")
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_create_schema") { db in
            // watches table (aggregate root)
            try db.create(table: "watches") { t in
                t.column("id", .text).primaryKey() // UUID string
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()

                t.column("manufacturer", .text).notNull()
                t.column("line", .text)
                t.column("model_name", .text).notNull()
                t.column("reference_number", .text)
                t.column("nickname", .text)

                t.column("serial_number", .text)
                t.column("production_year", .integer)
                t.column("country_of_origin", .text)
                t.column("limited_edition_number", .text)
                t.column("notes", .text)

                t.column("tags_json", .text).notNull().defaults(to: "[]")

                // Nested value objects stored as JSON for flexibility
                t.column("case_json", .text).notNull().defaults(to: "{}")
                t.column("dial_json", .text).notNull().defaults(to: "{}")
                t.column("crystal_json", .text).notNull().defaults(to: "{}")
                t.column("movement_type", .text) // indexed separately for filters
                t.column("movement_json", .text).notNull().defaults(to: "{}")
                t.column("water_resistance_m", .integer)
                t.column("water_json", .text).notNull().defaults(to: "{}")
                t.column("strap_current_json", .text).notNull().defaults(to: "{}")
                t.column("ownership_condition", .text)
                t.column("ownership_date_acquired", .text)
                t.column("ownership_json", .text).notNull().defaults(to: "{}")

                t.column("has_photos", .integer).notNull().defaults(to: 0)
            }

            try db.create(table: "watch_photos") { t in
                t.column("id", .text).primaryKey()
                t.column("watch_id", .text).notNull().indexed().references("watches", onDelete: .cascade)
                t.column("local_identifier", .text).notNull()
                t.column("is_primary", .integer).notNull().defaults(to: 0)
                t.column("position", .integer).notNull().defaults(to: 0)
            }

            try db.create(table: "service_history") { t in
                t.column("id", .text).primaryKey()
                t.column("watch_id", .text).notNull().indexed().references("watches", onDelete: .cascade)
                t.column("date", .text)
                t.column("provider", .text)
                t.column("work_description", .text)
                t.column("cost_amount", .double)
                t.column("cost_currency", .text)
                t.column("warranty_until", .text)
            }

            try db.create(table: "valuations") { t in
                t.column("id", .text).primaryKey()
                t.column("watch_id", .text).notNull().indexed().references("watches", onDelete: .cascade)
                t.column("date", .text)
                t.column("source", .text)
                t.column("value_amount", .double)
                t.column("value_currency", .text)
            }

            try db.create(table: "straps_inventory") { t in
                t.column("id", .text).primaryKey()
                t.column("watch_id", .text).notNull().indexed().references("watches", onDelete: .cascade)
                t.column("type", .text)
                t.column("material", .text)
                t.column("color", .text)
                t.column("width_mm", .integer)
                t.column("clasp_type", .text)
                t.column("quick_release", .integer).notNull().defaults(to: 0)
            }

            // Indexes
            try db.create(index: "idx_watches_mfr_line_model", on: "watches", columns: ["manufacturer", "line", "model_name"])           
            try db.create(index: "idx_watches_movement_type", on: "watches", columns: ["movement_type"])           
            try db.create(index: "idx_watches_water_resistance", on: "watches", columns: ["water_resistance_m"])           
            try db.create(index: "idx_watches_condition", on: "watches", columns: ["ownership_condition"])           
            try db.create(index: "idx_watches_ownership_date", on: "watches", columns: ["ownership_date_acquired"])           
            try db.create(index: "idx_watches_updated_at", on: "watches", columns: ["updated_at"])           
            try db.create(index: "idx_watches_has_photos", on: "watches", columns: ["has_photos"]) 
        }

        // v2: add explicit ownership_date_acquired column for efficient filtering
        migrator.registerMigration("v2_add_ownership_date") { db in
            // Check if column exists by querying table info
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(watches)")
            let hasColumn = columns.contains { row in
                (row["name"] as String?) == "ownership_date_acquired"
            }
            
            if !hasColumn {
                try db.alter(table: "watches") { t in
                    t.add(column: "ownership_date_acquired", .text)
                }
                try db.create(index: "idx_watches_ownership_date", on: "watches", columns: ["ownership_date_acquired"])           
            }
        }

        // v3: add wear entries table for tracking when watches are worn
        migrator.registerMigration("v3_create_wear_entries") { db in
            // Check if table already exists
            let tableExists = try Bool.fetchOne(db, sql: """
                SELECT COUNT(*) > 0 FROM sqlite_master 
                WHERE type='table' AND name='wearEntries'
            """) ?? false
            
            if !tableExists {
                try db.create(table: "wearEntries") { t in
                    t.column("id", .text).primaryKey() // UUID string
                    t.column("watchId", .text).notNull().indexed().references("watches", onDelete: .cascade)
                    t.column("date", .text).notNull()
                }
                
                // Index for efficient date-range queries
                try db.create(index: "idx_wear_entries_date", on: "wearEntries", columns: ["date"])
                // Composite index for watch-specific queries
                try db.create(index: "idx_wear_entries_watch_date", on: "wearEntries", columns: ["watchId", "date"])
            }
        }

        // v4: add achievements system tables
        migrator.registerMigration("v4_create_achievements") { db in
            // achievements table (definitions - these are constant and defined in code)
            try db.create(table: "achievements") { t in
                t.column("id", .text).primaryKey() // UUID string
                t.column("name", .text).notNull()
                t.column("description", .text).notNull()
                t.column("image_asset_name", .text).notNull()
                t.column("category", .text).notNull() // AchievementCategory rawValue
                t.column("criteria_json", .text).notNull() // AchievementCriteria encoded as JSON
                t.column("target_value", .double).notNull()
                t.column("created_at", .text).notNull()
            }
            
            // user_achievement_state table (user's progress for each achievement)
            try db.create(table: "user_achievement_state") { t in
                t.column("id", .text).primaryKey() // UUID string
                t.column("achievement_id", .text).notNull().indexed().references("achievements", onDelete: .cascade)
                t.column("is_unlocked", .integer).notNull().defaults(to: 0) // Boolean as integer
                t.column("unlocked_at", .text) // Nullable - only set when unlocked
                t.column("current_progress", .double).notNull().defaults(to: 0.0)
                t.column("progress_target", .double).notNull()
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
            }
            
            // Indexes for efficient queries
            try db.create(index: "idx_user_achievement_state_unlocked", on: "user_achievement_state", columns: ["is_unlocked"])
            try db.create(index: "idx_user_achievement_state_achievement_id", on: "user_achievement_state", columns: ["achievement_id"])
            
            // Composite index for filtering unlocked achievements
            try db.create(index: "idx_user_achievement_state_unlocked_date", on: "user_achievement_state", columns: ["is_unlocked", "unlocked_at"])
        }

        return migrator
    }
}

// MARK: - ISO8601 helpers

public enum ISO8601 {
    public static let formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    public static func string(from date: Date) -> String { formatter.string(from: date) }
    public static func date(from string: String) -> Date? { formatter.date(from: string) }
}


