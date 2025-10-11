import SwiftUI

/// Compact achievement badge component for horizontal display in detail views.
/// - What: Displays achievement icon with label below in a compact format suitable for rows.
/// - Why: Allows multiple achievements to be displayed horizontally at bottom of detail views.
/// - How: Smaller 60x60pt icon with name below, designed for wrapping flow layout.
public struct AchievementBadge: View {
    public let achievement: Achievement
    public let state: AchievementState?

    @Environment(\.themeToken) private var themeToken

    public init(achievement: Achievement, state: AchievementState?) {
        self.achievement = achievement
        self.state = state
    }

    public var body: some View {
        VStack(spacing: AppSpacing.xs) {
            // Achievement icon (compact size)
            achievementImage
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isUnlocked ? AppColors.accent : AppColors.separator, lineWidth: 2)
                )

            // Achievement name (compact, 2 lines max)
            Text(achievement.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(isUnlocked ? AppColors.textPrimary : AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 80) // Fixed width for consistent grid layout
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .id(themeToken) // Force refresh on theme change
    }

    // MARK: - Subviews

    private var achievementImage: some View {
        Group {
            if let image = UIImage(named: achievement.imageAssetName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .opacity(isUnlocked ? 1.0 : 0.3)
                    .accessibilityHidden(true)
            } else {
                // Fallback to SF Symbol
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(isUnlocked ? AppColors.accent : AppColors.separator)
                    .padding(AppSpacing.sm)
                    .opacity(isUnlocked ? 1.0 : 0.3)
                    .accessibilityHidden(true)
            }
        }
    }

    // MARK: - Helpers

    private var isUnlocked: Bool {
        state?.isUnlocked ?? false
    }

    private var accessibilityLabel: String {
        var label = achievement.name
        if isUnlocked {
            label += ". Unlocked"
        } else {
            label += ". Locked"
        }
        return label
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Achievement Badges - Horizontal Row") {
    ScrollView {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            DetailSectionHeader(title: "Achievements")

            // Horizontal wrapping row
            FlowLayout(spacing: AppSpacing.md) {
                AchievementBadge(
                    achievement: Achievement(
                        name: "First Watch",
                        description: "Add your first watch",
                        imageAssetName: "achievement-first-watch",
                        category: .collectionSize,
                        unlockCriteria: .watchCountReached(count: 1),
                        targetValue: 1
                    ),
                    state: AchievementState(
                        achievementId: UUID(),
                        isUnlocked: true,
                        unlockedAt: Date(),
                        currentProgress: 1,
                        progressTarget: 1
                    )
                )

                AchievementBadge(
                    achievement: Achievement(
                        name: "Collector",
                        description: "Own 5 watches",
                        imageAssetName: "achievement-collector",
                        category: .collectionSize,
                        unlockCriteria: .watchCountReached(count: 5),
                        targetValue: 5
                    ),
                    state: AchievementState(
                        achievementId: UUID(),
                        isUnlocked: true,
                        unlockedAt: Date(),
                        currentProgress: 5,
                        progressTarget: 5
                    )
                )

                AchievementBadge(
                    achievement: Achievement(
                        name: "Enthusiast",
                        description: "Own 10 watches",
                        imageAssetName: "achievement-enthusiast",
                        category: .collectionSize,
                        unlockCriteria: .watchCountReached(count: 10),
                        targetValue: 10
                    ),
                    state: AchievementState(
                        achievementId: UUID(),
                        isUnlocked: false,
                        unlockedAt: nil,
                        currentProgress: 7,
                        progressTarget: 10
                    )
                )

                AchievementBadge(
                    achievement: Achievement(
                        name: "Daily Wearer",
                        description: "Wear any watch 7 days in a row",
                        imageAssetName: "achievement-daily",
                        category: .wearingFrequency,
                        unlockCriteria: .consecutiveDaysStreak(days: 7),
                        targetValue: 7
                    ),
                    state: AchievementState(
                        achievementId: UUID(),
                        isUnlocked: true,
                        unlockedAt: Date(),
                        currentProgress: 7,
                        progressTarget: 7
                    )
                )

                AchievementBadge(
                    achievement: Achievement(
                        name: "Dedicated",
                        description: "Wear any watch 30 days in a row",
                        imageAssetName: "achievement-dedicated",
                        category: .wearingFrequency,
                        unlockCriteria: .consecutiveDaysStreak(days: 30),
                        targetValue: 30
                    ),
                    state: AchievementState(
                        achievementId: UUID(),
                        isUnlocked: false,
                        unlockedAt: nil,
                        currentProgress: 12,
                        progressTarget: 30
                    )
                )
            }

            Spacer()
        }
        .padding()
    }
    .background(AppColors.background)
}
#endif
