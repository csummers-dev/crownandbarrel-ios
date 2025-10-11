@testable import CrownAndBarrel
import XCTest

/// Tests for WatchFieldFormatters utility to verify field formatting and visibility logic.
final class WatchFieldFormattersTests: XCTestCase {
    // MARK: - Numeric Formatting Tests

    func testFormatMeasurementWholeNumber() throws {
        let result = WatchFieldFormatters.formatMeasurement(40.0, unit: "mm")
        XCTAssertEqual(result, "40mm", "Should not show decimals for whole numbers")
    }

    func testFormatMeasurementWithDecimals() throws {
        let result = WatchFieldFormatters.formatMeasurement(40.5, unit: "mm")
        XCTAssertEqual(result, "40.5mm", "Should show decimals for fractional values")
    }

    func testFormatMeasurementWithoutUnit() throws {
        let result = WatchFieldFormatters.formatMeasurement(12.5)
        XCTAssertEqual(result, "12.5", "Should work without unit")
    }

    func testFormatMeasurementNil() throws {
        let result = WatchFieldFormatters.formatMeasurement(nil, unit: "mm")
        XCTAssertNil(result, "Should return nil for nil value")
    }

    func testFormatIntWithUnit() throws {
        let result = WatchFieldFormatters.formatInt(20, unit: "mm")
        XCTAssertEqual(result, "20mm")
    }

    func testFormatIntNil() throws {
        let result = WatchFieldFormatters.formatInt(nil, unit: "mm")
        XCTAssertNil(result, "Should return nil for nil value")
    }

    // MARK: - Currency Formatting Tests

    func testFormatCurrencyWithCode() throws {
        let amount = Decimal(1_250.50)
        let result = WatchFieldFormatters.formatCurrency(amount, currencyCode: "USD")
        XCTAssertNotNil(result, "Should format currency")
        XCTAssertTrue(result?.contains("USD") ?? false, "Should include currency code")
        XCTAssertTrue(result?.contains("1") ?? false, "Should include amount")
    }

    func testFormatCurrencyNilAmount() throws {
        let result = WatchFieldFormatters.formatCurrency(nil, currencyCode: "USD")
        XCTAssertNil(result, "Should return nil for nil amount")
    }

    func testFormatCurrencyWithoutCode() throws {
        let amount = Decimal(1_250)
        let result = WatchFieldFormatters.formatCurrency(amount, currencyCode: nil)
        XCTAssertNotNil(result, "Should format without currency code")
        XCTAssertTrue(result?.contains("1") ?? false, "Should include amount")
    }

    func testFormatCurrencyEmptyCode() throws {
        let amount = Decimal(500)
        let result = WatchFieldFormatters.formatCurrency(amount, currencyCode: "")
        XCTAssertNotNil(result, "Should format with empty currency code")
    }

    // MARK: - Enum Formatting Tests

    func testFormatEnumValueSnakeCase() throws {
        enum TestEnum: String {
            case stainlessSteel = "stainless_steel"
        }
        let result = WatchFieldFormatters.formatEnumValue(TestEnum.stainlessSteel)
        XCTAssertEqual(result, "Stainless Steel", "Should convert snake_case to Title Case")
    }

    func testFormatEnumValueCamelCase() throws {
        enum TestEnum: String {
            case screwDown = "screwDown"
        }
        let result = WatchFieldFormatters.formatEnumValue(TestEnum.screwDown)
        XCTAssertEqual(result, "Screw Down", "Should convert camelCase to Title Case")
    }

    func testFormatEnumValueNil() throws {
        enum TestEnum: String {
            case test
        }
        let nilValue: TestEnum? = nil
        let result = WatchFieldFormatters.formatEnumValue(nilValue)
        XCTAssertNil(result, "Should return nil for nil value")
    }

    // MARK: - Specialized Formatters Tests

    func testFormatFrequency() throws {
        let result = WatchFieldFormatters.formatFrequency(28_800)
        XCTAssertEqual(result, "28,800 vph", "Should format frequency with comma separator")
    }

    func testFormatFrequencyNil() throws {
        let result = WatchFieldFormatters.formatFrequency(nil)
        XCTAssertNil(result, "Should return nil for nil value")
    }

    func testFormatPowerReserveHours() throws {
        let result = WatchFieldFormatters.formatPowerReserve(38)
        XCTAssertEqual(result, "38 hours")
    }

    func testFormatPowerReserveDays() throws {
        let result = WatchFieldFormatters.formatPowerReserve(72)
        XCTAssertEqual(result, "3 days", "Should convert 72 hours to 3 days")
    }

    func testFormatPowerReserveSingleHour() throws {
        let result = WatchFieldFormatters.formatPowerReserve(1)
        XCTAssertEqual(result, "1 hour", "Should use singular for 1 hour")
    }

    func testFormatPowerReserveNil() throws {
        let result = WatchFieldFormatters.formatPowerReserve(nil)
        XCTAssertNil(result, "Should return nil for nil value")
    }

    func testFormatAccuracyPositive() throws {
        let result = WatchFieldFormatters.formatAccuracy(2.5)
        XCTAssertEqual(result, "±2.5 sec/day")
    }

    func testFormatAccuracyNegative() throws {
        let result = WatchFieldFormatters.formatAccuracy(-4)
        XCTAssertEqual(result, "-4 sec/day")
    }

    func testFormatAccuracyNil() throws {
        let result = WatchFieldFormatters.formatAccuracy(nil)
        XCTAssertNil(result, "Should return nil for nil value")
    }

    func testFormatWaterResistance() throws {
        let result = WatchFieldFormatters.formatWaterResistance(100)
        XCTAssertEqual(result, "100m")
    }

    func testFormatWaterResistanceNil() throws {
        let result = WatchFieldFormatters.formatWaterResistance(nil)
        XCTAssertNil(result, "Should return nil for nil value")
    }

    func testFormatBoxPapersFullSet() throws {
        let result = WatchFieldFormatters.formatBoxPapers(.fullSet)
        XCTAssertEqual(result, "Full Set")
    }

    func testFormatBoxPapersBoxOnly() throws {
        let result = WatchFieldFormatters.formatBoxPapers(.boxOnly)
        XCTAssertEqual(result, "Box Only")
    }

    func testFormatBoxPapersPapersOnly() throws {
        let result = WatchFieldFormatters.formatBoxPapers(.papersOnly)
        XCTAssertEqual(result, "Papers Only")
    }

    func testFormatBoxPapersWatchOnly() throws {
        let result = WatchFieldFormatters.formatBoxPapers(.watchOnly)
        XCTAssertEqual(result, "Watch Only")
    }

    func testFormatBoxPapersPartial() throws {
        let result = WatchFieldFormatters.formatBoxPapers(.partial)
        XCTAssertEqual(result, "Partial")
    }

    func testFormatBoxPapersOther() throws {
        let result = WatchFieldFormatters.formatBoxPapers(.other("custom"))
        XCTAssertEqual(result, "Custom")
    }

    func testFormatBoxPapersNil() throws {
        let result = WatchFieldFormatters.formatBoxPapers(nil)
        XCTAssertNil(result, "Should return nil for nil value")
    }

    // MARK: - Group Visibility Tests

    func testHasCoreDetailsWithData() throws {
        let watch = WatchV2(
            manufacturer: "Rolex",
            modelName: "Submariner",
            serialNumber: "ABC123"
        )
        XCTAssertTrue(WatchFieldFormatters.hasCoreDetails(watch), "Should return true when serial number is present")
    }

    func testHasCoreDetailsWithoutData() throws {
        let watch = WatchV2(
            manufacturer: "Rolex",
            modelName: "Submariner"
        )
        XCTAssertFalse(WatchFieldFormatters.hasCoreDetails(watch), "Should return false when no optional fields are present")
    }

    func testHasCoreDetailsWithTags() throws {
        let watch = WatchV2(
            manufacturer: "Rolex",
            modelName: "Submariner",
            tags: ["Diver", "Sport"]
        )
        XCTAssertTrue(WatchFieldFormatters.hasCoreDetails(watch), "Should return true when tags are present")
    }

    func testHasCaseSpecsWithData() throws {
        let watchCase = WatchCase(material: .steel, diameterMM: 40)
        XCTAssertTrue(WatchFieldFormatters.hasCaseSpecs(watchCase), "Should return true when case fields are present")
    }

    func testHasCaseSpecsWithoutData() throws {
        let watchCase = WatchCase()
        XCTAssertFalse(WatchFieldFormatters.hasCaseSpecs(watchCase), "Should return false when no fields are present")
    }

    func testHasDialDetailsWithData() throws {
        let dial = WatchDial(color: "Black", finish: .matte)
        XCTAssertTrue(WatchFieldFormatters.hasDialDetails(dial), "Should return true when dial fields are present")
    }

    func testHasDialDetailsWithoutData() throws {
        let dial = WatchDial()
        XCTAssertFalse(WatchFieldFormatters.hasDialDetails(dial), "Should return false when no fields are present")
    }

    func testHasDialDetailsWithComplications() throws {
        let dial = WatchDial(complications: ["Date", "Chronograph"])
        XCTAssertTrue(WatchFieldFormatters.hasDialDetails(dial), "Should return true when complications are present")
    }

    func testHasCrystalDetailsWithData() throws {
        let crystal = WatchCrystal(material: .sapphire)
        XCTAssertTrue(WatchFieldFormatters.hasCrystalDetails(crystal), "Should return true when crystal fields are present")
    }

    func testHasCrystalDetailsWithoutData() throws {
        let crystal = WatchCrystal()
        XCTAssertFalse(WatchFieldFormatters.hasCrystalDetails(crystal), "Should return false when no fields are present")
    }

    func testHasMovementSpecsWithData() throws {
        let movement = MovementSpec(type: .automatic, caliber: "ETA 2824-2")
        XCTAssertTrue(WatchFieldFormatters.hasMovementSpecs(movement), "Should return true when movement fields are present")
    }

    func testHasMovementSpecsWithoutData() throws {
        let movement = MovementSpec()
        XCTAssertFalse(WatchFieldFormatters.hasMovementSpecs(movement), "Should return false when no fields are present")
    }

    func testHasWaterResistanceWithData() throws {
        let water = WatchWater(waterResistanceM: 100)
        XCTAssertTrue(WatchFieldFormatters.hasWaterResistance(water), "Should return true when water resistance is present")
    }

    func testHasWaterResistanceWithCrownGuard() throws {
        let water = WatchWater(crownGuard: true)
        XCTAssertTrue(WatchFieldFormatters.hasWaterResistance(water), "Should return true when crown guard is true")
    }

    func testHasWaterResistanceWithoutData() throws {
        let water = WatchWater()
        XCTAssertFalse(WatchFieldFormatters.hasWaterResistance(water), "Should return false when no fields are present")
    }

    func testHasStrapDetailsWithData() throws {
        let strap = WatchStrapCurrent(type: .bracelet, material: "Stainless Steel")
        XCTAssertTrue(WatchFieldFormatters.hasStrapDetails(strap), "Should return true when strap fields are present")
    }

    func testHasStrapDetailsWithoutData() throws {
        let strap = WatchStrapCurrent()
        XCTAssertFalse(WatchFieldFormatters.hasStrapDetails(strap), "Should return false when no fields are present")
    }

    func testHasOwnershipInfoWithData() throws {
        let ownership = WatchOwnership(dateAcquired: Date(), purchasedFrom: "Authorized Dealer")
        XCTAssertTrue(WatchFieldFormatters.hasOwnershipInfo(ownership), "Should return true when ownership fields are present")
    }

    func testHasOwnershipInfoWithoutData() throws {
        let ownership = WatchOwnership()
        XCTAssertFalse(WatchFieldFormatters.hasOwnershipInfo(ownership), "Should return false when no fields are present")
    }

    // MARK: - Edge Cases

    func testFormatMeasurementZero() throws {
        let result = WatchFieldFormatters.formatMeasurement(0, unit: "mm")
        XCTAssertEqual(result, "0mm", "Should handle zero value")
    }

    func testFormatCurrencyZeroAmount() throws {
        let result = WatchFieldFormatters.formatCurrency(Decimal(0), currencyCode: "USD")
        XCTAssertNotNil(result, "Should format zero amount")
    }

    func testFormatFrequencyLargeNumber() throws {
        let result = WatchFieldFormatters.formatFrequency(36_000)
        XCTAssertEqual(result, "36,000 vph", "Should format large numbers with comma")
    }

    func testFormatPowerReserveNonMultipleOf24() throws {
        let result = WatchFieldFormatters.formatPowerReserve(50)
        XCTAssertEqual(result, "50 hours", "Should use hours for non-multiples of 24")
    }

    func testFormatMeasurementMaxDecimals() throws {
        let result = WatchFieldFormatters.formatMeasurement(40.567, unit: "mm", maxDecimals: 2)
        XCTAssertEqual(result, "40.57mm", "Should respect maxDecimals parameter")
    }
}
