import Foundation

public enum WatchValidation {
    // MARK: - Tag Slugging

    public static func slugifyTag(_ input: String) -> String {
        let lower = input.lowercased()
        let allowed = lower.unicodeScalars.map { scalar -> Character in
            if CharacterSet.alphanumerics.contains(scalar) { return Character(scalar) }
            return "-"
        }
        let collapsed = String(allowed).replacingOccurrences(of: "-+", with: "-", options: .regularExpression)
        return collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    public static func normalizeTags(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for t in tags {
            let slug = slugifyTag(t)
            guard !slug.isEmpty else { continue }
            if !seen.contains(slug) {
                seen.insert(slug)
                result.append(slug)
            }
        }
        return result
    }

    // MARK: - Numeric Ranges

    public static func validateProductionYear(_ year: Int?) -> Bool {
        guard let year else { return true }
        let current = Calendar.current.component(.year, from: Date())
        return (1900...current).contains(year)
    }

    public static func validateCaseDimensions(diameter: Double?, thickness: Double?, lugToLug: Double?, lugWidth: Int?) -> Bool {
        let okDiameter = diameter.map { (16.0...60.0).contains($0) } ?? true
        let okThickness = thickness.map { (0.0...25.0).contains($0) } ?? true
        let okL2L = lugToLug.map { (0.0...70.0).contains($0) } ?? true
        let okLugWidth = lugWidth.map { (6...30).contains($0) } ?? true
        return okDiameter && okThickness && okL2L && okLugWidth
    }

    public static func validateMovement(powerReserveHours: Double?, frequencyVPH: Int?, jewelCount: Int?, accuracyPPD: Double?) -> Bool {
        let okPR = powerReserveHours.map { (0.0...2000.0).contains($0) } ?? true
        let okVPH = frequencyVPH.map { $0 == 0 || [18000, 19800, 21600, 24000, 25200, 28800, 36000].contains($0) } ?? true
        let okJewel = jewelCount.map { (0...60).contains($0) } ?? true
        let _ = accuracyPPD // any Double allowed; represents +/- seconds per day
        return okPR && okVPH && okJewel
    }

    public static func validateWaterResistance(_ meters: Int?) -> Bool {
        guard let meters else { return true }
        let allowed: Set<Int> = [0, 30, 50, 100, 200, 300, 600, 1000]
        return allowed.contains(meters) || meters > 1000
    }

    // MARK: - Photos

    public static func enforcePrimaryPhotoInvariant(_ photos: [WatchPhoto]) -> [WatchPhoto] {
        if photos.isEmpty { return photos }
        // If none marked, set the first as primary
        if !photos.contains(where: { $0.isPrimary }) {
            var copy = photos
            copy.indices.forEach { idx in copy[idx].isPrimary = (idx == 0) }
            return copy
        }
        // If multiple marked, keep the first marked as primary, unset the rest
        var found = false
        var adjusted: [WatchPhoto] = []
        for p in photos {
            if p.isPrimary && !found {
                adjusted.append(p)
                found = true
            } else if p.isPrimary && found {
                var q = p
                q.isPrimary = false
                adjusted.append(q)
            } else {
                adjusted.append(p)
            }
        }
        return adjusted
    }

    public static func validatePhotoLimit(_ photos: [WatchPhoto]) -> Bool {
        return photos.count <= 10
    }

    // MARK: - Aggregate validation

    public static func validate(_ watch: WatchV2) -> [String] {
        var errors: [String] = []

        if watch.manufacturer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("manufacturer is required")
        }
        if watch.modelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("model_name is required")
        }
        if !validateProductionYear(watch.productionYear) {
            errors.append("production_year must be 1900..current year")
        }
        if !validateCaseDimensions(diameter: watch.watchCase.diameterMM,
                                   thickness: watch.watchCase.thicknessMM,
                                   lugToLug: watch.watchCase.lugToLugMM,
                                   lugWidth: watch.watchCase.lugWidthMM) {
            errors.append("case dimensions out of allowed ranges")
        }
        if !validateMovement(powerReserveHours: watch.movement.powerReserveHours,
                              frequencyVPH: watch.movement.frequencyVPH,
                              jewelCount: watch.movement.jewelCount,
                              accuracyPPD: watch.movement.accuracySpecPPD) {
            errors.append("movement fields out of allowed ranges")
        }
        if !validateWaterResistance(watch.water.waterResistanceM) {
            errors.append("invalid water_resistance_m")
        }
        if !validatePhotoLimit(watch.photos) {
            errors.append("max 10 photos per watch")
        }
        return errors
    }
}


