import UIKit

/// Manages on-disk storage of images referenced by watches using an asset id.
/// - What: Provides save/delete/locate helpers for single-image assets.
/// - Why: Keeps the database slim and avoids bloating Core Data with binaries.
/// - How: Stores JPEGs under Documents/images with stable file names based on `assetId`.
public enum ImageStore {
    public static func imagesDirectory() throws -> URL {
        let base = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = base.appendingPathComponent("images", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    public static func saveImage(_ image: UIImage, assetId: String) throws -> URL {
        let url = try imagesDirectory().appendingPathComponent("\(assetId).jpg")
        guard let data = image.jpegData(compressionQuality: 0.85) else { throw AppError.repository("Failed to encode image") }
        try data.write(to: url, options: .atomic)
        return url
    }

    public static func deleteImage(assetId: String) throws {
        let url = try imagesDirectory().appendingPathComponent("\(assetId).jpg")
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    public static func imageURL(assetId: String) throws -> URL {
        try imagesDirectory().appendingPathComponent("\(assetId).jpg")
    }

    /// Loads an image by assetId or returns nil if it doesn't exist.
    public static func loadImage(assetId: String) -> UIImage? {
        do {
            let url = try imageURL(assetId: assetId)
            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
            return UIImage(contentsOfFile: url.path)
        } catch {
            return nil
        }
    }

    /// Loads a theme-aware placeholder image from the app bundle.
    /// - Parameters:
    ///   - colorScheme: Light/Dark preference to pick the matching asset.
    ///   - variantKey: Future hook for additional theme variants (e.g., "gold").
    /// - Returns: UIImage if found, else nil.
    public static func loadPlaceholder(colorScheme: UIUserInterfaceStyle, variantKey: String? = nil) -> UIImage? {
        // Prefer asset catalog which auto-picks light/dark variants
        if let asset = UIImage(named: "WatchEntryPlaceholder") { return asset }
        // Fallback: generate a simple themed placeholder (watch glyph in a rounded rect)
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.default())
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            // Background based on theme
            let bgColor = UIColor(AppColors.secondaryBackground)
            let fgColor = UIColor(AppColors.textSecondary)
            UIBezierPath(roundedRect: rect, cornerRadius: 24).addClip()
            bgColor.setFill()
            ctx.fill(rect)

            // Draw system watch glyph centered
            let config = UIImage.SymbolConfiguration(pointSize: 72, weight: .regular)
            let symbol = UIImage(systemName: "watch.case", withConfiguration: config)
            let tint = symbol?.withTintColor(fgColor, renderingMode: UIImage.RenderingMode.alwaysOriginal)
            if let glyph = tint {
                let glyphSize = glyph.size
                let glyphRect = CGRect(
                    x: (size.width - glyphSize.width) / 2.0,
                    y: (size.height - glyphSize.height) / 2.0,
                    width: glyphSize.width,
                    height: glyphSize.height
                )
                glyph.draw(in: glyphRect)
            }
        }
        return image.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
    }

    /// Returns a square-cropped copy of the image (center-crop) given any source image.
    /// - Parameter image: Source image.
    /// - Returns: New UIImage cropped to a square of min(width,height), preserving scale and orientation.
    public static func squareCropped(_ image: UIImage) -> UIImage {
        let size = image.size
        let side = min(size.width, size.height)
        let originX = (size.width - side) / 2.0
        let originY = (size.height - side) / 2.0
        let cropRect = CGRect(x: originX, y: originY, width: side, height: side)
        guard let cg = image.cgImage?.cropping(to: cropRect.applying(CGAffineTransform(scaleX: image.scale, y: image.scale))) else {
            return image
        }
        return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
    }
}
