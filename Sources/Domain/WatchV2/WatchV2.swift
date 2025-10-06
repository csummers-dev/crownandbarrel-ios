import Foundation

/// New watch domain model (greenfield schema) with nested value objects and child collections.
public struct WatchV2: Identifiable, Hashable, Codable, Sendable {
    // Metadata
    public let id: UUID
    public var createdAt: Date
    public var updatedAt: Date

    // Core identity
    public var manufacturer: String
    public var line: String?
    public var modelName: String
    public var referenceNumber: String?
    public var nickname: String?

    // Additional fields
    public var serialNumber: String?
    public var productionYear: Int?
    public var countryOfOrigin: String?
    public var limitedEditionNumber: String?
    public var notes: String?
    public var tags: [String]

    // Nested value objects
    public var watchCase: WatchCase
    public var dial: WatchDial
    public var crystal: WatchCrystal
    public var movement: MovementSpec
    public var water: WatchWater
    public var strapCurrent: WatchStrapCurrent
    public var ownership: WatchOwnership

    // Child collections
    public var photos: [WatchPhoto]
    public var serviceHistory: [ServiceHistoryEntry]
    public var valuations: [ValuationEntry]
    public var straps: [StrapInventoryItem]

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        manufacturer: String,
        line: String? = nil,
        modelName: String,
        referenceNumber: String? = nil,
        nickname: String? = nil,
        serialNumber: String? = nil,
        productionYear: Int? = nil,
        countryOfOrigin: String? = nil,
        limitedEditionNumber: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        watchCase: WatchCase = WatchCase(),
        dial: WatchDial = WatchDial(),
        crystal: WatchCrystal = WatchCrystal(),
        movement: MovementSpec = MovementSpec(),
        water: WatchWater = WatchWater(),
        strapCurrent: WatchStrapCurrent = WatchStrapCurrent(),
        ownership: WatchOwnership = WatchOwnership(),
        photos: [WatchPhoto] = [],
        serviceHistory: [ServiceHistoryEntry] = [],
        valuations: [ValuationEntry] = [],
        straps: [StrapInventoryItem] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.manufacturer = manufacturer
        self.line = line
        self.modelName = modelName
        self.referenceNumber = referenceNumber
        self.nickname = nickname
        self.serialNumber = serialNumber
        self.productionYear = productionYear
        self.countryOfOrigin = countryOfOrigin
        self.limitedEditionNumber = limitedEditionNumber
        self.notes = notes
        self.tags = tags
        self.watchCase = watchCase
        self.dial = dial
        self.crystal = crystal
        self.movement = movement
        self.water = water
        self.strapCurrent = strapCurrent
        self.ownership = ownership
        self.photos = photos
        self.serviceHistory = serviceHistory
        self.valuations = valuations
        self.straps = straps
    }
}


