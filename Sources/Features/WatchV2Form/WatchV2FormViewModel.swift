import Foundation
import UIKit

@MainActor
public final class WatchV2FormViewModel: ObservableObject {
    @Published public var watch: WatchV2
    @Published public var photoError: String?
    private let photoPipeline = PhotoPipelineV2()

    public init(watch: WatchV2) {
        var model = watch
        model.tags = WatchValidation.normalizeTags(watch.tags)
        model.photos = WatchValidation.enforcePrimaryPhotoInvariant(watch.photos)
        self.watch = model
    }

    public func addPhoto(from image: UIImage) {
        do {
            print("📸 Starting photo add for watch: \(watch.id)")
            print("📸 Existing photos: \(watch.photos.count)")
            print("📸 Image size: \(image.size)")
            
            let (newPhoto, updated) = try photoPipeline.addPhoto(watchId: watch.id, sourceImage: image, existingPhotos: watch.photos)
            
            print("📸 Photo added successfully: \(newPhoto.id)")
            print("📸 Updated photos count: \(updated.count)")
            
            watch.photos = updated
            photoError = nil
        } catch let error as PhotoPipelineV2Error {
            photoError = "Photo error: \(error)"
            print("❌ Photo pipeline error: \(error)")
        } catch {
            photoError = "Failed to add photo: \(error.localizedDescription)"
            print("❌ Photo upload error: \(error)")
            print("❌ Error details: \(error)")
        }
    }

    public func deletePhoto(_ photo: WatchPhoto) {
        watch.photos = photoPipeline.deletePhoto(watchId: watch.id, photo: photo, photos: watch.photos)
    }

    public func movePhoto(fromOffsets: IndexSet, toOffset: Int) {
        guard let source = fromOffsets.first else { return }
        watch.photos = photoPipeline.reorder(photos: watch.photos, from: source, to: toOffset)
    }

    public func setPrimary(_ photoId: UUID) {
        watch.photos = photoPipeline.setPrimary(photoId: photoId, photos: watch.photos)
    }

    public func normalizeTags() { watch.tags = WatchValidation.normalizeTags(watch.tags) }
}


