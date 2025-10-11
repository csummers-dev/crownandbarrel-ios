import Foundation

/// Core service for evaluating achievement criteria and unlocking achievements.
/// - What: Orchestrates achievement evaluation by checking user data against achievement criteria
///         and updating achievement states accordingly.
/// - Why: Centralizes all achievement evaluation logic, ensuring consistent evaluation across
///        different trigger points (watch added, wear logged, etc.).
/// - How: Uses dependency injection for repositories, evaluates criteria based on achievement type,
///        and persists updated states. Can evaluate all achievements or single achievements on demand.
public final class AchievementEvaluator: Sendable {
    private let achievementRepository: AchievementRepository
    private let watchRepository: WatchRepositoryV2

    public init(
        achievementRepository: AchievementRepository,
        watchRepository: WatchRepositoryV2
    ) {
        self.achievementRepository = achievementRepository
        self.watchRepository = watchRepository
    }

    // MARK: - Main Evaluation Methods

    /// Evaluates all locked achievements against current user data.
    /// - Returns: Array of achievement IDs that were newly unlocked
    public func evaluateAll() async throws -> [UUID] {
        // Fetch all achievement definitions and locked states
        let allDefinitions = try await achievementRepository.fetchAllDefinitions()
        let lockedStates = try await achievementRepository.fetchLocked()

        var newlyUnlocked: [UUID] = []
        var statesToUpdate: [AchievementState] = []

        for state in lockedStates {
            // Find the corresponding achievement definition
            guard let achievement = allDefinitions.first(where: { $0.id == state.achievementId }) else {
                continue
            }

            // Evaluate this achievement
            let (progress, isUnlocked) = try await evaluateCriteria(achievement.unlockCriteria)

            // Update state if changed
            var updatedState = state
            updatedState.currentProgress = progress

            if isUnlocked && !state.isUnlocked {
                updatedState.unlock()
                newlyUnlocked.append(achievement.id)
            }

            statesToUpdate.append(updatedState)
        }

        // Batch update all states
        if !statesToUpdate.isEmpty {
            try await achievementRepository.updateUserStates(statesToUpdate)
        }

        return newlyUnlocked
    }

    /// Evaluates a single achievement and updates its state.
    /// - Parameter achievementId: The ID of the achievement to evaluate
    /// - Returns: True if the achievement was newly unlocked, false otherwise
    public func evaluateAchievement(_ achievementId: UUID) async throws -> Bool {
        guard let achievement = try await achievementRepository.fetchDefinition(id: achievementId) else {
            return false
        }

        guard let state = try await achievementRepository.fetchUserState(achievementId: achievementId) else {
            return false
        }

        // Skip if already unlocked
        if state.isUnlocked {
            return false
        }

        // Evaluate criteria
        let (progress, isUnlocked) = try await evaluateCriteria(achievement.unlockCriteria)

        // Update state
        var updatedState = state
        updatedState.currentProgress = progress

        let wasUnlocked = isUnlocked && !state.isUnlocked
        if wasUnlocked {
            updatedState.unlock()
        }

        try await achievementRepository.updateUserState(updatedState)

        return wasUnlocked
    }

    // MARK: - Criteria Evaluation

    /// Evaluates achievement criteria and returns current progress and unlock status.
    /// - Parameter criteria: The achievement criteria to evaluate
    /// - Returns: Tuple of (currentProgress, isUnlocked)
    private func evaluateCriteria(_ criteria: AchievementCriteria) async throws -> (progress: Double, isUnlocked: Bool) {
        switch criteria {
        // Collection Size
        case .watchCountReached(let count):
            return try await evaluateCollectionSize(target: count)

        // Wearing Frequency
        case .totalWearsReached(let count):
            return try await evaluateTotalWears(target: count)
        case .singleWatchWornCount(let count):
            return try await evaluateSingleWatchWorn(target: count)

        // Consistency/Streaks
        case .consecutiveDaysStreak(let days):
            return try await evaluateConsecutiveDaysStreak(target: days)
        case .consecutiveWeekendsStreak(let weekends):
            return try await evaluateConsecutiveWeekendsStreak(target: weekends)
        case .consecutiveWeekdaysStreak(let weekdays):
            return try await evaluateConsecutiveWeekdaysStreak(target: weekdays)

        // Diversity
        case .uniqueBrandsReached(let count):
            return try await evaluateUniqueBrands(target: count)
        case .differentWatchesInWeek(let count):
            return try await evaluateDifferentWatchesInPeriod(target: count, days: 7)
        case .differentWatchesInMonth(let count):
            return try await evaluateDifferentWatchesInPeriod(target: count, days: 30)
        case .differentWatchesInQuarter(let count):
            return try await evaluateDifferentWatchesInPeriod(target: count, days: 90)
        case .allWatchesWornAtLeastOnce:
            return try await evaluateAllWatchesWornOnce()
        case .balancedWearDistribution(let maxPercentage):
            return try await evaluateBalancedDistribution(maxPercentage: maxPercentage)

        // Special Occasions
        case .firstWatchAdded:
            return try await evaluateFirstWatch()
        case .firstWearLogged:
            return try await evaluateFirstWear()
        case .trackingConsecutiveDays(let days):
            return try await evaluateTrackingConsecutiveDays(target: days)
        case .appUsageDuration(let days):
            return try await evaluateAppUsageDuration(target: days)
        case .wearsOnFirstDay(let count):
            return try await evaluateWearsOnFirstDay(target: count)
        case .uniqueDaysWithEntries(let days):
            return try await evaluateUniqueDaysWithEntries(target: days)
        }
    }

    // MARK: - Collection Size Evaluation

    private func evaluateCollectionSize(target: Int) async throws -> (Double, Bool) {
        let count = try await watchRepository.totalWatchCount()
        let progress = Double(count)
        let isUnlocked = count >= target
        return (progress, isUnlocked)
    }

    // MARK: - Wearing Frequency Evaluation

    private func evaluateTotalWears(target: Int) async throws -> (Double, Bool) {
        let count = try await watchRepository.totalWearCount()
        let progress = Double(count)
        let isUnlocked = count >= target
        return (progress, isUnlocked)
    }

    private func evaluateSingleWatchWorn(target: Int) async throws -> (Double, Bool) {
        // Get all watches and check if any have been worn >= target times
        let watches = try await watchRepository.fetchAll()
        var maxWears = 0

        for watch in watches {
            let wearCount = try await watchRepository.wearCountForWatch(watchId: watch.id)
            maxWears = max(maxWears, wearCount)
        }

        let progress = Double(maxWears)
        let isUnlocked = maxWears >= target
        return (progress, isUnlocked)
    }

    // MARK: - Consistency/Streak Evaluation

    private func evaluateConsecutiveDaysStreak(target: Int) async throws -> (Double, Bool) {
        let streak = try await watchRepository.currentStreak()
        let progress = Double(streak)
        let isUnlocked = streak >= target
        return (progress, isUnlocked)
    }

    private func evaluateConsecutiveWeekendsStreak(target: Int) async throws -> (Double, Bool) {
        // Calculate consecutive weekends with wear entries
        let allEntries = try await watchRepository.allWearEntries()
        let streak = StreakCalculator.calculateConsecutiveWeekends(from: allEntries)
        let progress = Double(streak)
        let isUnlocked = streak >= target
        return (progress, isUnlocked)
    }

    private func evaluateConsecutiveWeekdaysStreak(target: Int) async throws -> (Double, Bool) {
        // Calculate consecutive weekdays with wear entries
        let allEntries = try await watchRepository.allWearEntries()
        let streak = StreakCalculator.calculateConsecutiveWeekdays(from: allEntries)
        let progress = Double(streak)
        let isUnlocked = streak >= target
        return (progress, isUnlocked)
    }

    // MARK: - Diversity Evaluation

    private func evaluateUniqueBrands(target: Int) async throws -> (Double, Bool) {
        let count = try await watchRepository.uniqueBrandsCount()
        let progress = Double(count)
        let isUnlocked = count >= target
        return (progress, isUnlocked)
    }

    private func evaluateDifferentWatchesInPeriod(target: Int, days: Int) async throws -> (Double, Bool) {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            return (0, false)
        }

        let allEntries = try await watchRepository.allWearEntries()
        let entriesInPeriod = allEntries.filter { $0.date >= startDate && $0.date <= endDate }
        let uniqueWatchIds = Set(entriesInPeriod.map { $0.watchId })

        let count = uniqueWatchIds.count
        let progress = Double(count)
        let isUnlocked = count >= target
        return (progress, isUnlocked)
    }

    private func evaluateAllWatchesWornOnce() async throws -> (Double, Bool) {
        let watches = try await watchRepository.fetchAll()
        guard !watches.isEmpty else { return (0, false) }

        var wornWatchCount = 0
        for watch in watches {
            let wearCount = try await watchRepository.wearCountForWatch(watchId: watch.id)
            if wearCount > 0 {
                wornWatchCount += 1
            }
        }

        let progress = Double(wornWatchCount) / Double(watches.count)
        let isUnlocked = wornWatchCount == watches.count
        return (progress, isUnlocked)
    }

    private func evaluateBalancedDistribution(maxPercentage: Double) async throws -> (Double, Bool) {
        let totalWears = try await watchRepository.totalWearCount()
        guard totalWears > 0 else { return (0, false) }

        let watches = try await watchRepository.fetchAll()
        var maxWatchPercentage = 0.0

        for watch in watches {
            let wearCount = try await watchRepository.wearCountForWatch(watchId: watch.id)
            let percentage = Double(wearCount) / Double(totalWears)
            maxWatchPercentage = max(maxWatchPercentage, percentage)
        }

        let progress = maxWatchPercentage <= maxPercentage ? 1.0 : 0.0
        let isUnlocked = maxWatchPercentage <= maxPercentage
        return (progress, isUnlocked)
    }

    // MARK: - Special Occasions Evaluation

    private func evaluateFirstWatch() async throws -> (Double, Bool) {
        let count = try await watchRepository.totalWatchCount()
        let progress = count > 0 ? 1.0 : 0.0
        let isUnlocked = count > 0
        return (progress, isUnlocked)
    }

    private func evaluateFirstWear() async throws -> (Double, Bool) {
        let count = try await watchRepository.totalWearCount()
        let progress = count > 0 ? 1.0 : 0.0
        let isUnlocked = count > 0
        return (progress, isUnlocked)
    }

    private func evaluateTrackingConsecutiveDays(target: Int) async throws -> (Double, Bool) {
        // Same as consecutive days streak
        try await evaluateConsecutiveDaysStreak(target: target)
    }

    private func evaluateAppUsageDuration(target: Int) async throws -> (Double, Bool) {
        guard let firstWatchDate = try await watchRepository.firstWatchDate() else {
            return (0, false)
        }

        let calendar = Calendar.current
        let daysSinceFirst = calendar.dateComponents([.day], from: firstWatchDate, to: Date()).day ?? 0
        let progress = Double(daysSinceFirst)
        let isUnlocked = daysSinceFirst >= target
        return (progress, isUnlocked)
    }

    private func evaluateWearsOnFirstDay(target: Int) async throws -> (Double, Bool) {
        guard let firstWearDate = try await watchRepository.firstWearDate() else {
            return (0, false)
        }

        let calendar = Calendar.current
        let firstDay = calendar.startOfDay(for: firstWearDate)

        let allEntries = try await watchRepository.allWearEntries()
        let firstDayEntries = allEntries.filter { calendar.isDate($0.date, inSameDayAs: firstDay) }

        let count = firstDayEntries.count
        let progress = Double(count)
        let isUnlocked = count >= target
        return (progress, isUnlocked)
    }

    private func evaluateUniqueDaysWithEntries(target: Int) async throws -> (Double, Bool) {
        let count = try await watchRepository.uniqueDaysWithEntries()
        let progress = Double(count)
        let isUnlocked = count >= target
        return (progress, isUnlocked)
    }

    // MARK: - Event-Triggered Evaluation

    /// Evaluates relevant achievements when a watch is added.
    /// - Returns: Array of newly unlocked achievement IDs
    public func evaluateOnWatchAdded() async throws -> [UUID] {
        // Evaluate collection size and diversity achievements
        let relevantCategories: [AchievementCategory] = [.collectionSize, .diversity, .specialOccasions]
        return try await evaluateCategories(relevantCategories)
    }

    /// Evaluates relevant achievements when a wear entry is logged.
    /// - Parameters:
    ///   - watchId: The ID of the watch that was worn
    ///   - date: The date of the wear entry
    /// - Returns: Array of newly unlocked achievement IDs
    public func evaluateOnWearLogged(watchId: UUID, date: Date) async throws -> [UUID] {
        // Evaluate wearing frequency, consistency, and special occasion achievements
        let relevantCategories: [AchievementCategory] = [.wearingFrequency, .consistency, .diversity, .specialOccasions]
        return try await evaluateCategories(relevantCategories)
    }

    /// Recalculates progress for all achievements when data is deleted.
    /// Note: Already unlocked achievements remain unlocked.
    public func evaluateOnDataDeleted() async throws {
        // Re-evaluate all locked achievements to update their progress
        _ = try await evaluateAll()
    }

    /// Evaluates all existing user data for achievements (used on first launch or after updates).
    /// - Returns: Array of newly unlocked achievement IDs
    public func evaluateExistingUserData() async throws -> [UUID] {
        // Initialize user states if not already done
        try await achievementRepository.initializeUserStates()

        // Evaluate all achievements
        return try await evaluateAll()
    }

    // MARK: - Private Helpers

    private func evaluateCategories(_ categories: [AchievementCategory]) async throws -> [UUID] {
        var newlyUnlocked: [UUID] = []

        for category in categories {
            let achievements = try await achievementRepository.fetchByCategory(category)

            for achievement in achievements {
                guard let state = try await achievementRepository.fetchUserState(achievementId: achievement.id) else {
                    continue
                }

                // Skip if already unlocked
                if state.isUnlocked {
                    continue
                }

                // Evaluate this achievement
                let wasUnlocked = try await evaluateAchievement(achievement.id)
                if wasUnlocked {
                    newlyUnlocked.append(achievement.id)
                }
            }
        }

        return newlyUnlocked
    }
}
