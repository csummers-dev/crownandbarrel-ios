import Foundation

/// Domain model representing a single watch in the collection.
public struct Watch: Identifiable, Hashable, Codable {
    public let id: UUID

    // Required
    public var manufacturer: String

    // Optional details
    public var model: String?
    public var category: WatchCategory?
    public var serialNumber: String?
    public var referenceNumber: String?
    public var movement: WatchMovement?
    public var isFavorite: Bool

    // Additional details
    public var purchaseDate: Date?
    public var serviceIntervalMonths: Int?
    public var warrantyExpirationDate: Date?
    public var lastServiceDate: Date?
    public var purchasePrice: Decimal?
    public var currentValue: Decimal?
    public var notes: String?
    public var imageAssetId: String?

    // Derived/denormalized for performance
    public var timesWorn: Int
    public var lastWornDate: Date?

    // Sales info (to capture values of bought/sold watches)
    public var saleDate: Date?
    public var salePrice: Decimal?

    // Metadata
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        manufacturer: String,
        model: String? = nil,
        category: WatchCategory? = nil,
        serialNumber: String? = nil,
        referenceNumber: String? = nil,
        movement: WatchMovement? = nil,
        isFavorite: Bool = false,
        purchaseDate: Date? = nil,
        serviceIntervalMonths: Int? = nil,
        warrantyExpirationDate: Date? = nil,
        lastServiceDate: Date? = nil,
        purchasePrice: Decimal? = nil,
        currentValue: Decimal? = nil,
        notes: String? = nil,
        imageAssetId: String? = nil,
        timesWorn: Int = 0,
        lastWornDate: Date? = nil,
        saleDate: Date? = nil,
        salePrice: Decimal? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.manufacturer = manufacturer
        self.model = model
        self.category = category
        self.serialNumber = serialNumber
        self.referenceNumber = referenceNumber
        self.movement = movement
        self.isFavorite = isFavorite
        self.purchaseDate = purchaseDate
        self.serviceIntervalMonths = serviceIntervalMonths
        self.warrantyExpirationDate = warrantyExpirationDate
        self.lastServiceDate = lastServiceDate
        self.purchasePrice = purchasePrice
        self.currentValue = currentValue
        self.notes = notes
        self.imageAssetId = imageAssetId
        self.timesWorn = timesWorn
        self.lastWornDate = lastWornDate
        self.saleDate = saleDate
        self.salePrice = salePrice
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


