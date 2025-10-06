import Foundation

/// Categorizes achievements by their type for filtering and organization.
/// - What: Defines the five main categories of achievements in the Crown & Barrel system.
/// - Why: Enables filtering achievements by type in the UI and provides logical grouping
///        for the 50 achievement definitions (10 per category as per PRD).
/// - How: Each achievement is assigned one category that determines its grouping in the
///        stats page and helps users understand what type of milestone they've reached.
public enum AchievementCategory: String, Codable, Hashable, Sendable, CaseIterable {
    /// Achievements based on collection size milestones
    /// Examples: "Own 10 watches", "Own 50 watches", "Century Club (100 watches)"
    case collectionSize
    
    /// Achievements based on total wearing frequency across all watches
    /// Examples: "Log 100 wears", "Log 1000 wears", "Millennium Wearer"
    case wearingFrequency
    
    /// Achievements based on wearing consistency and streaks
    /// Examples: "7 days in a row", "30 days in a row", "Year-Long Dedication"
    case consistency
    
    /// Achievements based on collection diversity and variety
    /// Examples: "Own 5 different brands", "Wear 10 different watches in a month"
    case diversity
    
    /// Achievements for special occasions and first-time events
    /// Examples: "First watch added", "First wear logged", "Anniversary Year"
    case specialOccasions
}

// MARK: - Display Helpers

public extension AchievementCategory {
    /// Human-readable display name for the category
    var displayName: String {
        switch self {
        case .collectionSize:
            return "Collection Size"
        case .wearingFrequency:
            return "Wearing Frequency"
        case .consistency:
            return "Consistency"
        case .diversity:
            return "Diversity"
        case .specialOccasions:
            return "Special Occasions"
        }
    }
    
    /// SF Symbol icon name for the category
    var iconName: String {
        switch self {
        case .collectionSize:
            return "square.grid.3x3"
        case .wearingFrequency:
            return "chart.bar.fill"
        case .consistency:
            return "calendar"
        case .diversity:
            return "sparkles"
        case .specialOccasions:
            return "star.fill"
        }
    }
    
    /// Brief description of what achievements in this category represent
    var categoryDescription: String {
        switch self {
        case .collectionSize:
            return "Milestones for growing your watch collection"
        case .wearingFrequency:
            return "Recognition for logging wears across all your watches"
        case .consistency:
            return "Rewards for maintaining wearing streaks"
        case .diversity:
            return "Celebrate variety in your collection and rotation"
        case .specialOccasions:
            return "Commemorate special moments and firsts"
        }
    }
}
