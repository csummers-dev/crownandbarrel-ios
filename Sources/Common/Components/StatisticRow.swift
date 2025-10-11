import SwiftUI

/// Component for displaying key statistics in detail views with prominent styling.
/// - What: Renders a statistic with a label and prominent value display.
/// - Why: Makes important metrics like "Times Worn" and "Last Worn" immediately scannable.
/// - How: Uses larger typography for values and secondary text for labels, with consistent spacing.
public struct StatisticRow: View {
    public let label: String
    public let value: String
    public let icon: String?

    @Environment(\.themeToken) private var themeToken

    /// Creates a statistic row with label, value, and optional SF Symbol icon.
    /// - Parameters:
    ///   - label: The descriptive label (e.g., "Times Worn", "Last Worn")
    ///   - value: The prominent value to display (e.g., "42", "Jan 15, 2025")
    ///   - icon: Optional SF Symbol name to display before the label
    public init(label: String, value: String, icon: String? = nil) {
        self.label = label
        self.value = value
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Icon (optional)
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 24, height: 24)
            }

            // Label and Value
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)

                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.sm)
        .id(themeToken) // Force refresh on theme change
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Statistic Rows") {
    VStack(spacing: AppSpacing.md) {
        DetailSectionHeader(title: "Statistics")

        StatisticRow(
            label: "Times Worn",
            value: "42",
            icon: "clock.fill"
        )

        StatisticRow(
            label: "Last Worn",
            value: "Jan 15, 2025",
            icon: "calendar"
        )

        StatisticRow(
            label: "Achievements",
            value: "5 of 12 unlocked",
            icon: "trophy.fill"
        )

        Divider()
            .padding(.vertical, AppSpacing.sm)

        // Example without icons
        StatisticRow(
            label: "Purchase Date",
            value: "March 2023"
        )

        StatisticRow(
            label: "Days Owned",
            value: "587"
        )

        Spacer()
    }
    .padding()
    .background(AppColors.background)
}
#endif
