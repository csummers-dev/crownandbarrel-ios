import SwiftUI

/// Renders a watch image from disk or a theme-aware placeholder.
/// - What: Displays a square-friendly image that can be clipped/fitted by parent containers.
/// - Why: Centralizes placeholder logic and keeps UI consistent across screens.
/// - How: Loads from `ImageStore` by `imageAssetId`; falls back to light/dark placeholder by environment.
public struct WatchImageView: View {
    public let imageAssetId: String?
    @Environment(\.colorScheme) private var colorScheme

    public init(imageAssetId: String?) {
        self.imageAssetId = imageAssetId
    }

    public var body: some View {
        Group {
            if let id = imageAssetId, let img = ImageStore.loadImage(assetId: id) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .accessibilityIdentifier("watch-image-real")
            } else {
                let style: UIUserInterfaceStyle = (colorScheme == .dark) ? .dark : .light
                if let ui = ImageStore.loadPlaceholder(colorScheme: style) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .accessibilityIdentifier("watch-image-placeholder")
                } else {
                    Image(systemName: "applewatch")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(16)
                        .accessibilityIdentifier("watch-image-placeholder")
                }
            }
        }
    }
}


