import Foundation

public struct WatchCase: Codable, Hashable, Sendable {
    public var material: CaseMaterial?
    public var finish: CaseFinish?
    public var shape: CaseShape?
    public var diameterMM: Double?
    public var thicknessMM: Double?
    public var lugToLugMM: Double?
    public var lugWidthMM: Int?
    public var bezelType: BezelType?
    public var bezelMaterial: BezelMaterial?
    public var casebackType: CasebackType?
    public var casebackMaterial: CasebackMaterial?

    public init(material: CaseMaterial? = nil,
                finish: CaseFinish? = nil,
                shape: CaseShape? = nil,
                diameterMM: Double? = nil,
                thicknessMM: Double? = nil,
                lugToLugMM: Double? = nil,
                lugWidthMM: Int? = nil,
                bezelType: BezelType? = nil,
                bezelMaterial: BezelMaterial? = nil,
                casebackType: CasebackType? = nil,
                casebackMaterial: CasebackMaterial? = nil) {
        self.material = material
        self.finish = finish
        self.shape = shape
        self.diameterMM = diameterMM
        self.thicknessMM = thicknessMM
        self.lugToLugMM = lugToLugMM
        self.lugWidthMM = lugWidthMM
        self.bezelType = bezelType
        self.bezelMaterial = bezelMaterial
        self.casebackType = casebackType
        self.casebackMaterial = casebackMaterial
    }
}

public struct WatchDial: Codable, Hashable, Sendable {
    public var color: String?
    public var finish: DialFinish?
    public var indicesStyle: IndicesStyle?
    public var indicesMaterial: IndicesMaterial?
    public var handsStyle: HandsStyle?
    public var handsMaterial: HandsMaterial?
    public var lumeType: LumeType?
    public var complications: [String]

    public init(color: String? = nil,
                finish: DialFinish? = nil,
                indicesStyle: IndicesStyle? = nil,
                indicesMaterial: IndicesMaterial? = nil,
                handsStyle: HandsStyle? = nil,
                handsMaterial: HandsMaterial? = nil,
                lumeType: LumeType? = nil,
                complications: [String] = []) {
        self.color = color
        self.finish = finish
        self.indicesStyle = indicesStyle
        self.indicesMaterial = indicesMaterial
        self.handsStyle = handsStyle
        self.handsMaterial = handsMaterial
        self.lumeType = lumeType
        self.complications = complications
    }
}

public struct WatchCrystal: Codable, Hashable, Sendable {
    public var material: CrystalMaterial?
    public var shapeProfile: CrystalShapeProfile?
    public var arCoating: ARCoating?

    public init(material: CrystalMaterial? = nil,
                shapeProfile: CrystalShapeProfile? = nil,
                arCoating: ARCoating? = nil) {
        self.material = material
        self.shapeProfile = shapeProfile
        self.arCoating = arCoating
    }
}

public struct MovementSpec: Codable, Hashable, Sendable {
    public var type: MovementType?
    public var caliber: String?
    public var powerReserveHours: Double?
    public var frequencyVPH: Int?
    public var jewelCount: Int?
    public var accuracySpecPPD: Double?
    public var chronometerCert: ChronometerCert?

    public init(type: MovementType? = nil,
                caliber: String? = nil,
                powerReserveHours: Double? = nil,
                frequencyVPH: Int? = nil,
                jewelCount: Int? = nil,
                accuracySpecPPD: Double? = nil,
                chronometerCert: ChronometerCert? = nil) {
        self.type = type
        self.caliber = caliber
        self.powerReserveHours = powerReserveHours
        self.frequencyVPH = frequencyVPH
        self.jewelCount = jewelCount
        self.accuracySpecPPD = accuracySpecPPD
        self.chronometerCert = chronometerCert
    }
}

public struct WatchWater: Codable, Hashable, Sendable {
    public var waterResistanceM: Int?
    public var crownType: CrownType?
    public var crownGuard: Bool

    public init(waterResistanceM: Int? = nil, crownType: CrownType? = nil, crownGuard: Bool = false) {
        self.waterResistanceM = waterResistanceM
        self.crownType = crownType
        self.crownGuard = crownGuard
    }
}

public struct WatchStrapCurrent: Codable, Hashable, Sendable {
    public var type: StrapType?
    public var material: String?
    public var color: String?
    public var endLinks: EndLinks?
    public var claspType: ClaspType?
    public var braceletLinkCount: Int?
    public var quickRelease: Bool

    public init(type: StrapType? = nil,
                material: String? = nil,
                color: String? = nil,
                endLinks: EndLinks? = nil,
                claspType: ClaspType? = nil,
                braceletLinkCount: Int? = nil,
                quickRelease: Bool = false) {
        self.type = type
        self.material = material
        self.color = color
        self.endLinks = endLinks
        self.claspType = claspType
        self.braceletLinkCount = braceletLinkCount
        self.quickRelease = quickRelease
    }
}

public struct WatchOwnership: Codable, Hashable, Sendable {
    public var dateAcquired: Date?
    public var purchasedFrom: String?
    public var purchasePriceAmount: Decimal?
    public var purchasePriceCurrency: String?
    public var condition: OwnershipCondition?
    public var boxPapers: BoxPapers?
    public var currentEstimatedValueAmount: Decimal?
    public var currentEstimatedValueCurrency: String?
    public var insuranceProvider: String?
    public var insurancePolicyNumber: String?
    public var insuranceRenewalDate: Date?

    public init(dateAcquired: Date? = nil,
                purchasedFrom: String? = nil,
                purchasePriceAmount: Decimal? = nil,
                purchasePriceCurrency: String? = nil,
                condition: OwnershipCondition? = nil,
                boxPapers: BoxPapers? = nil,
                currentEstimatedValueAmount: Decimal? = nil,
                currentEstimatedValueCurrency: String? = nil,
                insuranceProvider: String? = nil,
                insurancePolicyNumber: String? = nil,
                insuranceRenewalDate: Date? = nil) {
        self.dateAcquired = dateAcquired
        self.purchasedFrom = purchasedFrom
        self.purchasePriceAmount = purchasePriceAmount
        self.purchasePriceCurrency = purchasePriceCurrency
        self.condition = condition
        self.boxPapers = boxPapers
        self.currentEstimatedValueAmount = currentEstimatedValueAmount
        self.currentEstimatedValueCurrency = currentEstimatedValueCurrency
        self.insuranceProvider = insuranceProvider
        self.insurancePolicyNumber = insurancePolicyNumber
        self.insuranceRenewalDate = insuranceRenewalDate
    }
}
