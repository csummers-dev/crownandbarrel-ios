import SwiftUI

/// Displays a grid of achievements with optional filtering and sorting.
/// - What: A responsive grid layout for displaying multiple achievements.
/// - Why: Provides a consistent way to show achievement collections across the app.
/// - How: Uses LazyVGrid with achievement cards, supports filtering by category and unlock status.
public struct AchievementGridView: View {
    public let achievements: [(achievement: Achievement, state: AchievementState?)]
    public let onAchievementTap: ((Achievement) -> Void)?
    
    @Environment(\.themeToken) private var themeToken
    @State private var selectedCategory: AchievementCategory?
    @State private var showOnlyUnlocked: Bool = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: AppSpacing.md)
    ]
    
    public init(
        achievements: [(achievement: Achievement, state: AchievementState?)],
        onAchievementTap: ((Achievement) -> Void)? = nil
    ) {
        self.achievements = achievements
        self.onAchievementTap = onAchievementTap
    }
    
    public var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Filter controls
            filterControls
            
            // Achievement grid
            if filteredAchievements.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        ForEach(filteredAchievements, id: \.achievement.id) { item in
                            AchievementCard(
                                achievement: item.achievement,
                                state: item.state
                            )
                            .onTapGesture {
                                onAchievementTap?(item.achievement)
                            }
                        }
                    }
                    .padding(AppSpacing.md)
                }
            }
        }
        .id(themeToken)
    }
    
    // MARK: - Subviews
    
    private var filterControls: some View {
        VStack(spacing: AppSpacing.sm) {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    // "All" button
                    FilterChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    // Category buttons
                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.displayName,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.md)
            }
            
            // Unlock status toggle
            Toggle("Show only unlocked", isOn: $showOnlyUnlocked)
                .padding(.horizontal, AppSpacing.md)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.background)
    }
    
    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "trophy.slash")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.textSecondary)
            
            Text("No achievements found")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            
            Text("Adjust your filters or start earning achievements!")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xl)
    }
    
    // MARK: - Filtering
    
    private var filteredAchievements: [(achievement: Achievement, state: AchievementState?)] {
        var filtered = achievements
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.achievement.category == category }
        }
        
        // Filter by unlock status
        if showOnlyUnlocked {
            filtered = filtered.filter { $0.state?.isUnlocked == true }
        }
        
        // Sort: unlocked first, then by progress, then alphabetically
        filtered.sort { lhs, rhs in
            let lhsUnlocked = lhs.state?.isUnlocked ?? false
            let rhsUnlocked = rhs.state?.isUnlocked ?? false
            
            if lhsUnlocked != rhsUnlocked {
                return lhsUnlocked // Unlocked first
            }
            
            if !lhsUnlocked {
                // For locked achievements, sort by progress percentage descending
                let lhsProgress = lhs.state?.progressPercentage ?? 0
                let rhsProgress = rhs.state?.progressPercentage ?? 0
                if lhsProgress != rhsProgress {
                    return lhsProgress > rhsProgress
                }
            }
            
            // Alphabetically by name
            return lhs.achievement.name < rhs.achievement.name
        }
        
        return filtered
    }
}

// MARK: - Filter Chip Component

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Color.white : AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? AppColors.accent : AppColors.secondaryBackground)
                .cornerRadius(AppRadius.large)
        }
        .buttonStyle(.plain)
    }
}
