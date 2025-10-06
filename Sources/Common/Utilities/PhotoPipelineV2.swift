import UIKit

public enum PhotoPipelineV2Error: Error {
    case maxPhotosReached
}

public final class PhotoPipelineV2 {
    public init() {}

    // Adds a photo to the watch, enforcing square crop, downscale, and thumbnail generation.
    // Returns the created WatchPhoto and the updated photo array with invariants enforced.
    public func addPhoto(watchId: UUID, sourceImage: UIImage, makePrimary: Bool = false, existingPhotos: [WatchPhoto]) throws -> (WatchPhoto, [WatchPhoto]) {
        guard existingPhotos.count < 10 else { throw PhotoPipelineV2Error.maxPhotosReached }

        // Transform
        let squared = PhotoTransformsV2.squareCropped(sourceImage)
        let original = PhotoTransformsV2.downscale(squared, maxDimension: 3000)
        let thumb = PhotoTransformsV2.thumbnail(original, size: 1000)

        // Persist
        let photoId = UUID()
        let originalURL = try PhotoStoreV2.originalURL(watchId: watchId, photoId: photoId)
        let thumbURL = try PhotoStoreV2.thumbURL(watchId: watchId, photoId: photoId)
        try PhotoStoreV2.saveJPEG(original, to: originalURL, quality: 0.9)
        try PhotoStoreV2.saveJPEG(thumb, to: thumbURL, quality: 0.9)
        PhotoCacheV2.shared.setThumb(thumb, forKey: "\(watchId.uuidString)/\(photoId.uuidString)")

        // Metadata
        let position = existingPhotos.count
        var new = WatchPhoto(id: photoId, localIdentifier: originalURL.path, isPrimary: makePrimary || existingPhotos.isEmpty, position: position)
        var updated = existingPhotos + [new]
        updated = WatchValidation.enforcePrimaryPhotoInvariant(updated)
        updated = normalizePositions(updated)
        // Reflect possibly changed primary flag
        if let idx = updated.firstIndex(where: { $0.id == new.id }) { new = updated[idx] }
        return (new, updated)
    }

    public func deletePhoto(watchId: UUID, photo: WatchPhoto, photos: [WatchPhoto]) -> [WatchPhoto] {
        PhotoStoreV2.deletePhotoFiles(watchId: watchId, photoId: photo.id)
        var remaining = photos.filter { $0.id != photo.id }
        remaining = WatchValidation.enforcePrimaryPhotoInvariant(remaining)
        return normalizePositions(remaining)
    }

    public func reorder(photos: [WatchPhoto], from fromIndex: Int, to toIndex: Int) -> [WatchPhoto] {
        var copy = photos
        guard fromIndex != toIndex, fromIndex >= 0, fromIndex < copy.count, toIndex >= 0, toIndex <= copy.count else { return photos }
        let item = copy.remove(at: fromIndex)
        copy.insert(item, at: min(toIndex, copy.count))
        copy = normalizePositions(copy)
        return WatchValidation.enforcePrimaryPhotoInvariant(copy)
    }

    public func setPrimary(photoId: UUID, photos: [WatchPhoto]) -> [WatchPhoto] {
        var adjusted: [WatchPhoto] = []
        for p in photos {
            var q = p
            q.isPrimary = (p.id == photoId)
            adjusted.append(q)
        }
        return WatchValidation.enforcePrimaryPhotoInvariant(adjusted)
    }

    private func normalizePositions(_ photos: [WatchPhoto]) -> [WatchPhoto] {
        var out: [WatchPhoto] = []
        for (idx, p) in photos.enumerated() {
            var q = p
            q.position = idx
            out.append(q)
        }
        return out
    }
}


