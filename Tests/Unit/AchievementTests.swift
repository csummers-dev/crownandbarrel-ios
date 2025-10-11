@testable import CrownAndBarrel
import XCTest

/// Unit tests for Achievement and AchievementState domain models.
final class AchievementTests: XCTestCase {
    // MARK: - Achievement Model Tests

    func testAchievementInitialization() {
        let achievement = Achievement(
            name: "Test Achievement",
            description: "Test description",
            imageAssetName: "test_image",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 10),
            targetValue: 10
        )

        XCTAssertEqual(achievement.name, "Test Achievement")
        XCTAssertEqual(achievement.description, "Test description")
        XCTAssertEqual(achievement.imageAssetName, "test_image")
        XCTAssertEqual(achievement.category, .collectionSize)
        XCTAssertEqual(achievement.targetValue, 10)
    }

    func testAchievementProgressString() {
        let achievement = Achievement(
            name: "Test",
            description: "Test",
            imageAssetName: "test",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 10),
            targetValue: 10
        )

        XCTAssertEqual(achievement.progressString(currentValue: 5), "5/10")
        XCTAssertEqual(achievement.progressString(currentValue: 10), "10/10")
        XCTAssertEqual(achievement.progressString(currentValue: 0), "0/10")
    }

    func testAchievementProgressPercentage() {
        let achievement = Achievement(
            name: "Test",
            description: "Test",
            imageAssetName: "test",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 10),
            targetValue: 10
        )

        XCTAssertEqual(achievement.progressPercentage(currentValue: 0), 0.0)
        XCTAssertEqual(achievement.progressPercentage(currentValue: 5), 0.5)
        XCTAssertEqual(achievement.progressPercentage(currentValue: 10), 1.0)
        XCTAssertEqual(achievement.progressPercentage(currentValue: 15), 1.0) // Capped at 1.0
    }

    func testAchievementCriteriaMet() {
        let achievement = Achievement(
            name: "Test",
            description: "Test",
            imageAssetName: "test",
            category: .collectionSize,
            unlockCriteria: .watchCountReached(count: 10),
            targetValue: 10
        )

        XCTAssertFalse(achievement.isCriteriaMet(currentValue: 5))
        XCTAssertTrue(achievement.isCriteriaMet(currentValue: 10))
        XCTAssertTrue(achievement.isCriteriaMet(currentValue: 15))
    }

    func testAchievementCodable() throws {
        let achievement = Achievement(
            name: "Test Achievement",
            description: "Test description",
            imageAssetName: "test_image",
            category: .wearingFrequency,
            unlockCriteria: .totalWearsReached(count: 50),
            targetValue: 50
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(achievement)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Achievement.self, from: data)

        XCTAssertEqual(decoded.name, achievement.name)
        XCTAssertEqual(decoded.description, achievement.description)
        XCTAssertEqual(decoded.category, achievement.category)
        XCTAssertEqual(decoded.targetValue, achievement.targetValue)
    }

    // MARK: - AchievementState Model Tests

    func testAchievementStateInitialization() {
        let achievementId = UUID()
        let state = AchievementState(
            achievementId: achievementId,
            isUnlocked: false,
            currentProgress: 5,
            progressTarget: 10
        )

        XCTAssertEqual(state.achievementId, achievementId)
        XCTAssertFalse(state.isUnlocked)
        XCTAssertNil(state.unlockedAt)
        XCTAssertEqual(state.currentProgress, 5)
        XCTAssertEqual(state.progressTarget, 10)
    }

    func testAchievementStateProgressString() {
        let state = AchievementState(
            achievementId: UUID(),
            currentProgress: 7,
            progressTarget: 10
        )

        XCTAssertEqual(state.progressString, "7/10")
    }

    func testAchievementStateProgressPercentage() {
        let state = AchievementState(
            achievementId: UUID(),
            currentProgress: 7.5,
            progressTarget: 10
        )

        XCTAssertEqual(state.progressPercentage, 0.75, accuracy: 0.001)
    }

    func testAchievementStateProgressComplete() {
        var state = AchievementState(
            achievementId: UUID(),
            currentProgress: 5,
            progressTarget: 10
        )

        XCTAssertFalse(state.isProgressComplete)

        state.currentProgress = 10
        XCTAssertTrue(state.isProgressComplete)

        state.currentProgress = 15
        XCTAssertTrue(state.isProgressComplete)
    }

    func testAchievementStateUpdateProgress() {
        var state = AchievementState(
            achievementId: UUID(),
            currentProgress: 5,
            progressTarget: 10
        )

        let beforeUpdate = state.updatedAt

        // Small delay to ensure timestamp changes
        Thread.sleep(forTimeInterval: 0.01)

        state.updateProgress(8)

        XCTAssertEqual(state.currentProgress, 8)
        XCTAssertGreaterThan(state.updatedAt, beforeUpdate)
    }

    func testAchievementStateUnlock() {
        var state = AchievementState(
            achievementId: UUID(),
            isUnlocked: false,
            currentProgress: 10,
            progressTarget: 10
        )

        XCTAssertFalse(state.isUnlocked)
        XCTAssertNil(state.unlockedAt)

        state.unlock()

        XCTAssertTrue(state.isUnlocked)
        XCTAssertNotNil(state.unlockedAt)
    }

    func testAchievementStateImmutableHelpers() {
        let state = AchievementState(
            achievementId: UUID(),
            currentProgress: 5,
            progressTarget: 10
        )

        let updatedState = state.withProgress(8)

        // Original unchanged
        XCTAssertEqual(state.currentProgress, 5)
        // New state updated
        XCTAssertEqual(updatedState.currentProgress, 8)

        let unlockedState = state.withUnlocked()

        // Original unchanged
        XCTAssertFalse(state.isUnlocked)
        // New state unlocked
        XCTAssertTrue(unlockedState.isUnlocked)
        XCTAssertNotNil(unlockedState.unlockedAt)
    }

    func testAchievementStateCodable() throws {
        let achievementId = UUID()
        let state = AchievementState(
            achievementId: achievementId,
            isUnlocked: true,
            unlockedAt: Date(),
            currentProgress: 10,
            progressTarget: 10
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(state)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AchievementState.self, from: data)

        XCTAssertEqual(decoded.achievementId, state.achievementId)
        XCTAssertEqual(decoded.isUnlocked, state.isUnlocked)
        XCTAssertEqual(decoded.currentProgress, state.currentProgress)
        XCTAssertEqual(decoded.progressTarget, state.progressTarget)
    }

    // MARK: - AchievementCategory Tests

    func testAchievementCategoryDisplayNames() {
        XCTAssertEqual(AchievementCategory.collectionSize.displayName, "Collection Size")
        XCTAssertEqual(AchievementCategory.wearingFrequency.displayName, "Wearing Frequency")
        XCTAssertEqual(AchievementCategory.consistency.displayName, "Consistency")
        XCTAssertEqual(AchievementCategory.diversity.displayName, "Diversity")
        XCTAssertEqual(AchievementCategory.specialOccasions.displayName, "Special Occasions")
    }

    func testAchievementCategoryIcons() {
        XCTAssertEqual(AchievementCategory.collectionSize.iconName, "square.grid.3x3")
        XCTAssertEqual(AchievementCategory.wearingFrequency.iconName, "chart.bar.fill")
        XCTAssertEqual(AchievementCategory.consistency.iconName, "calendar")
        XCTAssertEqual(AchievementCategory.diversity.iconName, "sparkles")
        XCTAssertEqual(AchievementCategory.specialOccasions.iconName, "star.fill")
    }

    func testAchievementCategoryCodable() throws {
        let category = AchievementCategory.collectionSize

        let encoder = JSONEncoder()
        let data = try encoder.encode(category)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AchievementCategory.self, from: data)

        XCTAssertEqual(decoded, category)
    }

    // MARK: - AchievementCriteria Tests

    func testAchievementCriteriaDescriptions() {
        XCTAssertEqual(AchievementCriteria.watchCountReached(count: 10).description, "Own 10 watches")
        XCTAssertEqual(AchievementCriteria.watchCountReached(count: 1).description, "Own 1 watch")
        XCTAssertEqual(AchievementCriteria.totalWearsReached(count: 50).description, "Log 50 total wears")
        XCTAssertEqual(AchievementCriteria.consecutiveDaysStreak(days: 7).description, "Log wears 7 days in a row")
        XCTAssertEqual(AchievementCriteria.uniqueBrandsReached(count: 5).description, "Own watches from 5 different brands")
    }

    func testAchievementCriteriaTargetValues() {
        XCTAssertEqual(AchievementCriteria.watchCountReached(count: 10).targetValue, 10)
        XCTAssertEqual(AchievementCriteria.totalWearsReached(count: 50).targetValue, 50)
        XCTAssertEqual(AchievementCriteria.consecutiveDaysStreak(days: 7).targetValue, 7)
        XCTAssertEqual(AchievementCriteria.firstWatchAdded.targetValue, 1)
        XCTAssertEqual(AchievementCriteria.balancedWearDistribution(maxPercentage: 0.3).targetValue, 1)
    }

    func testAchievementCriteriaCodable() throws {
        let criteria = AchievementCriteria.watchCountReached(count: 10)

        let encoder = JSONEncoder()
        let data = try encoder.encode(criteria)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AchievementCriteria.self, from: data)

        XCTAssertEqual(decoded.description, criteria.description)
        XCTAssertEqual(decoded.targetValue, criteria.targetValue)
    }

    func testAchievementCriteriaComplexCodable() throws {
        let testCases: [AchievementCriteria] = [
            .watchCountReached(count: 25),
            .totalWearsReached(count: 100),
            .consecutiveDaysStreak(days: 30),
            .uniqueBrandsReached(count: 5),
            .balancedWearDistribution(maxPercentage: 0.3),
            .firstWatchAdded,
            .allWatchesWornAtLeastOnce
        ]

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for criteria in testCases {
            let data = try encoder.encode(criteria)
            let decoded = try decoder.decode(AchievementCriteria.self, from: data)

            XCTAssertEqual(decoded.description, criteria.description)
            XCTAssertEqual(decoded.targetValue, criteria.targetValue)
        }
    }
}
