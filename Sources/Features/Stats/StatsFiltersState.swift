import Foundation
import SwiftUI

/// Preset ranges for Stats date filtering.
public enum StatsDateRangePreset: String, CaseIterable, Identifiable {
    case sevenDays
    case thirtyDays
    case ninetyDays
    case ytd
    case all
    case custom

    public var id: String { rawValue }
}

/// Shared filter and date-range state for the redesigned Stats experience.
/// This is intentionally persistence-free for now (persistence will be added in task 1.4).
public final class StatsFiltersState: ObservableObject {
    // MARK: - Date Range

    @AppStorage("stats.selectedPreset") public var selectedPresetRaw: String = StatsDateRangePreset.thirtyDays.rawValue
    @Published public var customStartDate: Date? = nil
    @Published public var customEndDate: Date? = nil

    public var selectedPreset: StatsDateRangePreset {
        get { StatsDateRangePreset(rawValue: selectedPresetRaw) ?? .thirtyDays }
        set { selectedPresetRaw = newValue.rawValue }
    }

    // MARK: - Filters

    /// Multi-select brand filter (manufacturer strings).
    @AppStorage("stats.selectedBrands") private var selectedBrandsRaw: String = "[]"
    @Published public var selectedBrands: Set<String> = [] { didSet { persist() } }

    /// Movement type identifiers (string raw values, e.g., "automatic", "quartz").
    @AppStorage("stats.selectedMovementTypes") private var selectedMovementTypesRaw: String = "[]"
    @Published public var selectedMovementTypes: Set<String> = [] { didSet { persist() } }

    /// Free-form complications captured on `WatchDial.complications`.
    @AppStorage("stats.selectedComplications") private var selectedComplicationsRaw: String = "[]"
    @Published public var selectedComplications: Set<String> = [] { didSet { persist() } }

    /// Condition or service status labels (simple string tags for now; normalize later if needed).
    @AppStorage("stats.selectedConditions") private var selectedConditionsRaw: String = "[]"
    @Published public var selectedConditions: Set<String> = [] { didSet { persist() } }

    /// Price bracket expressed as tuple (min,max) in USD; nil means no bracket.
    /// Use integer dollars for simplicity; formatting applied at view layer.
    @AppStorage("stats.priceBracketUSD") private var priceBracketRaw: String = ""
    @Published public var priceBracketUSD: (Int, Int)? = nil { didSet { persist() } }

    /// In-rotation toggle: nil = all; true = only in-rotation; false = only vaulted/for sale.
    @AppStorage("stats.inRotationOnly") private var inRotationOnlyRaw: Int = 0 // -1 = nil, 1 = true, 2 = false
    @Published public var inRotationOnly: Bool? = nil { didSet { persist() } }

    public init() { restore() }

    // MARK: - Effective Date Window

    /// Returns the effective [start,end] window for the current selection in the user's current calendar.
    /// End is inclusive for presentation but should be treated as exclusive bound (+1 day) for aggregation queries.
    public func currentDateWindow(now: Date = Date(), calendar: Calendar = .current) -> (start: Date?, end: Date?) {
        switch selectedPreset {
        case .sevenDays:
            let end = calendar.startOfDay(for: now)
            guard let start = calendar.date(byAdding: .day, value: -6, to: end) else { return (nil, nil) }
            return (start, end)
        case .thirtyDays:
            let end = calendar.startOfDay(for: now)
            guard let start = calendar.date(byAdding: .day, value: -29, to: end) else { return (nil, nil) }
            return (start, end)
        case .ninetyDays:
            let end = calendar.startOfDay(for: now)
            guard let start = calendar.date(byAdding: .day, value: -89, to: end) else { return (nil, nil) }
            return (start, end)
        case .ytd:
            let comps = calendar.dateComponents([.year], from: now)
            guard let year = comps.year,
                  let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) else { return (nil, nil) }
            let end = calendar.startOfDay(for: now)
            return (start, end)
        case .all:
            return (nil, nil)
        case .custom:
            return (customStartDate, customEndDate)
        }
    }

    // MARK: - Persistence
    private func persist() {
        selectedBrandsRaw = json(from: Array(selectedBrands))
        selectedMovementTypesRaw = json(from: Array(selectedMovementTypes))
        selectedComplicationsRaw = json(from: Array(selectedComplications))
        selectedConditionsRaw = json(from: Array(selectedConditions))
        if let b = priceBracketUSD { priceBracketRaw = "\(b.0),\(b.1)" } else { priceBracketRaw = "" }
        inRotationOnlyRaw = inRotationOnly == nil ? -1 : (inRotationOnly! ? 1 : 2)
    }

    private func restore() {
        selectedBrands = Set(array(from: selectedBrandsRaw))
        selectedMovementTypes = Set(array(from: selectedMovementTypesRaw))
        selectedComplications = Set(array(from: selectedComplicationsRaw))
        selectedConditions = Set(array(from: selectedConditionsRaw))
        if !priceBracketRaw.isEmpty {
            let parts = priceBracketRaw.split(separator: ",").compactMap { Int($0) }
            if parts.count == 2 { priceBracketUSD = (parts[0], parts[1]) }
        }
        switch inRotationOnlyRaw {
        case -1: inRotationOnly = nil
        case 1: inRotationOnly = true
        case 2: inRotationOnly = false
        default: inRotationOnly = nil
        }
    }

    private func json(from array: [String]) -> String {
        (try? String(data: JSONEncoder().encode(array), encoding: .utf8)) ?? "[]"
    }

    private func array(from raw: String) -> [String] {
        guard let data = raw.data(using: .utf8), let arr = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return arr
    }
}


