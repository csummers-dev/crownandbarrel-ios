import Foundation

/// Filter inputs for collection queries.
/// - What: Encapsulates user search text, sort option, and view mode.
/// - Why: Keeps repository interfaces stable and composable.
/// - How: View models build this struct and pass to the repository.

public struct WatchFilter: Codable, Equatable {
    public var searchText: String
    public var sortOption: WatchSortOption
    public var viewMode: CollectionViewMode

    public init(searchText: String = "", sortOption: WatchSortOption = .entryDateDescending, viewMode: CollectionViewMode = .grid) {
        self.searchText = searchText
        self.sortOption = sortOption
        self.viewMode = viewMode
    }
}

/// Repository abstraction for watches and wear entries.
/// - What: Defines async CRUD and query APIs for watches and wear records.
/// - Why: Decouples UI/domain from Core Data specifics and enables testing with in-memory repos.
/// - How: Concrete implementation updates derived fields (e.g., timesWorn, lastWornDate) to keep sorting fast.
public protocol WatchRepository {
    /// Returns all watches, typically sorted by creation date descending.
    func fetchAll() async throws -> [Watch]

    /// Inserts or updates a watch by `id`.
    func upsert(_ watch: Watch) async throws

    /// Deletes a watch and any associated records by `id`.
    func delete(_ watchId: UUID) async throws

    /// Performs a filtered and sorted query using `WatchFilter`.
    func search(filter: WatchFilter) async throws -> [Watch]

    /// Adds a wear entry for a watch on a given date, enforcing uniqueness per day.
    func incrementWear(for watchId: UUID, on date: Date) async throws

    /// Returns whether a wear entry exists for a watch on a given date.
    func existsWearEntry(watchId: UUID, date: Date) async throws -> Bool

    /// Returns all wear entries for a specific date, sorted by time.
    func wearEntries(on date: Date) async throws -> [WearEntry]
}


