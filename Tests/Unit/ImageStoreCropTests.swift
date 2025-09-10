import XCTest
@testable import GoodWatch

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
}


