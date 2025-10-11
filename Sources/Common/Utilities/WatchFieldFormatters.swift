import Foundation

/// Utilities for formatting and visibility checking of watch fields for detail view display.
/// - What: Provides formatters and visibility helpers for all WatchV2 properties and nested objects.
/// - Why: Centralizes field formatting logic per PRD requirements (smart decimal display, currency, etc.).
/// - How: Static methods for formatting and group visibility checks.
public enum WatchFieldFormatters {
    // MARK: - Numeric Formatting

    /// Formats a measurement value with smart decimal precision.
    /// - Shows no decimals for whole numbers (40mm)
    /// - Shows decimals for fractional values (40.5mm)
    /// - Parameters:
    ///   - value: The numeric value to format
    ///   - unit: Optional unit suffix (e.g., "mm", "m")
    ///   - maxDecimals: Maximum decimal places to show (default: 1)
    /// - Returns: Formatted string or nil if value is nil
    public static func formatMeasurement(
        _ value: Double?,
        unit: String = "",
        maxDecimals: Int = 1
    ) -> String? {
        guard let value = value else { return nil }

        // Check if value is a whole number
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            let formatted = String(format: "%.0f", value)
            return unit.isEmpty ? formatted : "\(formatted)\(unit)"
        } else {
            let formatted = String(format: "%.\(maxDecimals)f", value)
            return unit.isEmpty ? formatted : "\(formatted)\(unit)"
        }
    }

    /// Formats an integer value with optional unit.
    /// - Parameters:
    ///   - value: The integer value
    ///   - unit: Optional unit suffix
    /// - Returns: Formatted string or nil if value is nil
    public static func formatInt(_ value: Int?, unit: String = "") -> String? {
        guard let value = value else { return nil }
        return unit.isEmpty ? "\(value)" : "\(value)\(unit)"
    }

    // MARK: - Currency Formatting

    /// Formats a currency amount with proper locale formatting.
    /// - Parameters:
    ///   - amount: The decimal amount
    ///   - currencyCode: ISO currency code (e.g., "USD", "EUR")
    /// - Returns: Formatted currency string (e.g., "$1,250 USD") or nil if amount is nil
    public static func formatCurrency(
        _ amount: Decimal?,
        currencyCode: String?
    ) -> String? {
        guard let amount = amount else { return nil }
        guard let currencyCode = currencyCode, !currencyCode.isEmpty else {
            // Fallback to just the number if no currency code
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            return formatter.string(from: NSDecimalNumber(decimal: amount))
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale.current

        if let formatted = formatter.string(from: NSDecimalNumber(decimal: amount)) {
            // Append currency code for clarity (e.g., "$1,250 USD")
            return "\(formatted) \(currencyCode)"
        }

        return nil
    }

    // MARK: - Enum Formatting

    /// Formats an enum raw value into a human-readable string.
    /// - Converts snake_case to Title Case
    /// - Converts camelCase to Title Case
    /// - Example: "stainless_steel" -> "Stainless Steel", "screwDown" -> "Screw Down"
    public static func formatEnumValue<T: RawRepresentable>(
        _ value: T?
    ) -> String? where T.RawValue == String {
        guard let value = value else { return nil }
        let rawValue = value.rawValue

        // Replace underscores with spaces and capitalize
        let withSpaces = rawValue.replacingOccurrences(of: "_", with: " ")

        // Handle camelCase by inserting spaces before capitals
        var result = ""
        for (index, char) in withSpaces.enumerated() {
            if char.isUppercase && index > 0 {
                result += " "
            }
            result.append(char)
        }

        // Capitalize each word
        return result.capitalized
    }

    // MARK: - Group Visibility Helpers

    /// Checks if the core details group has any populated fields.
    /// Fields: serial number, production year, country, limited edition, notes, tags
    public static func hasCoreDetails(_ watch: WatchV2) -> Bool {
        watch.serialNumber != nil ||
               watch.productionYear != nil ||
               watch.countryOfOrigin != nil ||
               watch.limitedEditionNumber != nil ||
               watch.notes != nil ||
               !watch.tags.isEmpty
    }

    /// Checks if the case specifications group has any populated fields.
    public static func hasCaseSpecs(_ watchCase: WatchCase) -> Bool {
        watchCase.material != nil ||
               watchCase.finish != nil ||
               watchCase.shape != nil ||
               watchCase.diameterMM != nil ||
               watchCase.thicknessMM != nil ||
               watchCase.lugToLugMM != nil ||
               watchCase.lugWidthMM != nil ||
               watchCase.bezelType != nil ||
               watchCase.bezelMaterial != nil ||
               watchCase.casebackType != nil ||
               watchCase.casebackMaterial != nil
    }

    /// Checks if the dial details group has any populated fields.
    public static func hasDialDetails(_ dial: WatchDial) -> Bool {
        dial.color != nil ||
               dial.finish != nil ||
               dial.indicesStyle != nil ||
               dial.indicesMaterial != nil ||
               dial.handsStyle != nil ||
               dial.handsMaterial != nil ||
               dial.lumeType != nil ||
               !dial.complications.isEmpty
    }

    /// Checks if the crystal details group has any populated fields.
    public static func hasCrystalDetails(_ crystal: WatchCrystal) -> Bool {
        crystal.material != nil ||
               crystal.shapeProfile != nil ||
               crystal.arCoating != nil
    }

    /// Checks if the movement specifications group has any populated fields.
    public static func hasMovementSpecs(_ movement: MovementSpec) -> Bool {
        movement.type != nil ||
               movement.caliber != nil ||
               movement.powerReserveHours != nil ||
               movement.frequencyVPH != nil ||
               movement.jewelCount != nil ||
               movement.accuracySpecPPD != nil ||
               movement.chronometerCert != nil
    }

    /// Checks if the water resistance group has any populated fields.
    public static func hasWaterResistance(_ water: WatchWater) -> Bool {
        water.waterResistanceM != nil ||
               water.crownType != nil ||
               water.crownGuard == true
    }

    /// Checks if the strap/bracelet details group has any populated fields.
    public static func hasStrapDetails(_ strap: WatchStrapCurrent) -> Bool {
        strap.type != nil ||
               strap.material != nil ||
               strap.color != nil ||
               strap.endLinks != nil ||
               strap.claspType != nil ||
               strap.braceletLinkCount != nil ||
               strap.quickRelease == true
    }

    /// Checks if the ownership information group has any populated fields.
    public static func hasOwnershipInfo(_ ownership: WatchOwnership) -> Bool {
        ownership.dateAcquired != nil ||
               ownership.purchasedFrom != nil ||
               ownership.purchasePriceAmount != nil ||
               ownership.condition != nil ||
               ownership.boxPapers != nil ||
               ownership.currentEstimatedValueAmount != nil ||
               ownership.insuranceProvider != nil ||
               ownership.insurancePolicyNumber != nil ||
               ownership.insuranceRenewalDate != nil
    }

    // MARK: - Specialized Formatters

    /// Formats frequency in VPH (vibrations per hour) to a readable format.
    /// Example: 28800 -> "28,800 vph"
    public static func formatFrequency(_ vph: Int?) -> String? {
        guard let vph = vph else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let formatted = formatter.string(from: NSNumber(value: vph)) {
            return "\(formatted) vph"
        }
        return "\(vph) vph"
    }

    /// Formats power reserve hours.
    /// Example: 38 -> "38 hours", 72 -> "72 hours" (or "3 days")
    public static func formatPowerReserve(_ hours: Double?) -> String? {
        guard let hours = hours else { return nil }

        if hours >= 48 && hours.truncatingRemainder(dividingBy: 24) == 0 {
            let days = Int(hours / 24)
            return "\(days) day\(days == 1 ? "" : "s")"
        }

        let hoursInt = Int(hours)
        return "\(hoursInt) hour\(hoursInt == 1 ? "" : "s")"
    }

    /// Formats accuracy specification in PPD (per day).
    /// Example: -4 -> "-4/+6 sec/day" or 2.5 -> "±2.5 sec/day"
    public static func formatAccuracy(_ ppd: Double?) -> String? {
        guard let ppd = ppd else { return nil }
        if ppd >= 0 {
            return "±\(formatMeasurement(ppd, maxDecimals: 1) ?? "0") sec/day"
        } else {
            return "\(formatMeasurement(ppd, maxDecimals: 1) ?? "0") sec/day"
        }
    }

    /// Formats water resistance in meters.
    /// Example: 100 -> "100m", 200 -> "200m"
    public static func formatWaterResistance(_ meters: Int?) -> String? {
        guard let meters = meters else { return nil }
        return "\(meters)m"
    }

    /// Formats box and papers status.
    public static func formatBoxPapers(_ boxPapers: BoxPapers?) -> String? {
        guard let boxPapers = boxPapers else { return nil }
        switch boxPapers {
        case .fullSet:
            return "Full Set"
        case .watchOnly:
            return "Watch Only"
        case .partial:
            return "Partial"
        case .boxOnly:
            return "Box Only"
        case .papersOnly:
            return "Papers Only"
        case .other(let value):
            return value.capitalized
        }
    }
}
