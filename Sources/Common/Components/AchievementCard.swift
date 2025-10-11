import SwiftUI

/// Displays an achievement with its unlock status, image, and progress.
/// - What: A reusable card component showing achievement information in locked or unlocked state.
/// - Why: Provides consistent achievement visualization across the app with proper state indication.
/// - How: Accepts Achievement and AchievementState, renders different UI based on unlock status.
public struct AchievementCard: View {
    public let achievement: Achievement
    public let state: AchievementState?

    @Environment(\.themeToken) private var themeToken

    public init(achievement: Achievement, state: AchievementState?) {
        self.achievement = achievement
        self.state = state
    }

    public var body: some View {
        VStack(spacing: AppSpacing.sm) {
            // Achievement image
            achievementImage
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isUnlocked ? AppColors.accent : AppColors.separator, lineWidth: 2)
                )

            // Achievement name
            Text(achievement.name)
                .font(.headline)
                .foregroundStyle(isUnlocked ? AppColors.textPrimary : AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Achievement description
            Text(achievement.description)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Progress or unlock date
            if let state = state {
                if state.isUnlocked {
                    unlockedInfo(state: state)
                } else {
                    lockedInfo(state: state)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppRadius.large)
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
                    .opacity(isUnlocked ? 1.0 : 0.4)
                    .accessibilityHidden(true)
            } else {
                // Fallback to SF Symbol
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(isUnlocked ? AppColors.accent : AppColors.separator)
                    .padding(AppSpacing.sm)
                    .opacity(isUnlocked ? 1.0 : 0.4)
                    .accessibilityHidden(true)
            }
        }
    }

    private func unlockedInfo(state: AchievementState) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColors.accent)
                .font(.caption)

            if let unlockedAt = state.unlockedAt {
                Text(formatDate(unlockedAt))
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private func lockedInfo(state: AchievementState) -> some View {
        VStack(spacing: AppSpacing.xs) {
            AchievementProgressView(
                current: state.currentProgress,
                target: state.progressTarget,
                isCompact: true
            )

            Text(state.progressString)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Helpers

    private var isUnlocked: Bool {
        state?.isUnlocked ?? false
    }

    private var accessibilityLabel: String {
        var label = "\(achievement.name). \(achievement.description)."

        if let state = state {
            if state.isUnlocked {
                label += " Unlocked"
                if let unlockedAt = state.unlockedAt {
                    label += " on \(formatDate(unlockedAt))"
                }
            } else {
                label += " Locked. Progress: \(state.progressString)"
            }
        }

        return label
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
