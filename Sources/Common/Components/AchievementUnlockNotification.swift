import SwiftUI

/// Displays a celebratory notification when an achievement is unlocked.
/// - What: An overlay notification that appears with animation when an achievement unlocks.
/// - Why: Provides immediate positive feedback to celebrate user accomplishments.
/// - How: Slides in from top, displays achievement info, auto-dismisses after 3 seconds,
///        and triggers haptic feedback per PRD requirements.
public struct AchievementUnlockNotification: View {
    public let achievement: Achievement
    public let isPresented: Binding<Bool>

    @Environment(\.themeToken) private var themeToken
    @State private var offset: CGFloat = -200

    public init(achievement: Achievement, isPresented: Binding<Bool>) {
        self.achievement = achievement
        self.isPresented = isPresented
    }

    public var body: some View {
        if isPresented.wrappedValue {
            VStack {
                notificationContent
                    .padding(AppSpacing.md)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(AppRadius.large)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, AppSpacing.md)
                    .offset(y: offset)
                    .onAppear {
                        // Trigger haptic feedback
                        Haptics.success()

                        // Animate in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            offset = AppSpacing.md
                        }

                        // Auto-dismiss after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            dismiss()
                        }
                    }

                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(999) // Ensure it appears on top
            .id(themeToken)
        }
    }

    // MARK: - Subviews

    private var notificationContent: some View {
        HStack(spacing: AppSpacing.md) {
            // Achievement image
            if let image = UIImage(named: achievement.imageAssetName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(AppColors.accent)
                    .padding(AppSpacing.sm)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // "Achievement Unlocked!" header
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(AppColors.accent)

                    Text("Achievement Unlocked!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.accent)
                }

                // Achievement name
                Text(achievement.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                // Achievement description
                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            // Dismiss button
            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Achievement unlocked: \(achievement.name). \(achievement.description)")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to dismiss")
        .contentShape(Rectangle())
        .onTapGesture {
            dismiss()
        }
        // Support swipe to dismiss
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height < -50 {
                        dismiss()
                    }
                }
        )
    }

    // MARK: - Actions

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = -200
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented.wrappedValue = false
        }
    }
}

// MARK: - View Extension for Easy Integration

public extension View {
    /// Displays an achievement unlock notification overlay when triggered.
    /// - Parameters:
    ///   - achievement: The achievement that was unlocked (optional)
    ///   - isPresented: Binding to control notification visibility
    /// - Returns: View with notification overlay
    func achievementUnlockNotification(
        achievement: Achievement?,
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self

            if let achievement = achievement {
                AchievementUnlockNotification(
                    achievement: achievement,
                    isPresented: isPresented
                )
            }
        }
    }
}
