import Foundation

/// Hardcoded definitions for all 50 achievements in the Crown & Barrel system.
/// - What: Provides the constant achievement definitions that are used throughout the app.
/// - Why: Achievement definitions are fixed and should not be modified by users. Hardcoding
///        them ensures consistency and makes them easy to reference.
/// - How: This file defines all 50 achievements across 5 categories (10 per category).
///        Achievement IDs are deterministic UUIDs based on achievement names for consistency.
public enum AchievementDefinitions {
    
    /// All 50 achievement definitions organized by category
    public static let all: [Achievement] = 
        collectionSize + 
        wearingFrequency + 
        consistency + 
        diversity + 
        specialOccasions
    
    // MARK: - Collection Size Achievements (10)
    
    public static let collectionSize: [Achievement] = [
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000001")!,
            name: "The Journey Begins",
            description: "Add your first watch",
            imageAssetName: "achievement_001",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 1),
            targetValue: 1
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000002")!,
            name: "Growing Collection",
            description: "Own 5 watches",
            imageAssetName: "achievement_002",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 5),
            targetValue: 5
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000003")!,
            name: "Serious Collector",
            description: "Own 10 watches",
            imageAssetName: "achievement_003",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 10),
            targetValue: 10
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000004")!,
            name: "Watch Enthusiast",
            description: "Own 25 watches",
            imageAssetName: "achievement_004",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 25),
            targetValue: 25
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000005")!,
            name: "Master Collector",
            description: "Own 50 watches",
            imageAssetName: "achievement_005",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 50),
            targetValue: 50
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000006")!,
            name: "Elite Collection",
            description: "Own 75 watches",
            imageAssetName: "achievement_006",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 75),
            targetValue: 75
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000007")!,
            name: "Century Club",
            description: "Own 100 watches",
            imageAssetName: "achievement_007",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 100),
            targetValue: 100
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000008")!,
            name: "Distinguished Collector",
            description: "Own 150 watches",
            imageAssetName: "achievement_008",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 150),
            targetValue: 150
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000009")!,
            name: "Ultimate Collector",
            description: "Own 200 watches",
            imageAssetName: "achievement_009",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 200),
            targetValue: 200
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000000a")!,
            name: "Crown Jewel",
            description: "Own 250 watches",
            imageAssetName: "achievement_010",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 250),
            targetValue: 250
        ),
    ]
    
    // MARK: - Wearing Frequency Achievements (10)
    
    public static let wearingFrequency: [Achievement] = [
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000000b")!,
            name: "Breaking It In",
            description: "Log your first wear",
            imageAssetName: "achievement_011",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 1),
            targetValue: 1
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000000c")!,
            name: "Getting Started",
            description: "Log 10 total wears",
            imageAssetName: "achievement_012",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 10),
            targetValue: 10
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000000d")!,
            name: "Regular Wearer",
            description: "Log 25 total wears",
            imageAssetName: "achievement_013",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 25),
            targetValue: 25
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000000e")!,
            name: "Committed Wearer",
            description: "Log 50 total wears",
            imageAssetName: "achievement_014",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 50),
            targetValue: 50
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000000f")!,
            name: "Dedicated Enthusiast",
            description: "Log 100 total wears",
            imageAssetName: "achievement_015",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 100),
            targetValue: 100
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000010")!,
            name: "Wear Champion",
            description: "Log 250 total wears",
            imageAssetName: "achievement_016",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 250),
            targetValue: 250
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000011")!,
            name: "Wear Master",
            description: "Log 500 total wears",
            imageAssetName: "achievement_017",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 500),
            targetValue: 500
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000012")!,
            name: "Millennium Wearer",
            description: "Log 1000 total wears",
            imageAssetName: "achievement_018",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 1000),
            targetValue: 1000
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000013")!,
            name: "Epic Wearer",
            description: "Log 2500 total wears",
            imageAssetName: "achievement_019",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 2500),
            targetValue: 2500
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000014")!,
            name: "Legendary Wearer",
            description: "Log 5000 total wears",
            imageAssetName: "achievement_020",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 5000),
            targetValue: 5000
        ),
    ]
    
    // MARK: - Consistency/Streak Achievements (10)
    
    public static let consistency: [Achievement] = [
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000015")!,
            name: "Getting Into Rhythm",
            description: "Log wears 3 days in a row",
            imageAssetName: "achievement_021",
            category: .consistency,
            unlockCriteria: .consecutiveDaysStreak(days: 3),
            targetValue: 3
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000016")!,
            name: "Weekly Warrior",
            description: "Log wears 7 days in a row",
            imageAssetName: "achievement_022",
            category: .consistency,
            unlockCriteria: .consecutiveDaysStreak(days: 7),
            targetValue: 7
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000017")!,
            name: "Two Week Streak",
            description: "Log wears 14 days in a row",
            imageAssetName: "achievement_023",
            category: .consistency,
            unlockCriteria: .consecutiveDaysStreak(days: 14),
            targetValue: 14
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000018")!,
            name: "Monthly Master",
            description: "Log wears 30 days in a row",
            imageAssetName: "achievement_024",
            category: .consistency,
            unlockCriteria: .consecutiveDaysStreak(days: 30),
            targetValue: 30
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000019")!,
            name: "Two Month Champion",
            description: "Log wears 60 days in a row",
            imageAssetName: "achievement_025",
            category: .consistency,
            unlockCriteria: .consecutiveDaysStreak(days: 60),
            targetValue: 60
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000001a")!,
            name: "Quarter Year Streak",
            description: "Log wears 90 days in a row",
            imageAssetName: "achievement_026",
            category: .consistency,
            unlockCriteria: .consecutiveDaysStreak(days: 90),
            targetValue: 90
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000001b")!,
            name: "Half Year Hero",
            description: "Log wears 180 days in a row",
            imageAssetName: "achievement_027",
            category: .consistency,
            unlockCriteria: .consecutiveDaysStreak(days: 180),
            targetValue: 180
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000001c")!,
            name: "Year-Long Dedication",
            description: "Log wears 365 days in a row",
            imageAssetName: "achievement_028",
            category: .consistency,
            unlockCriteria: .consecutiveDaysStreak(days: 365),
            targetValue: 365
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000001d")!,
            name: "Weekend Warrior",
            description: "Log wears on 10 consecutive weekends",
            imageAssetName: "achievement_029",
            category: .consistency,
            unlockCriteria: .consecutiveWeekendsStreak(weekends: 10),
            targetValue: 10
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000001e")!,
            name: "Weekday Champion",
            description: "Log wears on 20 consecutive weekdays",
            imageAssetName: "achievement_030",
            category: .consistency,
            unlockCriteria: .consecutiveWeekdaysStreak(weekdays: 20),
            targetValue: 20
        ),
    ]
    
    // MARK: - Diversity Achievements (10)
    
    public static let diversity: [Achievement] = [
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000001f")!,
            name: "Brand Explorer",
            description: "Own watches from 3 different brands",
            imageAssetName: "achievement_031",
            category: .diversity,
            unlockCriteria: .uniqueBrandsReached(count: 3),
            targetValue: 3
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000020")!,
            name: "Multi-Brand Collector",
            description: "Own watches from 5 different brands",
            imageAssetName: "achievement_032",
            category: .diversity,
            unlockCriteria: .uniqueBrandsReached(count: 5),
            targetValue: 5
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000021")!,
            name: "Brand Connoisseur",
            description: "Own watches from 10 different brands",
            imageAssetName: "achievement_033",
            category: .diversity,
            unlockCriteria: .uniqueBrandsReached(count: 10),
            targetValue: 10
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000022")!,
            name: "Brand Master",
            description: "Own watches from 15 different brands",
            imageAssetName: "achievement_034",
            category: .diversity,
            unlockCriteria: .uniqueBrandsReached(count: 15),
            targetValue: 15
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000023")!,
            name: "Brand Legend",
            description: "Own watches from 20 different brands",
            imageAssetName: "achievement_035",
            category: .diversity,
            unlockCriteria: .uniqueBrandsReached(count: 20),
            targetValue: 20
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000024")!,
            name: "Variety Seeker",
            description: "Wear 5 different watches in a week",
            imageAssetName: "achievement_036",
            category: .diversity,
            unlockCriteria: .differentWatchesInWeek(count: 5),
            targetValue: 5
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000025")!,
            name: "Rotation Master",
            description: "Wear 10 different watches in a month",
            imageAssetName: "achievement_037",
            category: .diversity,
            unlockCriteria: .differentWatchesInMonth(count: 10),
            targetValue: 10
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000026")!,
            name: "Equal Opportunity",
            description: "Wear each watch in collection at least once",
            imageAssetName: "achievement_038",
            category: .diversity,
            unlockCriteria: .allWatchesWornAtLeastOnce,
            targetValue: 1
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000027")!,
            name: "Balanced Collector",
            description: "No single watch accounts for more than 30% of wears",
            imageAssetName: "achievement_039",
            category: .diversity,
            unlockCriteria: .balancedWearDistribution(maxPercentage: 0.30),
            targetValue: 1
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000028")!,
            name: "True Rotation",
            description: "Wear 20 different watches in a quarter",
            imageAssetName: "achievement_040",
            category: .diversity,
            unlockCriteria: .differentWatchesInQuarter(count: 20),
            targetValue: 20
        ),
    ]
    
    // MARK: - Special Occasions/Firsts Achievements (10)
    
    public static let specialOccasions: [Achievement] = [
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000029")!,
            name: "First Time Out",
            description: "Log your first wear entry",
            imageAssetName: "achievement_041",
            category: .specialOccasions,
            unlockCriteria: .firstWearLogged,
            targetValue: 1
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000002a")!,
            name: "Week One Complete",
            description: "Track wears for 7 consecutive days",
            imageAssetName: "achievement_042",
            category: .specialOccasions,
            unlockCriteria: .trackingConsecutiveDays(days: 7),
            targetValue: 7
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000002b")!,
            name: "Month One Complete",
            description: "Track wears for 30 consecutive days",
            imageAssetName: "achievement_043",
            category: .specialOccasions,
            unlockCriteria: .trackingConsecutiveDays(days: 30),
            targetValue: 30
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000002c")!,
            name: "Anniversary Year",
            description: "Use the app for 1 full year",
            imageAssetName: "achievement_044",
            category: .specialOccasions,
            unlockCriteria: .appUsageDuration(days: 365),
            targetValue: 365
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000002d")!,
            name: "Favorite Watch",
            description: "Wear a single watch 10 times",
            imageAssetName: "achievement_045",
            category: .specialOccasions,
            unlockCriteria: .singleWatchWornCount(count: 10),
            targetValue: 10
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000002e")!,
            name: "True Love",
            description: "Wear a single watch 50 times",
            imageAssetName: "achievement_046",
            category: .specialOccasions,
            unlockCriteria: .singleWatchWornCount(count: 50),
            targetValue: 50
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-00000000002f")!,
            name: "Daily Driver",
            description: "Wear a single watch 100 times",
            imageAssetName: "achievement_047",
            category: .specialOccasions,
            unlockCriteria: .singleWatchWornCount(count: 100),
            targetValue: 100
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000030")!,
            name: "Inseparable",
            description: "Wear a single watch 250 times",
            imageAssetName: "achievement_048",
            category: .specialOccasions,
            unlockCriteria: .singleWatchWornCount(count: 250),
            targetValue: 250
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000031")!,
            name: "Quick Start",
            description: "Log 5 wear entries in your first day",
            imageAssetName: "achievement_049",
            category: .specialOccasions,
            unlockCriteria: .wearsOnFirstDay(count: 5),
            targetValue: 5
        ),
        Achievement(
            id: UUID(uuidString: "a0000000-0000-0000-0000-000000000032")!,
            name: "Dedicated Tracker",
            description: "Log wear entries on 100 different days",
            imageAssetName: "achievement_050",
            category: .specialOccasions,
            unlockCriteria: .uniqueDaysWithEntries(days: 100),
            targetValue: 100
        ),
    ]
    
    // MARK: - Helper Methods
    
    /// Fetches an achievement by ID
    public static func achievement(withId id: UUID) -> Achievement? {
        return all.first { $0.id == id }
    }
    
    /// Fetches all achievements in a specific category
    public static func achievements(in category: AchievementCategory) -> [Achievement] {
        switch category {
        case .collectionSize:
            return collectionSize
        case .wearingFrequency:
            return wearingFrequency
        case .consistency:
            return consistency
        case .diversity:
            return diversity
        case .specialOccasions:
            return specialOccasions
        }
    }
}
