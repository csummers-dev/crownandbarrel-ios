import Foundation
import CoreData

/// Manages the Core Data stack and provides a programmatic data model.
/// - What: Owns the `NSPersistentContainer`, view context, save semantics, and model description.
/// - Why: Programmatic model avoids .xcdatamodeld and simplifies in-memory testing and CI.
/// - How: Builds entities and relationships in code, sets a merge policy to prefer incoming changes.
public final class CoreDataStack {
    public static let shared = CoreDataStack()

    public let persistentContainer: NSPersistentContainer

    public var viewContext: NSManagedObjectContext { persistentContainer.viewContext }

    /// Creates the stack with an on-disk store in the app's default directory.
    /// - Parameter inMemory: If true, configures an in-memory store (useful for tests).
    public init(inMemory: Bool = false) {
        let model = CoreDataStack.buildModel()
        persistentContainer = NSPersistentContainer(name: "GoodWatch", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }

        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        viewContext.automaticallyMergesChangesFromParent = true
    }

    /// Saves the view context if there are changes.
    /// - Note: No-op if there are no changes; throws on save failure.
    public func saveContext() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }

    /// Programmatically builds the data model to avoid needing an .xcdatamodeld file.
    /// - Design:
    ///   - `CDWatch` holds denormalized fields (`timesWorn`, `lastWornDate`) to allow efficient sorting.
    ///   - `CDWearEntry` has a to-one relationship to `CDWatch` and is unique per day at repository level.
    ///   - `CDAppSettings` stores simple key-value preferences.
    private static func buildModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // MARK: - Watch entity
        let watchEntity = NSEntityDescription()
        watchEntity.name = "CDWatch"
        watchEntity.managedObjectClassName = NSStringFromClass(CDWatch.self)

        var watchProperties: [NSPropertyDescription] = []

        watchProperties.append(makeUUIDAttribute(name: "id", isOptional: false))
        watchProperties.append(makeStringAttribute(name: "manufacturer"))
        watchProperties.append(makeStringAttribute(name: "model", optional: true))
        watchProperties.append(makeStringAttribute(name: "category", optional: true))
        watchProperties.append(makeStringAttribute(name: "serialNumber", optional: true))
        watchProperties.append(makeStringAttribute(name: "referenceNumber", optional: true))
        watchProperties.append(makeStringAttribute(name: "movement", optional: true))
        watchProperties.append(makeBooleanAttribute(name: "isFavorite"))
        watchProperties.append(makeDateAttribute(name: "purchaseDate", optional: true))
        watchProperties.append(makeInteger16Attribute(name: "serviceIntervalMonths", optional: true))
        watchProperties.append(makeDateAttribute(name: "warrantyExpirationDate", optional: true))
        watchProperties.append(makeDateAttribute(name: "lastServiceDate", optional: true))
        watchProperties.append(makeDecimalAttribute(name: "purchasePrice", optional: true))
        watchProperties.append(makeDecimalAttribute(name: "currentValue", optional: true))
        watchProperties.append(makeStringAttribute(name: "notes", optional: true))
        watchProperties.append(makeStringAttribute(name: "imageAssetId", optional: true))
        watchProperties.append(makeInteger32Attribute(name: "timesWorn"))
        watchProperties.append(makeDateAttribute(name: "lastWornDate", optional: true))
        watchProperties.append(makeDateAttribute(name: "saleDate", optional: true))
        watchProperties.append(makeDecimalAttribute(name: "salePrice", optional: true))
        watchProperties.append(makeDateAttribute(name: "createdAt"))
        watchProperties.append(makeDateAttribute(name: "updatedAt"))

        // Relationship: wearEntries (to-many) will be added after wear entity defined

        watchEntity.properties = watchProperties

        // MARK: - WearEntry entity
        let wearEntity = NSEntityDescription()
        wearEntity.name = "CDWearEntry"
        wearEntity.managedObjectClassName = NSStringFromClass(CDWearEntry.self)

        var wearProperties: [NSPropertyDescription] = []
        wearProperties.append(makeUUIDAttribute(name: "id", isOptional: false))
        wearProperties.append(makeDateAttribute(name: "date"))
        // Relationship to watch (to-one)
        let wearToWatch = NSRelationshipDescription()
        wearToWatch.name = "watch"
        wearToWatch.destinationEntity = watchEntity
        wearToWatch.minCount = 1
        wearToWatch.maxCount = 1
        wearToWatch.deleteRule = .nullifyDeleteRule
        wearProperties.append(wearToWatch)
        wearEntity.properties = wearProperties

        // Add inverse relationship: watch.wearEntries (to-many)
        let watchToWear = NSRelationshipDescription()
        watchToWear.name = "wearEntries"
        watchToWear.destinationEntity = wearEntity
        watchToWear.minCount = 0
        watchToWear.maxCount = 0 // to-many
        watchToWear.deleteRule = .cascadeDeleteRule
        wearToWatch.inverseRelationship = watchToWear
        watchToWear.inverseRelationship = wearToWatch
        watchEntity.properties.append(watchToWear)

        // MARK: - AppSettings entity
        let settingsEntity = NSEntityDescription()
        settingsEntity.name = "CDAppSettings"
        settingsEntity.managedObjectClassName = NSStringFromClass(CDAppSettings.self)
        let themeAttr = makeStringAttribute(name: "themePreference", optional: true)
        settingsEntity.properties = [themeAttr]

        model.entities = [watchEntity, wearEntity, settingsEntity]
        return model
    }
}

// MARK: - Managed Object Subclasses

@objc(CDWatch)
final class CDWatch: NSManagedObject {}

@objc(CDWearEntry)
final class CDWearEntry: NSManagedObject {}

@objc(CDAppSettings)
final class CDAppSettings: NSManagedObject {}

// MARK: - Attribute helpers

private func makeStringAttribute(name: String, optional: Bool = false) -> NSAttributeDescription {
    let attr = NSAttributeDescription()
    attr.name = name
    attr.attributeType = .stringAttributeType
    attr.isOptional = optional
    return attr
}

private func makeUUIDAttribute(name: String, isOptional: Bool) -> NSAttributeDescription {
    let attr = NSAttributeDescription()
    attr.name = name
    attr.attributeType = .UUIDAttributeType
    attr.isOptional = isOptional
    return attr
}

private func makeBooleanAttribute(name: String) -> NSAttributeDescription {
    let attr = NSAttributeDescription()
    attr.name = name
    attr.attributeType = .booleanAttributeType
    attr.isOptional = false
    return attr
}

private func makeInteger16Attribute(name: String, optional: Bool = false) -> NSAttributeDescription {
    let attr = NSAttributeDescription()
    attr.name = name
    attr.attributeType = .integer16AttributeType
    attr.isOptional = optional
    return attr
}

private func makeInteger32Attribute(name: String, optional: Bool = false) -> NSAttributeDescription {
    let attr = NSAttributeDescription()
    attr.name = name
    attr.attributeType = .integer32AttributeType
    attr.isOptional = optional
    return attr
}

private func makeDateAttribute(name: String, optional: Bool = false) -> NSAttributeDescription {
    let attr = NSAttributeDescription()
    attr.name = name
    attr.attributeType = .dateAttributeType
    attr.isOptional = optional
    return attr
}

private func makeDecimalAttribute(name: String, optional: Bool = false) -> NSAttributeDescription {
    let attr = NSAttributeDescription()
    attr.name = name
    attr.attributeType = .decimalAttributeType
    attr.isOptional = optional
    return attr
}


