import Foundation

/// Type-safe routes for drill-in destinations from Stats modules.
public enum StatsRoute: Hashable {
    case brandCompositionDetail(brand: String)
    case watchWearHistoryDetail(watchId: UUID)
    case acquisitionTimelineDetail
}


