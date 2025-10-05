import Foundation

// MARK: - Codable helpers for enums-with-Other

private protocol StringBackedEnum: Codable, Hashable, Sendable {
    static func fromString(_ raw: String) -> Self
    func asString() -> String
}

extension StringBackedEnum {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = Self.fromString(raw)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(asString())
    }
}

// MARK: - Case

public enum CaseMaterial: StringBackedEnum {
    case steel
    case titanium
    case gold
    case ceramic
    case bronze
    case carbon
    case twoTone
    case other(String)

    public static func fromString(_ raw: String) -> CaseMaterial {
        switch raw.lowercased() {
        case "steel": return .steel
        case "titanium": return .titanium
        case "gold": return .gold
        case "ceramic": return .ceramic
        case "bronze": return .bronze
        case "carbon": return .carbon
        case "two-tone", "twotone", "two_tone": return .twoTone
        default: return .other(raw)
        }
    }

    public func asString() -> String {
        switch self {
        case .steel: return "steel"
        case .titanium: return "titanium"
        case .gold: return "gold"
        case .ceramic: return "ceramic"
        case .bronze: return "bronze"
        case .carbon: return "carbon"
        case .twoTone: return "two-tone"
        case .other(let v): return v
        }
    }
}

public enum CaseFinish: StringBackedEnum {
    case polished
    case brushed
    case mixed
    case beadBlasted
    case other(String)

    public static func fromString(_ raw: String) -> CaseFinish {
        switch raw.lowercased() {
        case "polished": return .polished
        case "brushed": return .brushed
        case "mixed": return .mixed
        case "bead-blasted", "beadblasted", "bead_blasted": return .beadBlasted
        default: return .other(raw)
        }
    }

    public func asString() -> String {
        switch self {
        case .polished: return "polished"
        case .brushed: return "brushed"
        case .mixed: return "mixed"
        case .beadBlasted: return "bead-blasted"
        case .other(let v): return v
        }
    }
}

public enum CaseShape: StringBackedEnum {
    case round
    case cushion
    case tonneau
    case rectangular
    case square
    case oval
    case other(String)

    public static func fromString(_ raw: String) -> CaseShape {
        switch raw.lowercased() {
        case "round": return .round
        case "cushion": return .cushion
        case "tonneau": return .tonneau
        case "rectangular": return .rectangular
        case "square": return .square
        case "oval": return .oval
        default: return .other(raw)
        }
    }

    public func asString() -> String {
        switch self {
        case .round: return "round"
        case .cushion: return "cushion"
        case .tonneau: return "tonneau"
        case .rectangular: return "rectangular"
        case .square: return "square"
        case .oval: return "oval"
        case .other(let v): return v
        }
    }
}

public enum BezelType: StringBackedEnum {
    case fixed
    case diveUni
    case biDirectional
    case gmt
    case tachymeter
    case other(String)

    public static func fromString(_ raw: String) -> BezelType {
        switch raw.lowercased() {
        case "fixed": return .fixed
        case "dive", "dive (uni)", "dive_uni": return .diveUni
        case "bi-directional", "bidirectional": return .biDirectional
        case "gmt": return .gmt
        case "tachymeter": return .tachymeter
        default: return .other(raw)
        }
    }

    public func asString() -> String {
        switch self {
        case .fixed: return "fixed"
        case .diveUni: return "dive (uni)"
        case .biDirectional: return "bi-directional"
        case .gmt: return "GMT"
        case .tachymeter: return "tachymeter"
        case .other(let v): return v
        }
    }
}

public enum BezelMaterial: StringBackedEnum { case steel, ceramic, aluminum, sapphire, gold, other(String)
    public static func fromString(_ raw: String) -> BezelMaterial {
        switch raw.lowercased() {
        case "steel": return .steel
        case "ceramic": return .ceramic
        case "aluminum": return .aluminum
        case "sapphire": return .sapphire
        case "gold": return .gold
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .steel: return "steel"
        case .ceramic: return "ceramic"
        case .aluminum: return "aluminum"
        case .sapphire: return "sapphire"
        case .gold: return "gold"
        case .other(let v): return v
    }}
}

public enum CasebackType: StringBackedEnum { case solid, exhibition, engraved, other(String)
    public static func fromString(_ raw: String) -> CasebackType {
        switch raw.lowercased() {
        case "solid": return .solid
        case "exhibition": return .exhibition
        case "engraved": return .engraved
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .solid: return "solid"
        case .exhibition: return "exhibition"
        case .engraved: return "engraved"
        case .other(let v): return v
    }}
}

public enum CasebackMaterial: StringBackedEnum { case steel, titanium, sapphire, gold, other(String)
    public static func fromString(_ raw: String) -> CasebackMaterial {
        switch raw.lowercased() {
        case "steel": return .steel
        case "titanium": return .titanium
        case "sapphire": return .sapphire
        case "gold": return .gold
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .steel: return "steel"
        case .titanium: return "titanium"
        case .sapphire: return "sapphire"
        case .gold: return "gold"
        case .other(let v): return v
    }}
}

// MARK: - Dial & Hands

public enum DialFinish: StringBackedEnum {
    case sunburst, matte, enamel, lacquer, fume, guilloche, other(String)
    public static func fromString(_ raw: String) -> DialFinish {
        switch raw.lowercased() {
        case "sunburst": return .sunburst
        case "matte": return .matte
        case "enamel": return .enamel
        case "lacquer": return .lacquer
        case "fumé", "fume": return .fume
        case "guilloché", "guilloche": return .guilloche
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .sunburst: return "sunburst"
        case .matte: return "matte"
        case .enamel: return "enamel"
        case .lacquer: return "lacquer"
        case .fume: return "fumé"
        case .guilloche: return "guilloché"
        case .other(let v): return v
    }}
}

public enum IndicesStyle: StringBackedEnum {
    case applied, painted, roman, arabic, baton, mixed, other(String)
    public static func fromString(_ raw: String) -> IndicesStyle {
        switch raw.lowercased() {
        case "applied": return .applied
        case "painted": return .painted
        case "roman": return .roman
        case "arabic": return .arabic
        case "baton": return .baton
        case "mixed": return .mixed
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .applied: return "applied"
        case .painted: return "painted"
        case .roman: return "Roman"
        case .arabic: return "Arabic"
        case .baton: return "baton"
        case .mixed: return "mixed"
        case .other(let v): return v
    }}
}

public enum IndicesMaterial: StringBackedEnum { case metal, lume, ceramic, other(String)
    public static func fromString(_ raw: String) -> IndicesMaterial {
        switch raw.lowercased() {
        case "metal": return .metal
        case "lume": return .lume
        case "ceramic": return .ceramic
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .metal: return "metal"
        case .lume: return "lume"
        case .ceramic: return "ceramic"
        case .other(let v): return v
    }}
}

public enum HandsStyle: StringBackedEnum { case dauphine, baton, sword, mercedes, cathedral, other(String)
    public static func fromString(_ raw: String) -> HandsStyle {
        switch raw.lowercased() {
        case "dauphine": return .dauphine
        case "baton": return .baton
        case "sword": return .sword
        case "mercedes": return .mercedes
        case "cathedral": return .cathedral
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .dauphine: return "dauphine"
        case .baton: return "baton"
        case .sword: return "sword"
        case .mercedes: return "Mercedes"
        case .cathedral: return "cathedral"
        case .other(let v): return v
    }}
}

public enum HandsMaterial: StringBackedEnum { case steel, gold, bluedSteel, lume, other(String)
    public static func fromString(_ raw: String) -> HandsMaterial {
        switch raw.lowercased() {
        case "steel": return .steel
        case "gold": return .gold
        case "blued steel", "blued_steel": return .bluedSteel
        case "lume": return .lume
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .steel: return "steel"
        case .gold: return "gold"
        case .bluedSteel: return "blued steel"
        case .lume: return "lume"
        case .other(let v): return v
    }}
}

public enum LumeType: StringBackedEnum { case none, superLuminova(String), tritium, other(String)
    public static func fromString(_ raw: String) -> LumeType {
        switch raw.lowercased() {
        case "none": return .none
        case let v where v.hasPrefix("super-luminova") || v.contains("lumi"): return .superLuminova(raw)
        case "tritium": return .tritium
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .none: return "none"
        case .superLuminova(let v): return v
        case .tritium: return "tritium"
        case .other(let v): return v
    }}
}

// MARK: - Crystal

public enum CrystalMaterial: StringBackedEnum { case sapphire, mineral, acrylic, hesalite, other(String)
    public static func fromString(_ raw: String) -> CrystalMaterial {
        switch raw.lowercased() {
        case "sapphire": return .sapphire
        case "mineral": return .mineral
        case "acrylic": return .acrylic
        case "hesalite", "acrylic/hesalite": return .hesalite
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .sapphire: return "sapphire"
        case .mineral: return "mineral"
        case .acrylic: return "acrylic"
        case .hesalite: return "hesalite"
        case .other(let v): return v
    }}
}

public enum CrystalShapeProfile: StringBackedEnum { case flat, domed, doubleDomed, boxed, other(String)
    public static func fromString(_ raw: String) -> CrystalShapeProfile {
        switch raw.lowercased() {
        case "flat": return .flat
        case "domed": return .domed
        case "double-domed", "double_domed": return .doubleDomed
        case "boxed": return .boxed
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .flat: return "flat"
        case .domed: return "domed"
        case .doubleDomed: return "double-domed"
        case .boxed: return "boxed"
        case .other(let v): return v
    }}
}

public enum ARCoating: StringBackedEnum { case none, inside, bothSides, other(String)
    public static func fromString(_ raw: String) -> ARCoating {
        switch raw.lowercased() {
        case "none": return .none
        case "inside": return .inside
        case "both", "both sides": return .bothSides
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .none: return "none"
        case .inside: return "inside"
        case .bothSides: return "both sides"
        case .other(let v): return v
    }}
}

// MARK: - Movement

public enum MovementType: String, Codable, Hashable, Sendable {
    case automatic, manual, quartz, solar, springDrive, mechaquartz, kinetic, tuningFork, smartHybrid
}

public enum ChronometerCert: StringBackedEnum { case none, cosc, metas, jis, inHouse, other(String)
    public static func fromString(_ raw: String) -> ChronometerCert {
        switch raw.lowercased() {
        case "none": return .none
        case "cosc": return .cosc
        case "metas", "master chronometer": return .metas
        case "jis": return .jis
        case "in-house", "in house": return .inHouse
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .none: return "none"
        case .cosc: return "COSC"
        case .metas: return "METAS/Master Chronometer"
        case .jis: return "JIS"
        case .inHouse: return "in-house"
        case .other(let v): return v
    }}
}

// MARK: - Water & Crown

public enum CrownType: StringBackedEnum { case pushPull, screwDown, lockingSystem, other(String)
    public static func fromString(_ raw: String) -> CrownType {
        switch raw.lowercased() {
        case "push/pull", "push-pull", "pushpull": return .pushPull
        case "screw-down", "screwdown": return .screwDown
        case "locking system", "locking": return .lockingSystem
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .pushPull: return "push/pull"
        case .screwDown: return "screw-down"
        case .lockingSystem: return "locking system"
        case .other(let v): return v
    }}
}

// MARK: - Strap / Bracelet

public enum StrapType: StringBackedEnum { case bracelet, leather, rubber, silicone, fabricNATO, fkm, integrated, nato, other(String)
    public static func fromString(_ raw: String) -> StrapType {
        switch raw.lowercased() {
        case "bracelet": return .bracelet
        case "leather": return .leather
        case "rubber": return .rubber
        case "silicone": return .silicone
        case "fabric/nato", "fabric", "nato": return .fabricNATO
        case "fkm": return .fkm
        case "integrated": return .integrated
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .bracelet: return "bracelet"
        case .leather: return "leather"
        case .rubber: return "rubber"
        case .silicone: return "silicone"
        case .fabricNATO: return "fabric/NATO"
        case .fkm: return "FKM"
        case .integrated: return "integrated"
        case .nato: return "NATO"
        case .other(let v): return v
    }}
}

public enum EndLinks: StringBackedEnum { case solid, hollow, fitted, straight, integrated, other(String)
    public static func fromString(_ raw: String) -> EndLinks {
        switch raw.lowercased() {
        case "solid": return .solid
        case "hollow": return .hollow
        case "fitted": return .fitted
        case "straight": return .straight
        case "integrated": return .integrated
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .solid: return "solid"
        case .hollow: return "hollow"
        case .fitted: return "fitted"
        case .straight: return "straight"
        case .integrated: return "integrated"
        case .other(let v): return v
    }}
}

public enum ClaspType: StringBackedEnum { case pinBuckle, deployant, folding, butterfly, microAdjust, other(String)
    public static func fromString(_ raw: String) -> ClaspType {
        switch raw.lowercased() {
        case "pin buckle", "pin_buckle": return .pinBuckle
        case "deployant": return .deployant
        case "folding": return .folding
        case "butterfly": return .butterfly
        case "micro-adjust", "micro_adjust", "microadjust": return .microAdjust
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .pinBuckle: return "pin buckle"
        case .deployant: return "deployant"
        case .folding: return "folding"
        case .butterfly: return "butterfly"
        case .microAdjust: return "micro-adjust"
        case .other(let v): return v
    }}
}

// MARK: - Ownership

public enum OwnershipCondition: StringBackedEnum { case new, unworn, excellent, veryGood, good, fair, poor, other(String)
    public static func fromString(_ raw: String) -> OwnershipCondition {
        switch raw.lowercased() {
        case "new": return .new
        case "unworn": return .unworn
        case "excellent": return .excellent
        case "very good", "very_good": return .veryGood
        case "good": return .good
        case "fair": return .fair
        case "poor": return .poor
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .new: return "new"
        case .unworn: return "unworn"
        case .excellent: return "excellent"
        case .veryGood: return "very good"
        case .good: return "good"
        case .fair: return "fair"
        case .poor: return "poor"
        case .other(let v): return v
    }}
}

public enum BoxPapers: StringBackedEnum { case fullSet, watchOnly, partial, boxOnly, papersOnly, other(String)
    public static func fromString(_ raw: String) -> BoxPapers {
        switch raw.lowercased() {
        case "full set", "full_set": return .fullSet
        case "watch only", "watch_only": return .watchOnly
        case "partial": return .partial
        case "box only", "box_only": return .boxOnly
        case "papers only", "papers_only": return .papersOnly
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .fullSet: return "full set"
        case .watchOnly: return "watch only"
        case .partial: return "partial"
        case .boxOnly: return "box only"
        case .papersOnly: return "papers only"
        case .other(let v): return v
    }}
}

// MARK: - Valuation

public enum ValuationSource: StringBackedEnum { case insurer, appraisal, marketEst, auctionComp, other(String)
    public static func fromString(_ raw: String) -> ValuationSource {
        switch raw.lowercased() {
        case "insurer": return .insurer
        case "appraisal": return .appraisal
        case "market est.", "market est", "market_est": return .marketEst
        case "auction comp", "auction_comp": return .auctionComp
        default: return .other(raw)
        }
    }
    public func asString() -> String { switch self {
        case .insurer: return "insurer"
        case .appraisal: return "appraisal"
        case .marketEst: return "market est."
        case .auctionComp: return "auction comp"
        case .other(let v): return v
    }}
}


