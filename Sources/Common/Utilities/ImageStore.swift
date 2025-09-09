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
        return try imagesDirectory().appendingPathComponent("\(assetId).jpg")
    }
}


