import Foundation

/// Repository abstraction for backup/restore operations.
public protocol BackupRepository {
    /// Exports a full-replace backup and returns the file URL of the generated `.goodwatch` archive.
    func exportBackup() async throws -> URL

    /// Imports a backup from the provided URL. Replace must be true for now.
    func importBackup(from url: URL, replace: Bool) async throws

    /// Deletes all persisted data. Callers must enforce double confirmation.
    func deleteAll() async throws
}


