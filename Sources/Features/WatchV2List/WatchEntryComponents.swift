import SwiftUI

/// Shared components for displaying watch entries in both grid and list views.
/// - What: Reusable view components for watch collection entries
/// - Why: Ensures visual consistency between grid and list views
/// - How: Extracted from WatchV2ListView to enable component reuse and maintainability

// MARK: - Shared Content Component

/// Shared content view that displays manufacturer, model, and nickname consistently.
/// - What: Displays watch text information with consistent styling and hierarchy
/// - Why: Ensures manufacturer, model, and nickname are displayed identically across grid and list views
/// - How: Uses consistent fonts, spacing, and handles optional nickname gracefully
struct WatchEntryContent: View {
    let manufacturer: String
    let modelName: String
    let nickname: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Manufacturer - Large and bold for visual prominence
            Text(manufacturer)
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
                .truncationMode(.tail)
            
            // Model - Medium size, regular weight
            Text(modelName)
                .font(.system(size: 14, weight: .regular))
                .lineLimit(1)
                .truncationMode(.tail)
            
            // Nickname - Small size, lighter weight, secondary color
            if let nickname = nickname {
                Text(nickname)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }
}

// MARK: - Grid Card Component

/// Grid card component for displaying a watch entry in grid view
public struct WatchGridCard: View {
    let watch: WatchV2
    
    // Fixed square dimensions for consistent grid layout
    // Calculation: (iPhone screen width ~393pt - horizontal padding 32pt - column spacing 8pt) / 2 = 176.5pt
    private let cardSize: CGFloat = 176
    
    public init(watch: WatchV2) {
        self.watch = watch
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Photo - Takes up about 60% of card height for proper balance
            let imageHeight: CGFloat = cardSize * 0.6
            let primary = watch.photos.first(where: { $0.isPrimary }) ?? watch.photos.first
            if let primary,
               let img = PhotoStoreV2.loadThumb(watchId: watch.id, photoId: primary.id) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardSize, height: imageHeight)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: cardSize, height: imageHeight)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "clock")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    )
            }
            
            // Text Content - Use shared component for consistency
            WatchEntryContent(
                manufacturer: watch.manufacturer,
                modelName: watch.modelName,
                nickname: watch.nickname
            )
            .padding(.horizontal, 4)
            
            Spacer(minLength: 0)
        }
        .frame(width: cardSize, height: cardSize)
        .background(Color(.systemBackground))
    }
}

// MARK: - List Row Component

/// List row component for displaying a watch entry in list view
public struct WatchListRow: View {
    let watch: WatchV2
    
    // Fixed height for consistent list item sizing
    // Height accommodates image (56pt) plus vertical padding
    private let rowHeight: CGFloat = 72
    
    public init(watch: WatchV2) {
        self.watch = watch
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Photo
            let primary = watch.photos.first(where: { $0.isPrimary }) ?? watch.photos.first
            if let primary,
               let img = PhotoStoreV2.loadThumb(watchId: watch.id, photoId: primary.id) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                    )
            }
            
            // Text Content - Use shared component for consistency
            WatchEntryContent(
                manufacturer: watch.manufacturer,
                modelName: watch.modelName,
                nickname: watch.nickname
            )
            
            Spacer()
        }
        .frame(height: rowHeight)
        .padding(.vertical, AppSpacing.xs)
    }
}

