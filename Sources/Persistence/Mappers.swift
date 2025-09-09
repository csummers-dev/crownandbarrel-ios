import Foundation
import CoreData

/// Maps between domain models and Core Data managed objects.
/// - What: Bridges the gap between strongly-typed domain structs and dynamic Core Data entities.
/// - Why: Keeps persistence concerns isolated from the domain layer.
/// - How: Uses keyed `setValue` / `value(forKey:)` to avoid tight coupling to generated subclasses.
enum Mappers {
    /// Applies values from a domain `Watch` to a managed `CDWatch` object.
    /// - Note: Handles optional numeric conversions and denormalized counters.
    static func update(_ cd: CDWatch, from watch: Watch) {
        cd.setValue(watch.id, forKey: "id")
        cd.setValue(watch.manufacturer, forKey: "manufacturer")
        cd.setValue(watch.model, forKey: "model")
        cd.setValue(watch.category?.rawValue, forKey: "category")
        cd.setValue(watch.serialNumber, forKey: "serialNumber")
        cd.setValue(watch.referenceNumber, forKey: "referenceNumber")
        cd.setValue(watch.movement?.rawValue, forKey: "movement")
        cd.setValue(watch.isFavorite, forKey: "isFavorite")
        cd.setValue(watch.purchaseDate, forKey: "purchaseDate")
        cd.setValue(watch.serviceIntervalMonths.map { Int16($0) }, forKey: "serviceIntervalMonths")
        cd.setValue(watch.warrantyExpirationDate, forKey: "warrantyExpirationDate")
        cd.setValue(watch.lastServiceDate, forKey: "lastServiceDate")
        cd.setValue(watch.purchasePrice.map { NSDecimalNumber(decimal: $0) }, forKey: "purchasePrice")
        cd.setValue(watch.currentValue.map { NSDecimalNumber(decimal: $0) }, forKey: "currentValue")
        cd.setValue(watch.notes, forKey: "notes")
        cd.setValue(watch.imageAssetId, forKey: "imageAssetId")
        cd.setValue(Int32(watch.timesWorn), forKey: "timesWorn")
        cd.setValue(watch.lastWornDate, forKey: "lastWornDate")
        cd.setValue(watch.saleDate, forKey: "saleDate")
        cd.setValue(watch.salePrice.map { NSDecimalNumber(decimal: $0) }, forKey: "salePrice")
        cd.setValue(watch.createdAt, forKey: "createdAt")
        cd.setValue(watch.updatedAt, forKey: "updatedAt")
    }

    /// Builds a domain `Watch` from a managed `CDWatch`.
    static func toDomain(_ cd: CDWatch) -> Watch {
        let purchasePrice = cd.value(forKey: "purchasePrice") as? NSDecimalNumber
        let currentValue = cd.value(forKey: "currentValue") as? NSDecimalNumber
        let salePrice = cd.value(forKey: "salePrice") as? NSDecimalNumber
        let serviceInterval = cd.value(forKey: "serviceIntervalMonths") as? Int16

        return Watch(
            id: cd.value(forKey: "id") as? UUID ?? UUID(),
            manufacturer: cd.value(forKey: "manufacturer") as? String ?? "",
            model: cd.value(forKey: "model") as? String,
            category: (cd.value(forKey: "category") as? String).flatMap(WatchCategory.init(rawValue:)),
            serialNumber: cd.value(forKey: "serialNumber") as? String,
            referenceNumber: cd.value(forKey: "referenceNumber") as? String,
            movement: (cd.value(forKey: "movement") as? String).flatMap(WatchMovement.init(rawValue:)),
            isFavorite: cd.value(forKey: "isFavorite") as? Bool ?? false,
            purchaseDate: cd.value(forKey: "purchaseDate") as? Date,
            serviceIntervalMonths: serviceInterval.map(Int.init),
            warrantyExpirationDate: cd.value(forKey: "warrantyExpirationDate") as? Date,
            lastServiceDate: cd.value(forKey: "lastServiceDate") as? Date,
            purchasePrice: purchasePrice?.decimalValue,
            currentValue: currentValue?.decimalValue,
            notes: cd.value(forKey: "notes") as? String,
            imageAssetId: cd.value(forKey: "imageAssetId") as? String,
            timesWorn: Int(cd.value(forKey: "timesWorn") as? Int32 ?? 0),
            lastWornDate: cd.value(forKey: "lastWornDate") as? Date,
            saleDate: cd.value(forKey: "saleDate") as? Date,
            salePrice: salePrice?.decimalValue,
            createdAt: cd.value(forKey: "createdAt") as? Date ?? Date(),
            updatedAt: cd.value(forKey: "updatedAt") as? Date ?? Date()
        )
    }

    /// Builds a domain `WearEntry` from a managed `CDWearEntry`.
    static func toDomain(_ cd: CDWearEntry) -> WearEntry {
        return WearEntry(
            id: cd.value(forKey: "id") as? UUID ?? UUID(),
            watchId: (cd.value(forKey: "watch") as? CDWatch).flatMap { $0.value(forKey: "id") as? UUID } ?? UUID(),
            date: cd.value(forKey: "date") as? Date ?? Date()
        )
    }
}


