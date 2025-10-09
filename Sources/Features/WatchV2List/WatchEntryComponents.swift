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
            // Manufacturer - displayed separately on first line
            Text(manufacturer)
                .font(.headline)
                .lineLimit(1)
            
            // Model - displayed on second line
            Text(modelName)
                .font(.subheadline)
                .lineLimit(1)
            
            // Nickname - optional, displayed on third line if present
            if let nickname = nickname {
                Text(nickname)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Grid Card Component

/// Grid card component for displaying a watch entry in grid view
public struct WatchGridCard: View {
    let watch: WatchV2
    
    public init(watch: WatchV2) {
        self.watch = watch
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Photo
            let primary = watch.photos.first(where: { $0.isPrimary }) ?? watch.photos.first
            if let primary,
               let img = PhotoStoreV2.loadThumb(watchId: watch.id, photoId: primary.id) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(height: 120)
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
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - List Row Component

/// List row component for displaying a watch entry in list view
public struct WatchListRow: View {
    let watch: WatchV2
    
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
        .padding(.vertical, 4)
    }
}

