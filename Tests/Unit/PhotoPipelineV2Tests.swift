import XCTest
import UIKit
@testable import CrownAndBarrel

final class PhotoPipelineV2Tests: XCTestCase {
    
    private var testWatchIds: [UUID] = []
    
    override func setUpWithError() throws {
        testWatchIds = []
    }
    
    override func tearDownWithError() throws {
        // Clean up any test files created during tests
        for watchId in testWatchIds {
            // Clean up photo directories for test watch IDs
            let photoDir = try PhotoStoreV2.photosDirectory(watchId: watchId)
            if FileManager.default.fileExists(atPath: photoDir.path) {
                try? FileManager.default.removeItem(at: photoDir)
            }
        }
        testWatchIds = []
    }
    
    func makeSquareImage(color: UIColor = .systemBlue, size: CGFloat = 1400) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
        }
    }

    func testAddAndDeletePhoto() throws {
        let pipeline = PhotoPipelineV2()
        let watchId = UUID()
        testWatchIds.append(watchId) // Track for cleanup
        
        let img = makeSquareImage()
        let (photo, list) = try pipeline.addPhoto(watchId: watchId, sourceImage: img, existingPhotos: [])
        XCTAssertEqual(list.count, 1)
        XCTAssertTrue(list.first?.isPrimary == true)

        // Files exist
        let o = try PhotoStoreV2.originalURL(watchId: watchId, photoId: photo.id)
        let t = try PhotoStoreV2.thumbURL(watchId: watchId, photoId: photo.id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: o.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: t.path))

        // Delete cleans up
        let after = pipeline.deletePhoto(watchId: watchId, photo: photo, photos: list)
        XCTAssertTrue(after.isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: o.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: t.path))
    }
}


