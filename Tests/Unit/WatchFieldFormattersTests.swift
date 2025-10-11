@testable import CrownAndBarrel
import XCTest

/// Tests for WatchFieldFormatters utility to verify field formatting and visibility logic.
final class WatchFieldFormattersTests: XCTestCase {

    // MARK: - Numeric Formatting Tests

    func testMeasurementFormatting() throws {
        // Whole numbers - no decimals
        XCTAssertEqual(WatchFieldFormatters.formatMeasurement(40.0, unit: "mm"), "40mm")

        // Fractional values - show decimals
        XCTAssertEqual(WatchFieldFormatters.formatMeasurement(40.5, unit: "mm"), "40.5mm")

        // Without unit
        XCTAssertEqual(WatchFieldFormatters.formatMeasurement(12.5), "12.5")

        // Nil handling
        XCTAssertNil(WatchFieldFormatters.formatMeasurement(nil, unit: "mm"))

        // Int formatting
        XCTAssertEqual(WatchFieldFormatters.formatInt(20, unit: "mm"), "20mm")
        XCTAssertNil(WatchFieldFormatters.formatInt(nil, unit: "mm"))

        // Edge cases
        XCTAssertEqual(WatchFieldFormatters.formatMeasurement(0, unit: "mm"), "0mm")
        XCTAssertEqual(WatchFieldFormatters.formatMeasurement(40.567, unit: "mm", maxDecimals: 2), "40.57mm")
    }

    // MARK: - Currency Formatting Tests

    func testCurrencyFormatting() throws {
        // With currency code
        let result1 = WatchFieldFormatters.formatCurrency(Decimal(1_250.50), currencyCode: "USD")
        XCTAssertNotNil(result1)
        XCTAssertTrue(result1?.contains("USD") ?? false, "Should include currency code")

        // Without currency code
        let result2 = WatchFieldFormatters.formatCurrency(Decimal(1_250), currencyCode: nil)
        XCTAssertNotNil(result2)

        // Nil amount
        XCTAssertNil(WatchFieldFormatters.formatCurrency(nil, currencyCode: "USD"))

        // Zero amount
        XCTAssertNotNil(WatchFieldFormatters.formatCurrency(Decimal(0), currencyCode: "USD"))
    }

    // MARK: - Enum Formatting Tests

    func testEnumFormatting() throws {
        enum TestEnum: String {
            case stainlessSteel = "stainless_steel"
            case screwDown = "screwDown"
        }

        XCTAssertEqual(WatchFieldFormatters.formatEnumValue(TestEnum.stainlessSteel), "Stainless Steel")
        XCTAssertEqual(WatchFieldFormatters.formatEnumValue(TestEnum.screwDown), "Screw Down")
        XCTAssertNil(WatchFieldFormatters.formatEnumValue(nil as TestEnum?))
    }

    // MARK: - Specialized Formatters Tests

    func testSpecializedFormatters() throws {
        // Frequency
        XCTAssertEqual(WatchFieldFormatters.formatFrequency(28_800), "28,800 vph")
        XCTAssertEqual(WatchFieldFormatters.formatFrequency(36_000), "36,000 vph")
        XCTAssertNil(WatchFieldFormatters.formatFrequency(nil))

        // Power reserve
        XCTAssertEqual(WatchFieldFormatters.formatPowerReserve(38), "38 hours")
        XCTAssertEqual(WatchFieldFormatters.formatPowerReserve(72), "3 days")
        XCTAssertEqual(WatchFieldFormatters.formatPowerReserve(1), "1 hour")
        XCTAssertEqual(WatchFieldFormatters.formatPowerReserve(50), "50 hours")
        XCTAssertNil(WatchFieldFormatters.formatPowerReserve(nil))

        // Accuracy
        XCTAssertEqual(WatchFieldFormatters.formatAccuracy(2.5), "±2.5 sec/day")
        XCTAssertEqual(WatchFieldFormatters.formatAccuracy(-4), "-4 sec/day")
        XCTAssertNil(WatchFieldFormatters.formatAccuracy(nil))

        // Water resistance
        XCTAssertEqual(WatchFieldFormatters.formatWaterResistance(100), "100m")
        XCTAssertNil(WatchFieldFormatters.formatWaterResistance(nil))

        // Box & Papers
        XCTAssertEqual(WatchFieldFormatters.formatBoxPapers(.fullSet), "Full Set")
        XCTAssertEqual(WatchFieldFormatters.formatBoxPapers(.boxOnly), "Box Only")
        XCTAssertEqual(WatchFieldFormatters.formatBoxPapers(.papersOnly), "Papers Only")
        XCTAssertEqual(WatchFieldFormatters.formatBoxPapers(.watchOnly), "Watch Only")
        XCTAssertEqual(WatchFieldFormatters.formatBoxPapers(.partial), "Partial")
        XCTAssertEqual(WatchFieldFormatters.formatBoxPapers(.other("custom")), "Custom")
        XCTAssertNil(WatchFieldFormatters.formatBoxPapers(nil))
    }

    // MARK: - Group Visibility Tests

    func testCoreDetailsVisibility() throws {
        // With data
        let watchWithData = WatchV2(manufacturer: "Rolex", modelName: "Submariner", serialNumber: "ABC123")
        XCTAssertTrue(WatchFieldFormatters.hasCoreDetails(watchWithData))

        let watchWithTags = WatchV2(manufacturer: "Rolex", modelName: "Submariner", tags: ["Diver"])
        XCTAssertTrue(WatchFieldFormatters.hasCoreDetails(watchWithTags))

        // Without data
        let watchWithoutData = WatchV2(manufacturer: "Rolex", modelName: "Submariner")
        XCTAssertFalse(WatchFieldFormatters.hasCoreDetails(watchWithoutData))
    }

    func testCaseSpecsVisibility() throws {
        XCTAssertTrue(WatchFieldFormatters.hasCaseSpecs(WatchCase(material: .steel, diameterMM: 40)))
        XCTAssertFalse(WatchFieldFormatters.hasCaseSpecs(WatchCase()))
    }

    func testDialDetailsVisibility() throws {
        XCTAssertTrue(WatchFieldFormatters.hasDialDetails(WatchDial(color: "Black", finish: .matte)))
        XCTAssertTrue(WatchFieldFormatters.hasDialDetails(WatchDial(complications: ["Date"])))
        XCTAssertFalse(WatchFieldFormatters.hasDialDetails(WatchDial()))
    }

    func testCrystalDetailsVisibility() throws {
        XCTAssertTrue(WatchFieldFormatters.hasCrystalDetails(WatchCrystal(material: .sapphire)))
        XCTAssertFalse(WatchFieldFormatters.hasCrystalDetails(WatchCrystal()))
    }

    func testMovementSpecsVisibility() throws {
        XCTAssertTrue(WatchFieldFormatters.hasMovementSpecs(MovementSpec(type: .automatic, caliber: "ETA")))
        XCTAssertFalse(WatchFieldFormatters.hasMovementSpecs(MovementSpec()))
    }

    func testWaterResistanceVisibility() throws {
        XCTAssertTrue(WatchFieldFormatters.hasWaterResistance(WatchWater(waterResistanceM: 100)))
        XCTAssertTrue(WatchFieldFormatters.hasWaterResistance(WatchWater(crownGuard: true)))
        XCTAssertFalse(WatchFieldFormatters.hasWaterResistance(WatchWater()))
    }

    func testStrapDetailsVisibility() throws {
        XCTAssertTrue(WatchFieldFormatters.hasStrapDetails(WatchStrapCurrent(type: .bracelet, material: "Steel")))
        XCTAssertFalse(WatchFieldFormatters.hasStrapDetails(WatchStrapCurrent()))
    }

    func testOwnershipInfoVisibility() throws {
        XCTAssertTrue(WatchFieldFormatters.hasOwnershipInfo(WatchOwnership(dateAcquired: Date())))
        XCTAssertFalse(WatchFieldFormatters.hasOwnershipInfo(WatchOwnership()))
    }
}
