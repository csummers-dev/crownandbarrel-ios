import Foundation
import Combine

/// ViewModel for the Collection screen.
/// - What: Holds watch list data, search text, sort option, and view mode.
/// - Why: Separates UI concerns from data access; debounces search and reacts to sort changes.
/// - How: Builds a `WatchFilter` and queries the repository; publishes updates to the view.
@MainActor
final class CollectionViewModel: ObservableObject {
    @Published var watches: [Watch] = []
    @Published var searchText: String = ""
    @Published var sortOption: WatchSortOption = .entryDateDescending
    @Published var viewMode: CollectionViewMode = .grid
    @Published var isPresentingAdd: Bool = false
    @Published var errorMessage: String?

    private let repository: WatchRepository
    private var cancellables: Set<AnyCancellable> = []

    /// Injects a repository (default Core Data) and wires live search/sort.
    init(repository: WatchRepository = WatchRepositoryCoreData()) {
        self.repository = repository
        // Live search
        $searchText
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in Task { await self?.load() } }
            .store(in: &cancellables)
        // Sort changes
        $sortOption
            .sink { [weak self] _ in Task { await self?.load() } }
            .store(in: &cancellables)
    }

    /// Loads the collection using the current search/sort settings.
    /// - Note: Error surfaces via `errorMessage` for UI to present.
    func load() async {
        do {
            let filter = WatchFilter(searchText: searchText, sortOption: sortOption, viewMode: viewMode)
            watches = try await repository.search(filter: filter)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


