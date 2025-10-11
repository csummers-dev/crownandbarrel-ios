import SwiftUI

/// Reusable section header component for detail views with luxury typography styling.
/// - What: Displays section titles in detail views with consistent styling.
/// - Why: Provides visual separation between specification groups while maintaining luxury aesthetic.
/// - How: Uses AppTypography.heading for serif elegance, with consistent spacing and colors.
public struct DetailSectionHeader: View {
    public let title: String

    @Environment(\.themeToken) private var themeToken

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(AppTypography.heading)
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.sm)
            .id(themeToken) // Force refresh on theme change
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Detail Section Headers") {
    VStack(spacing: 0) {
        DetailSectionHeader(title: "Core Details")

        Text("Serial Number: ABC123")
            .font(.body)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.horizontal)

        DetailSectionHeader(title: "Case Specifications")

        Text("Material: Stainless Steel")
            .font(.body)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.horizontal)

        DetailSectionHeader(title: "Movement")

        Text("Type: Automatic")
            .font(.body)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.horizontal)

        Spacer()
    }
    .padding()
    .background(AppColors.background)
}
#endif
