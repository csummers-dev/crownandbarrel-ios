import Foundation

@MainActor
public final class WatchV2ListViewModel: ObservableObject {
    @Published public private(set) var watches: [WatchV2] = []
    @Published public var sort: WatchSort = .manufacturerLineModel
    @Published public var filters = WatchFilters()
    @Published public private(set) var lastLoadMs: Int = 0

    private let repo: WatchRepositoryV2

    public init(repo: WatchRepositoryV2 = WatchRepositoryGRDB()) {
        self.repo = repo
    }

    public func load() {
        let start = Date()
        do {
            let list = try repo.list(sortedBy: sort, filters: filters)
            self.watches = list
            self.lastLoadMs = Int(Date().timeIntervalSince(start) * 1_000)
        } catch {
            self.watches = []
            self.lastLoadMs = -1
        }
    }
}
