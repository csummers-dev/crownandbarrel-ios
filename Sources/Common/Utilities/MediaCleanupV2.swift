import Foundation
import GRDB

public enum MediaCleanupV2 {
    public static func run(dbQueue: DatabaseQueue = AppDatabase.shared.dbQueue) {
        DispatchQueue.global(qos: .utility).async {
            do {
                let fm = FileManager.default
                let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let base = docs.appendingPathComponent("images-v2", isDirectory: true)
                let existing = try listAllFiles(at: base)
                let referenced = try referencedFiles(dbQueue: dbQueue)
                let orphaned = existing.subtracting(referenced)
                for path in orphaned {
                    try? fm.removeItem(atPath: path)
                }
            } catch {
                // Best-effort cleanup; ignore errors
            }
        }
    }

    private static func listAllFiles(at base: URL) throws -> Set<String> {
        var paths = Set<String>()
        let fm = FileManager.default
        if !fm.fileExists(atPath: base.path) { return paths }
        let enumerator = fm.enumerator(at: base, includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            if url.hasDirectoryPath { continue }
            paths.insert(url.path)
        }
        return paths
    }

    private static func referencedFiles(dbQueue: DatabaseQueue) throws -> Set<String> {
        try dbQueue.read { db in
            let rows = try Row.fetchAll(db, sql: "SELECT id, watch_id FROM watch_photos")
            var set = Set<String>()
            for row in rows {
                guard let idStr: String = row["id"], let widStr: String = row["watch_id"], let wid = UUID(uuidString: widStr), let pid = UUID(uuidString: idStr) else { continue }
                if let o = try? PhotoStoreV2.originalURL(watchId: wid, photoId: pid).path { set.insert(o) }
                if let t = try? PhotoStoreV2.thumbURL(watchId: wid, photoId: pid).path { set.insert(t) }
            }
            return set
        }
    }
}


