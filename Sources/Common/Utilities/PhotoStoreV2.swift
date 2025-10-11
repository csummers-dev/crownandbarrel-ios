import UIKit

public final class PhotoCacheV2 {
    public static let shared = PhotoCacheV2()
    private let thumbCache = NSCache<NSString, UIImage>()
    private init() {}

    public func thumb(forKey key: String) -> UIImage? { thumbCache.object(forKey: key as NSString) }
    public func setThumb(_ image: UIImage, forKey key: String) { thumbCache.setObject(image, forKey: key as NSString) }
}

public enum PhotoStoreV2 {
    public static func watchDirectory(watchId: UUID) throws -> URL {
        let base = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = base.appendingPathComponent("images-v2", isDirectory: true).appendingPathComponent(watchId.uuidString, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    public static func originalURL(watchId: UUID, photoId: UUID) throws -> URL {
        try watchDirectory(watchId: watchId).appendingPathComponent("\(photoId.uuidString).jpg")
    }

    public static func thumbURL(watchId: UUID, photoId: UUID) throws -> URL {
        try watchDirectory(watchId: watchId).appendingPathComponent("thumb-\(photoId.uuidString).jpg")
    }

    public static func saveJPEG(_ image: UIImage, to url: URL, quality: CGFloat = 0.9) throws {
        guard let data = image.jpegData(compressionQuality: quality) else { throw AppError.repository("Failed to encode image") }
        try data.write(to: url, options: .atomic)
    }

    public static func loadImage(at url: URL) -> UIImage? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    public static func loadThumb(watchId: UUID, photoId: UUID) -> UIImage? {
        let key = "\(watchId.uuidString)/\(photoId.uuidString)"
        if let cached = PhotoCacheV2.shared.thumb(forKey: key) { return cached }
        guard let img = try? thumbURL(watchId: watchId, photoId: photoId).path, FileManager.default.fileExists(atPath: img) else { return nil }
        let image = UIImage(contentsOfFile: img)
        if let image { PhotoCacheV2.shared.setThumb(image, forKey: key) }
        return image
    }

    public static func deletePhotoFiles(watchId: UUID, photoId: UUID) {
        if let url = try? originalURL(watchId: watchId, photoId: photoId) { try? FileManager.default.removeItem(at: url) }
        if let url = try? thumbURL(watchId: watchId, photoId: photoId) { try? FileManager.default.removeItem(at: url) }
    }
}

// MARK: - Image transforms

public enum PhotoTransformsV2 {
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

    public static func downscale(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let w = image.size.width
        let h = image.size.height
        let maxSide = max(w, h)
        guard maxSide > maxDimension else { return image }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: floor(w * scale), height: floor(h * scale))
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    public static func thumbnail(_ image: UIImage, size: CGFloat = 1_000) -> UIImage {
        let square = squareCropped(image)
        let newSize = CGSize(width: size, height: size)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            square.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
