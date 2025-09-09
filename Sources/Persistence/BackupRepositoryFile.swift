import Foundation
import CoreData
import ZIPFoundation

/// File-based implementation of `BackupRepository` using ZIP archives.
/// - What: Exports JSON + images to a `.goodwatch` zip; imports by replacing the store; deletes all data on request.
/// - Why: Keeps backups portable and explicit, and avoids partial merges that can corrupt referential integrity.
/// - How: Serializes domain objects, zips them with images, validates schema on import, and replaces the store.
public final class BackupRepositoryFile: BackupRepository {
    private let stack: CoreDataStack
    private let fileManager: FileManager

    public init(stack: CoreDataStack = .shared, fileManager: FileManager = .default) {
        self.stack = stack
        self.fileManager = fileManager
    }

    /// Exports a full-replace backup to a temporary `.goodwatch` file and returns its URL.
    public func exportBackup() async throws -> URL {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Prepare JSON payloads
        let watches = try await exportWatches()
        let wearEntries = try await exportWearEntries()
        let meta = BackupMetadata(schemaVersion: 1, exportedAt: Date())

        try JSONEncoder().encode(meta).write(to: tempDir.appendingPathComponent("metadata.json"))
        try JSONEncoder().encode(watches).write(to: tempDir.appendingPathComponent("watches.json"))
        try JSONEncoder().encode(wearEntries).write(to: tempDir.appendingPathComponent("wear_entries.json"))

        // Copy images folder if exists
        let imagesSrc = try? ImageStore.imagesDirectory()
        if let src = imagesSrc, fileManager.fileExists(atPath: src.path) {
            let dst = tempDir.appendingPathComponent("images", isDirectory: true)
            try fileManager.createDirectory(at: dst, withIntermediateDirectories: true)
            let contents = try fileManager.contentsOfDirectory(at: src, includingPropertiesForKeys: nil)
            for file in contents { try fileManager.copyItem(at: file, to: dst.appendingPathComponent(file.lastPathComponent)) }
        }

        let archiveURL = fileManager.temporaryDirectory.appendingPathComponent("GoodWatch_\(ISO8601DateFormatter().string(from: Date())).goodwatch")
        if fileManager.fileExists(atPath: archiveURL.path) { try fileManager.removeItem(at: archiveURL) }
        let archive = try Archive(url: archiveURL, accessMode: .create)
        if let enumerator = fileManager.enumerator(at: tempDir, includingPropertiesForKeys: nil) {
            while let any = enumerator.nextObject() {
                guard let url = any as? URL else { continue }
                if url.hasDirectoryPath { continue }
                let pathInArchive = url.path.replacingOccurrences(of: tempDir.path + "/", with: "")
                try archive.addEntry(with: pathInArchive, relativeTo: tempDir)
            }
        }
        return archiveURL
    }

    /// Imports a `.goodwatch` backup by fully replacing the store.
    /// - Note: `replace` must be true for safety. Import validates schema version and structure before applying.
    public func importBackup(from url: URL, replace: Bool) async throws {
        guard replace else { throw AppError.incompatibleBackup("Only full replace imports are supported.") }
        // Unzip to temp and validate
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let archive = try Archive(url: url, accessMode: .read)
        for entry in archive {
            let dest = tempDir.appendingPathComponent(entry.path)
            try fileManager.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
            _ = try archive.extract(entry, to: dest)
        }

        let metaURL = tempDir.appendingPathComponent("metadata.json")
        let watchesURL = tempDir.appendingPathComponent("watches.json")
        let wearURL = tempDir.appendingPathComponent("wear_entries.json")
        guard fileManager.fileExists(atPath: metaURL.path), fileManager.fileExists(atPath: watchesURL.path), fileManager.fileExists(atPath: wearURL.path) else {
            throw AppError.restoreFailed("Backup contents are missing required files.")
        }
        let meta = try JSONDecoder().decode(BackupMetadata.self, from: Data(contentsOf: metaURL))
        guard meta.schemaVersion == 1 else { throw AppError.incompatibleBackup("Incompatible schema version.") }

        let watches = try JSONDecoder().decode([Watch].self, from: Data(contentsOf: watchesURL))
        let wearEntries = try JSONDecoder().decode([WearEntry].self, from: Data(contentsOf: wearURL))

        // Replace store: delete all entities then re-insert
        try await deleteAll()
        try await stack.viewContext.perform { [self] in
            for w in watches {
                let obj = CDWatch(entity: NSEntityDescription.entity(forEntityName: "CDWatch", in: self.stack.viewContext)!, insertInto: self.stack.viewContext)
                Mappers.update(obj, from: w)
            }
            for e in wearEntries {
                let request = NSFetchRequest<CDWatch>(entityName: "CDWatch")
                request.predicate = NSPredicate(format: "id == %@", e.watchId as CVarArg)
                guard let watch = try? self.stack.viewContext.fetch(request).first else { continue }
                let wear = CDWearEntry(entity: NSEntityDescription.entity(forEntityName: "CDWearEntry", in: self.stack.viewContext)!, insertInto: self.stack.viewContext)
                wear.setValue(e.id, forKey: "id")
                wear.setValue(e.date, forKey: "date")
                wear.setValue(watch, forKey: "watch")
            }
            try? self.stack.saveContext()
        }

        // Replace images
        let extractedImages = tempDir.appendingPathComponent("images", isDirectory: true)
        if fileManager.fileExists(atPath: extractedImages.path) {
            let dst = try ImageStore.imagesDirectory()
            let contents = try fileManager.contentsOfDirectory(at: dst, includingPropertiesForKeys: nil)
            for file in contents { try? fileManager.removeItem(at: file) }
            let toCopy = try fileManager.contentsOfDirectory(at: extractedImages, includingPropertiesForKeys: nil)
            for file in toCopy { try fileManager.copyItem(at: file, to: dst.appendingPathComponent(file.lastPathComponent)) }
        }
    }

    /// Deletes all persisted objects and clears image files.
    /// - Why: Useful for reset scenarios and for preparing to restore a backup.
    public func deleteAll() async throws {
        try await stack.viewContext.perform { [self] in
            for entityName in ["CDWearEntry", "CDWatch", "CDAppSettings"] {
                let fetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
                let objects = try? self.stack.viewContext.fetch(fetch)
                objects?.forEach { self.stack.viewContext.delete($0) }
            }
            try? self.stack.saveContext()
        }
        // Also wipe images
        if let imagesDir = try? ImageStore.imagesDirectory() {
            let files = try fileManager.contentsOfDirectory(at: imagesDir, includingPropertiesForKeys: nil)
            for f in files { try? fileManager.removeItem(at: f) }
        }
    }
}

private struct BackupMetadata: Codable { let schemaVersion: Int; let exportedAt: Date }

// MARK: - Private helpers
extension BackupRepositoryFile {
    /// Reads all watches from the current store and returns them as domain models.
    fileprivate func exportWatches() async throws -> [Watch] {
        try await stack.viewContext.perform { [self] in
            let request = NSFetchRequest<CDWatch>(entityName: "CDWatch")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let results = try self.stack.viewContext.fetch(request)
            return results.map(Mappers.toDomain)
        }
    }

    /// Reads all wear entries from the current store and returns them as domain models.
    fileprivate func exportWearEntries() async throws -> [WearEntry] {
        try await stack.viewContext.perform { [self] in
            let request = NSFetchRequest<CDWearEntry>(entityName: "CDWearEntry")
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            let results = try self.stack.viewContext.fetch(request)
            return results.map(Mappers.toDomain)
        }
    }
}


