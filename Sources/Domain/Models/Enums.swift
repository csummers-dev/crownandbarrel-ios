import Foundation

/// Represents the high-level category of a watch.
public enum WatchCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case dress, diver, pilot, field, chronograph, gmt, digital, smart, other
    public var id: String { rawValue }
}

/// Represents the movement type of a watch.
public enum WatchMovement: String, CaseIterable, Identifiable, Codable, Sendable {
    case automatic, manual, quartz, solar, kinetic, smart, other
    public var id: String { rawValue }
}

/// Theme preference saved in settings.
public enum ThemePreference: String, CaseIterable, Identifiable, Codable {
    case system, light, dark
    public var id: String { rawValue }
}

/// Sorting options for the collection screen.
public enum WatchSortOption: String, CaseIterable, Identifiable, Codable, Sendable {
    case entryDateAscending
    case entryDateDescending
    case manufacturerAZ
    case manufacturerZA
    case mostWorn
    case leastWorn
    case lastWornDate

    public var id: String { rawValue }
}

/// Preferred layout mode for the collection.
public enum CollectionViewMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case grid
    case list

    public var id: String { rawValue }
}


