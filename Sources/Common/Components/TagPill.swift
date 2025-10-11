import SwiftUI

/// Displays a single tag as a rounded pill/chip for tag collections.
/// - What: Renders an individual tag with rounded corners and subtle background.
/// - Why: Provides visual separation and scannability for tag collections.
/// - How: Small rounded rectangle with padding, designed to wrap in horizontal flow layouts.
public struct TagPill: View {
    public let text: String
    
    @Environment(\.themeToken) private var themeToken
    
    public init(_ text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .stroke(AppColors.separator, lineWidth: 0.5)
            )
            .id(themeToken) // Force refresh on theme change
    }
}

/// Displays a collection of tags as horizontally wrapping pills.
/// - What: Renders multiple tags in a flow layout that wraps to multiple rows.
/// - Why: Allows displaying any number of tags without horizontal scrolling.
/// - How: Uses custom flow layout to arrange tag pills with proper spacing and wrapping.
public struct TagPillGroup: View {
    public let tags: [String]
    
    @Environment(\.themeToken) private var themeToken
    
    public init(tags: [String]) {
        self.tags = tags
    }
    
    public var body: some View {
        if !tags.isEmpty {
            FlowLayout(spacing: AppSpacing.xs) {
                ForEach(tags, id: \.self) { tag in
                    TagPill(tag)
                }
            }
            .id(themeToken) // Force refresh on theme change
        }
    }
}

// MARK: - Flow Layout

/// Simple flow layout that arranges views horizontally with wrapping.
/// - What: Custom layout that flows items left-to-right, wrapping to new rows as needed.
/// - Why: Allows tag pills to wrap naturally without fixed row structure.
/// - How: Calculates positions by tracking current x/y coordinates and line heights.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y
                ),
                proposal: .unspecified
            )
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                // Wrap to next line if current item doesn't fit
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.positions = positions
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Tag Pills") {
    ScrollView {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            DetailSectionHeader(title: "Single Tag")
            
            TagPill("Diver")
            
            DetailSectionHeader(title: "Multiple Tags - Wrapping Flow")
            
            TagPillGroup(tags: [
                "Diver",
                "Automatic",
                "Swiss Made",
                "Water Resistant",
                "Chronometer",
                "Tool Watch",
                "Vintage Inspired",
                "Limited Edition"
            ])
            
            DetailSectionHeader(title: "Few Tags")
            
            TagPillGroup(tags: ["Sports", "Daily Wearer"])
            
            DetailSectionHeader(title: "In Specification Context")
            
            VStack(spacing: 0) {
                SpecificationRow(label: "Serial Number", value: "ABC123")
                SpecificationRow(label: "Production Year", value: 2023).map { $0 }
                SpecificationRow(label: "Country", value: "Switzerland")
            }
            
            HStack(alignment: .top, spacing: AppSpacing.md) {
                Text("Tags")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                
                Spacer()
                
                TagPillGroup(tags: ["Diver", "Automatic", "Swiss Made"])
                    .frame(maxWidth: 200, alignment: .trailing)
            }
            .padding(.vertical, AppSpacing.xxs)
            
            Spacer()
        }
        .padding()
    }
    .background(AppColors.background)
}
#endif

