import Foundation
import CoreData

/// Core Data-backed implementation of `WatchRepository`.
/// - What: Persists and queries watches and wear entries using Core Data.
/// - Why: Provides robust local storage with sorting/filtering capabilities and referential integrity.
/// - How: Uses a shared `CoreDataStack` and maps between domain models and managed objects via `Mappers`.
/// Core Data-backed implementation of `WatchRepository`.
/// - What: Persists and queries watches and wear entries using Core Data.
/// - Why: Provides robust local storage with sorting/filtering and derived field updates.
/// - How: Uses a shared `CoreDataStack`, mapping helpers, and calendar normalization.
@unchecked Sendable
public final class WatchRepositoryCoreData: WatchRepository {
    private let stack: CoreDataStack
    private let calendar: Calendar

    public init(stack: CoreDataStack = .shared, calendar: Calendar = .current) {
        self.stack = stack
        self.calendar = calendar
    }

    /// Returns all watches sorted by creation date descending.
    public func fetchAll() async throws -> [Watch] {
        try await stack.viewContext.perform { [weak stack] in
            guard let stack = stack else { throw AppError.unknown }
            let request = NSFetchRequest<CDWatch>(entityName: "CDWatch")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let results = try stack.viewContext.fetch(request)
            return results.map(Mappers.toDomain)
        }
    }

    /// Fetches a single watch by id.
    /// - Note: Uses a direct Core Data fetch with `fetchLimit = 1` for efficiency.
    ///   Prefer this for detail refreshes instead of a broader `search` query.
    public func fetchById(_ id: UUID) async throws -> Watch? {
        try await stack.viewContext.perform { [weak stack] in
            guard let stack = stack else { throw AppError.unknown }
            let request = NSFetchRequest<CDWatch>(entityName: "CDWatch")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            let obj = try stack.viewContext.fetch(request).first
            return obj.map(Mappers.toDomain)
        }
    }

    /// Inserts or updates a watch based on `id` and updates derived fields as needed.
    public func upsert(_ watch: Watch) async throws {
        try await stack.viewContext.perform { [weak stack] in
            guard let stack = stack else { throw AppError.unknown }
            let request = NSFetchRequest<CDWatch>(entityName: "CDWatch")
            request.predicate = NSPredicate(format: "id == %@", watch.id as CVarArg)
            let existing = try stack.viewContext.fetch(request).first
            let object = existing ?? CDWatch(entity: NSEntityDescription.entity(forEntityName: "CDWatch", in: stack.viewContext)!, insertInto: stack.viewContext)
            Mappers.update(object, from: watch)
            try stack.saveContext()
        }
    }

    /// Deletes a watch by id. Associated wear entries are removed via cascade rules when applicable.
    public func delete(_ watchId: UUID) async throws {
        try await stack.viewContext.perform { [weak stack] in
            guard let stack = stack else { throw AppError.unknown }
            let request = NSFetchRequest<CDWatch>(entityName: "CDWatch")
            request.predicate = NSPredicate(format: "id == %@", watchId as CVarArg)
            if let object = try stack.viewContext.fetch(request).first {
                stack.viewContext.delete(object)
                try stack.saveContext()
            }
        }
    }

    /// Performs search/filter/sort using `WatchFilter`. Search matches manufacturer/model/reference number.
    public func search(filter: WatchFilter) async throws -> [Watch] {
        try await stack.viewContext.perform { [weak stack] in
            guard let stack = stack else { throw AppError.unknown }
            let request = NSFetchRequest<CDWatch>(entityName: "CDWatch")
            var predicates: [NSPredicate] = []
            if !filter.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                let q = filter.searchText
                let p = NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "manufacturer CONTAINS[cd] %@", q),
                    NSPredicate(format: "model CONTAINS[cd] %@", q),
                    NSPredicate(format: "referenceNumber CONTAINS[cd] %@", q)
                ])
                predicates.append(p)
            }
            if !predicates.isEmpty { request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates) }

            switch filter.sortOption {
            case .entryDateAscending:
                request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            case .entryDateDescending:
                request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            case .manufacturerAZ:
                request.sortDescriptors = [NSSortDescriptor(key: "manufacturer", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
            case .manufacturerZA:
                request.sortDescriptors = [NSSortDescriptor(key: "manufacturer", ascending: false, selector: #selector(NSString.localizedStandardCompare(_:)))]
            case .mostWorn:
                request.sortDescriptors = [NSSortDescriptor(key: "timesWorn", ascending: false)]
            case .leastWorn:
                request.sortDescriptors = [NSSortDescriptor(key: "timesWorn", ascending: true)]
            case .lastWornDate:
                request.sortDescriptors = [NSSortDescriptor(key: "lastWornDate", ascending: false)]
            }

            let results = try stack.viewContext.fetch(request)
            return results.map(Mappers.toDomain)
        }
    }

    /// Adds a wear entry for a watch on a given date.
    /// - Enforces uniqueness per-day, per-watch. Updates `timesWorn` and `lastWornDate`.
    public func incrementWear(for watchId: UUID, on date: Date) async throws {
        try await stack.viewContext.perform { [weak self, weak stack] in
            guard let self = self, let stack = stack else { throw AppError.unknown }
            let normalized = calendar.startOfDay(for: date)
            if try self.existsWearEntrySync(watchId: watchId, date: normalized) {
                throw AppError.duplicateWear("This watch is already marked as worn on this date.")
            }
            guard let watch = try self.fetchCDWatch(by: watchId) else { throw AppError.repository("Watch not found") }
            let wear = CDWearEntry(entity: NSEntityDescription.entity(forEntityName: "CDWearEntry", in: stack.viewContext)!, insertInto: stack.viewContext)
            wear.setValue(UUID(), forKey: "id")
            wear.setValue(normalized, forKey: "date")
            wear.setValue(watch, forKey: "watch")

            let times = (watch.value(forKey: "timesWorn") as? Int32 ?? 0) + 1
            watch.setValue(times, forKey: "timesWorn")
            watch.setValue(normalized, forKey: "lastWornDate")
            watch.setValue(Date(), forKey: "updatedAt")

            try stack.saveContext()
        }
    }

    /// Returns true if a wear entry exists for a watch on a given calendar day (normalized).
    public func existsWearEntry(watchId: UUID, date: Date) async throws -> Bool {
        try await stack.viewContext.perform { [weak self] in
            guard let self = self else { throw AppError.unknown }
            return try self.existsWearEntrySync(watchId: watchId, date: self.calendar.startOfDay(for: date))
        }
    }

    /// Returns wear entries on a specific day, sorted by time.
    public func wearEntries(on date: Date) async throws -> [WearEntry] {
        try await stack.viewContext.perform { [weak stack] in
            guard let stack = stack else { throw AppError.unknown }
            let request = NSFetchRequest<CDWearEntry>(entityName: "CDWearEntry")
            let day = self.calendar.startOfDay(for: date)
            let next = self.calendar.date(byAdding: .day, value: 1, to: day)!
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", day as NSDate, next as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            return try stack.viewContext.fetch(request).map(Mappers.toDomain)
        }
    }

    /// Returns all wear entries for a watch up to and including the given date.
    /// Returns all wear entries for a watch up to and including the given date, sorted ascending.
    /// - Parameters:
    ///   - watchId: watch identifier
    ///   - date: inclusive upper bound
    public func wearEntriesUpTo(watchId: UUID, through date: Date) async throws -> [WearEntry] {
        try await stack.viewContext.perform { [weak self, weak stack] in
            guard let self = self, let stack = stack else { throw AppError.unknown }
            guard let watch = try self.fetchCDWatch(by: watchId) else { return [] }
            let end = self.calendar.startOfDay(for: date)
            let request = NSFetchRequest<CDWearEntry>(entityName: "CDWearEntry")
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "watch == %@", watch),
                NSPredicate(format: "date <= %@", end as NSDate)
            ])
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            return try stack.viewContext.fetch(request).map(Mappers.toDomain)
        }
    }

    // MARK: - Helpers

    /// Fetches a managed watch by id.
    private func fetchCDWatch(by id: UUID) throws -> CDWatch? {
        let request = NSFetchRequest<CDWatch>(entityName: "CDWatch")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try stack.viewContext.fetch(request).first
    }

    /// Synchronous helper to check for wear entry existence in the current context.
    private func existsWearEntrySync(watchId: UUID, date: Date) throws -> Bool {
        guard let watch = try fetchCDWatch(by: watchId) else { return false }
        let request = NSFetchRequest<CDWearEntry>(entityName: "CDWearEntry")
        let next = calendar.date(byAdding: .day, value: 1, to: date)!
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "watch == %@", watch),
            NSPredicate(format: "date >= %@ AND date < %@", date as NSDate, next as NSDate)
        ])
        request.fetchLimit = 1
        let count = try stack.viewContext.count(for: request)
        return count > 0
    }
}


