@testable import CrownAndBarrel
import XCTest

final class WatchValidationTests: XCTestCase {
    func testTagSlugging() {
        let input = ["Diver", "Diver", "GMT Master", "  Vintage  ", ""]
        let out = WatchValidation.normalizeTags(input)
        XCTAssertEqual(out, ["diver", "gmt-master", "vintage"])
    }

    func testProductionYear() {
        XCTAssertTrue(WatchValidation.validateProductionYear(nil))
        XCTAssertTrue(WatchValidation.validateProductionYear(1_900))
        XCTAssertFalse(WatchValidation.validateProductionYear(1_899))
        XCTAssertTrue(WatchValidation.validateProductionYear(Calendar.current.component(.year, from: Date())))
        XCTAssertFalse(WatchValidation.validateProductionYear(Calendar.current.component(.year, from: Date()) + 1))
    }

    func testCaseDimensions() {
        XCTAssertTrue(WatchValidation.validateCaseDimensions(diameter: 40.0, thickness: 13.0, lugToLug: 48.0, lugWidth: 20))
        XCTAssertFalse(WatchValidation.validateCaseDimensions(diameter: 10.0, thickness: 30.0, lugToLug: 100.0, lugWidth: 100))
    }

    func testMovementRanges() {
        XCTAssertTrue(WatchValidation.validateMovement(powerReserveHours: 48.0, frequencyVPH: 28_800, jewelCount: 25, accuracyPPD: -5.0))
        XCTAssertTrue(WatchValidation.validateMovement(powerReserveHours: nil, frequencyVPH: 0, jewelCount: 0, accuracyPPD: nil))
        XCTAssertFalse(WatchValidation.validateMovement(powerReserveHours: 3_000.0, frequencyVPH: 12_345, jewelCount: 100, accuracyPPD: 0))
    }

    func testWaterResistance() {
        XCTAssertTrue(WatchValidation.validateWaterResistance(200))
        XCTAssertTrue(WatchValidation.validateWaterResistance(1_500))
        XCTAssertFalse(WatchValidation.validateWaterResistance(25))
    }

    func testPhotoInvariants() {
        let a = WatchPhoto(id: UUID(), localIdentifier: "a", isPrimary: false, position: 0)
        let b = WatchPhoto(id: UUID(), localIdentifier: "b", isPrimary: false, position: 1)
        let adjusted = WatchValidation.enforcePrimaryPhotoInvariant([a, b])
        XCTAssertEqual(adjusted.filter { $0.isPrimary }.count, 1)
        XCTAssertTrue(WatchValidation.validatePhotoLimit(Array(repeating: a, count: 10)))
        XCTAssertFalse(WatchValidation.validatePhotoLimit(Array(repeating: a, count: 11)))
    }
}
