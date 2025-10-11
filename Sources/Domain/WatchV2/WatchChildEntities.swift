import Foundation

public struct WatchPhoto: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public var localIdentifier: String
    public var isPrimary: Bool
    public var position: Int

    public init(id: UUID = UUID(), localIdentifier: String, isPrimary: Bool = false, position: Int = 0) {
        self.id = id
        self.localIdentifier = localIdentifier
        self.isPrimary = isPrimary
        self.position = position
    }
}

public struct ServiceHistoryEntry: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public var date: Date?
    public var provider: String?
    public var workDescription: String?
    public var costAmount: Decimal?
    public var costCurrency: String?
    public var warrantyUntil: Date?

    public init(id: UUID = UUID(),
                date: Date? = nil,
                provider: String? = nil,
                workDescription: String? = nil,
                costAmount: Decimal? = nil,
                costCurrency: String? = nil,
                warrantyUntil: Date? = nil) {
        self.id = id
        self.date = date
        self.provider = provider
        self.workDescription = workDescription
        self.costAmount = costAmount
        self.costCurrency = costCurrency
        self.warrantyUntil = warrantyUntil
    }
}

public struct ValuationEntry: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public var date: Date?
    public var source: ValuationSource?
    public var valueAmount: Decimal?
    public var valueCurrency: String?

    public init(id: UUID = UUID(),
                date: Date? = nil,
                source: ValuationSource? = nil,
                valueAmount: Decimal? = nil,
                valueCurrency: String? = nil) {
        self.id = id
        self.date = date
        self.source = source
        self.valueAmount = valueAmount
        self.valueCurrency = valueCurrency
    }
}

public struct StrapInventoryItem: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public var type: StrapType?
    public var material: String?
    public var color: String?
    public var widthMM: Int?
    public var claspType: ClaspType?
    public var quickRelease: Bool

    public init(id: UUID = UUID(),
                type: StrapType? = nil,
                material: String? = nil,
                color: String? = nil,
                widthMM: Int? = nil,
                claspType: ClaspType? = nil,
                quickRelease: Bool = false) {
        self.id = id
        self.type = type
        self.material = material
        self.color = color
        self.widthMM = widthMM
        self.claspType = claspType
        self.quickRelease = quickRelease
    }
}
