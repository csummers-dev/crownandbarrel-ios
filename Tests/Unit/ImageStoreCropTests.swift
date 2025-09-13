import XCTest
@testable import CrownAndBarrel

final class ImageStoreCropTests: XCTestCase {
    func testSquareCropCentersAndProducesSquare() throws {
        // Create a 200x100 red image
        let size = CGSize(width: 200, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let cropped = ImageStore.squareCropped(img)
        XCTAssertEqual(cropped.size.width, cropped.size.height, accuracy: 0.5)
        XCTAssertLessThanOrEqual(cropped.size.width, 100.5)
    }

    func testSaveAndLoadRoundTrip() throws {
        let size = CGSize(width: 64, height: 64)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        UIColor.blue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let id = UUID().uuidString
        _ = try ImageStore.saveImage(img, assetId: id)
        let loaded = ImageStore.loadImage(assetId: id)
        XCTAssertNotNil(loaded)
    }
}


