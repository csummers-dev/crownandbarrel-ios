import SwiftUI

/// Displays progress toward unlocking an achievement.
/// - What: A progress bar or fractional text showing current progress vs target.
/// - Why: Provides visual feedback on how close a user is to unlocking an achievement.
/// - How: Renders a progress bar with percentage fill and optional text overlay.
public struct AchievementProgressView: View {
    public let current: Double
    public let target: Double
    public let isCompact: Bool
    
    @Environment(\.themeToken) private var themeToken
    
    public init(current: Double, target: Double, isCompact: Bool = false) {
        self.current = current
        self.target = target
        self.isCompact = isCompact
    }
    
    public var body: some View {
        if isCompact {
            compactView
        } else {
            fullView
        }
    }
    
    // MARK: - Subviews
    
    private var compactView: some View {
        ProgressView(value: progressPercentage)
            .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
            .frame(height: 4)
            .accessibilityLabel("Progress: \(Int(progressPercentage * 100))%")
    }
    
    private var fullView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text("Progress")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                
                Spacer()
                
                Text("\(Int(progressPercentage * 100))%")
                    .font(.caption)
                    .foregroundStyle(AppColors.textPrimary)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(AppColors.separator)
                        .frame(width: geometry.size.width, height: 8)
                        .cornerRadius(AppRadius.small)
                    
                    // Progress fill
                    Rectangle()
                        .fill(AppColors.accent)
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                        .cornerRadius(AppRadius.small)
                        .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                }
            }
            .frame(height: 8)
            
            Text(progressText)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress: \(progressText), \(Int(progressPercentage * 100))% complete")
        .id(themeToken)
    }
    
    // MARK: - Helpers
    
    private var progressPercentage: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }
    
    private var progressText: String {
        let currentInt = Int(current)
        let targetInt = Int(target)
        return "\(currentInt) / \(targetInt)"
    }
}
