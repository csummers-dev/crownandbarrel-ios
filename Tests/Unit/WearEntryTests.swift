import XCTest
import GRDB
@testable import CrownAndBarrel

/// Tests for wear entry functionality, specifically validating:
/// 1. Creating watches and adding wear entries
/// 2. Foreign key constraints are properly enforced
/// 3. UUID encoding/decoding works correctly between watches and wearentry tables
/// 4. Duplicate wear entries on the same day are prevented
final class WearEntryTests: XCTestCase {
    
    var dbQueue: DatabaseQueue!
    var repository: WatchRepositoryGRDB!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory database for testing
        dbQueue = try DatabaseQueue()
        
        // Run migrations
        var migrator = DatabaseMigrator()
        
        // v1: Create schema
        migrator.registerMigration("v1_create_schema") { db in
            try db.create(table: "watches") { t in
                t.column("id", .text).primaryKey()
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
                t.column("case_json", .text).notNull().defaults(to: "{}")
                t.column("dial_json", .text).notNull().defaults(to: "{}")
                t.column("crystal_json", .text).notNull().defaults(to: "{}")
                t.column("movement_type", .text)
                t.column("movement_json", .text).notNull().defaults(to: "{}")
                t.column("water_resistance_m", .integer)
                t.column("water_json", .text).notNull().defaults(to: "{}")
                t.column("strap_current_json", .text).notNull().defaults(to: "{}")
                t.column("ownership_condition", .text)
                t.column("ownership_date_acquired", .text)
                t.column("ownership_json", .text).notNull().defaults(to: "{}")
                t.column("has_photos", .integer).notNull().defaults(to: 0)
            }
        }
        
        // v3: Create wear entries table
        migrator.registerMigration("v3_create_wear_entries") { db in
            try db.execute(sql: "PRAGMA foreign_keys=ON;")
            
            try db.create(table: "wearentry") { t in
                t.column("id", .text).primaryKey()
                t.column("watch_id", .text).notNull().indexed().references("watches", onDelete: .cascade)
                t.column("date", .text).notNull()
            }
            
            try db.create(index: "idx_wear_entries_date", on: "wearentry", columns: ["date"])
            try db.create(index: "idx_wear_entries_watch_date", on: "wearentry", columns: ["watch_id", "date"])
        }
        
        try migrator.migrate(dbQueue)
        
        // Create repository with test database
        repository = WatchRepositoryGRDB(dbQueue: dbQueue)
    }
    
    override func tearDown() async throws {
        repository = nil
        dbQueue = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Test creating a watch and adding a wear entry
    /// This validates the critical UUID encoding fix
    func testCreateWatchAndAddWearEntry() async throws {
        // Create a test watch
        let watch = WatchV2(
            manufacturer: "Test Brand",
            modelName: "Test Model",
            movement: MovementSpec(type: .automatic),
            ownership: WatchOwnership(
                purchasePriceAmount: 1000,
                currentEstimatedValueAmount: 1200
            )
        )
        
        // Save watch to database
        try repository.create(watch)
        
        // Verify watch was saved
        let fetchedWatch = try repository.fetch(id: watch.id)
        XCTAssertNotNil(fetchedWatch, "Watch should be saved to database")
        XCTAssertEqual(fetchedWatch?.id, watch.id, "Watch ID should match")
        
        // Add wear entry for today
        let today = Date()
        try await repository.incrementWear(for: watch.id, on: today)
        
        // Verify wear entry was created
        let entries = try await repository.wearEntries(on: today)
        XCTAssertEqual(entries.count, 1, "Should have exactly one wear entry")
        XCTAssertEqual(entries.first?.watchId, watch.id, "Wear entry should reference the correct watch")
    }
    
    /// Test that duplicate wear entries on the same day are prevented
    func testPreventDuplicateWearEntriesOnSameDay() async throws {
        let watch = WatchV2(
            manufacturer: "Rolex",
            modelName: "Submariner",
            movement: MovementSpec(type: .automatic),
            ownership: WatchOwnership()
        )
        
        try repository.create(watch)
        
        let today = Date()
        
        // Add wear entry
        try await repository.incrementWear(for: watch.id, on: today)
        
        // Try to add another wear entry for the same day
        try await repository.incrementWear(for: watch.id, on: today)
        
        // Should still have only one entry
        let entries = try await repository.wearEntries(on: today)
        XCTAssertEqual(entries.count, 1, "Should not create duplicate wear entries for the same day")
    }
    
    /// Test that foreign key constraint prevents orphaned wear entries
    func testForeignKeyConstraintPreventsOrphanedEntries() async throws {
        let watch = WatchV2(
            manufacturer: "Omega",
            modelName: "Speedmaster",
            movement: MovementSpec(type: .manual),
            ownership: WatchOwnership()
        )
        
        try repository.create(watch)
        
        // Add wear entry
        try await repository.incrementWear(for: watch.id, on: Date())
        
        // Delete the watch
        try repository.delete(id: watch.id)
        
        // Wear entry should be automatically deleted due to CASCADE
        let entries = try await repository.wearEntries(on: Date())
        XCTAssertEqual(entries.count, 0, "Wear entries should be deleted when parent watch is deleted")
    }
    
    /// Test adding wear entries for multiple watches on the same day
    func testMultipleWatchesOnSameDay() async throws {
        let watch1 = WatchV2(
            manufacturer: "Seiko",
            modelName: "SKX007",
            movement: MovementSpec(type: .automatic),
            ownership: WatchOwnership()
        )
        
        let watch2 = WatchV2(
            manufacturer: "Casio",
            modelName: "G-Shock",
            movement: MovementSpec(type: .quartz),
            ownership: WatchOwnership()
        )
        
        try repository.create(watch1)
        try repository.create(watch2)
        
        let today = Date()
        
        // Add wear entries for both watches
        try await repository.incrementWear(for: watch1.id, on: today)
        try await repository.incrementWear(for: watch2.id, on: today)
        
        // Should have two entries
        let entries = try await repository.wearEntries(on: today)
        XCTAssertEqual(entries.count, 2, "Should have wear entries for both watches")
        
        let watchIds = Set(entries.map { $0.watchId })
        XCTAssertTrue(watchIds.contains(watch1.id), "Should have entry for watch 1")
        XCTAssertTrue(watchIds.contains(watch2.id), "Should have entry for watch 2")
    }
    
    /// Test wear entries on different days
    func testWearEntriesOnDifferentDays() async throws {
        let watch = WatchV2(
            manufacturer: "Tudor",
            modelName: "Black Bay",
            movement: MovementSpec(type: .automatic),
            ownership: WatchOwnership()
        )
        
        try repository.create(watch)
        
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        // Add wear entries for different days
        try await repository.incrementWear(for: watch.id, on: today)
        try await repository.incrementWear(for: watch.id, on: yesterday)
        try await repository.incrementWear(for: watch.id, on: twoDaysAgo)
        
        // Verify each day has its entry
        let todayEntries = try await repository.wearEntries(on: today)
        XCTAssertEqual(todayEntries.count, 1, "Should have entry for today")
        
        let yesterdayEntries = try await repository.wearEntries(on: yesterday)
        XCTAssertEqual(yesterdayEntries.count, 1, "Should have entry for yesterday")
        
        let twoDaysAgoEntries = try await repository.wearEntries(on: twoDaysAgo)
        XCTAssertEqual(twoDaysAgoEntries.count, 1, "Should have entry for two days ago")
        
        // Verify total wear count
        let totalWearCount = try await repository.totalWearCount()
        XCTAssertEqual(totalWearCount, 3, "Should have three total wear entries")
    }
    
    /// Test UUID encoding/decoding between tables
    /// This is the critical test for the bug fix
    func testUUIDEncodingConsistency() async throws {
        let watch = WatchV2(
            manufacturer: "Grand Seiko",
            modelName: "Snowflake",
            movement: MovementSpec(type: .automatic),
            ownership: WatchOwnership()
        )
        
        try repository.create(watch)
        
        // Verify the UUID is stored as TEXT in the watches table
        let watchIdFromDB = try dbQueue.read { db in
            try String.fetchOne(db, sql: "SELECT id FROM watches WHERE id = ?", arguments: [watch.id.uuidString])
        }
        XCTAssertNotNil(watchIdFromDB, "Watch ID should be stored as TEXT")
        XCTAssertEqual(watchIdFromDB, watch.id.uuidString, "Watch ID should match UUID string format")
        
        // Add wear entry
        try await repository.incrementWear(for: watch.id, on: Date())
        
        // Verify the UUID is stored as TEXT in the wearentry table
        let wearWatchIdFromDB = try dbQueue.read { db in
            try String.fetchOne(db, sql: "SELECT watch_id FROM wearentry WHERE watch_id = ?", arguments: [watch.id.uuidString])
        }
        XCTAssertNotNil(wearWatchIdFromDB, "Wear entry watch_id should be stored as TEXT")
        XCTAssertEqual(wearWatchIdFromDB, watch.id.uuidString, "Wear entry watch_id should match UUID string format")
        
        // Verify they match (critical for foreign key constraint)
        XCTAssertEqual(watchIdFromDB, wearWatchIdFromDB, "UUIDs should be stored identically in both tables")
    }
    
    /// Test wear count statistics
    func testWearCountStatistics() async throws {
        let watch1 = WatchV2(
            manufacturer: "Rolex",
            modelName: "Submariner",
            movement: MovementSpec(type: .automatic),
            ownership: WatchOwnership()
        )
        
        let watch2 = WatchV2(
            manufacturer: "Omega",
            modelName: "Seamaster",
            movement: MovementSpec(type: .automatic),
            ownership: WatchOwnership()
        )
        
        try repository.create(watch1)
        try repository.create(watch2)
        
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Add wear entries
        try await repository.incrementWear(for: watch1.id, on: today)
        try await repository.incrementWear(for: watch1.id, on: yesterday)
        try await repository.incrementWear(for: watch2.id, on: today)
        
        // Test total wear count
        let totalWears = try await repository.totalWearCount()
        XCTAssertEqual(totalWears, 3, "Should have 3 total wear entries")
        
        // Test wear count for specific watch
        let watch1Wears = try await repository.wearCountForWatch(watchId: watch1.id)
        XCTAssertEqual(watch1Wears, 2, "Watch 1 should have 2 wear entries")
        
        let watch2Wears = try await repository.wearCountForWatch(watchId: watch2.id)
        XCTAssertEqual(watch2Wears, 1, "Watch 2 should have 1 wear entry")
        
        // Test unique days with entries
        let uniqueDays = try await repository.uniqueDaysWithEntries()
        XCTAssertEqual(uniqueDays, 2, "Should have entries on 2 unique days")
    }
}

