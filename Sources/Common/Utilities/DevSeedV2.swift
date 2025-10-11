import Foundation
import UIKit

#if DEBUG
public enum DevSeedV2 {
    public static func seedIfEmpty() {
        do {
            let repo = WatchRepositoryGRDB()
            let list = try repo.list(sortedBy: .manufacturerLineModel, filters: WatchFilters())
            guard list.isEmpty else { return }

            // Generate comprehensive test data
            let testWatches = generateTestWatches()

            for watchData in testWatches {
                var watch = watchData.watch

                // Add placeholder image if specified
                if watchData.addPhoto {
                    let img = generatePlaceholderImage(text: watchData.imageText, color: watchData.imageColor)
                    let pipeline = PhotoPipelineV2()
                    let (_, updated) = try pipeline.addPhoto(watchId: watch.id, sourceImage: img, makePrimary: true, existingPhotos: [])
                    watch.photos = updated
                }

                try repo.create(watch)
            }
        } catch {
            // ignore in seed
        }
    }

    public static func generateTestData() {
        do {
            let repo = WatchRepositoryGRDB()
            let testWatches = generateTestWatches()

            for watchData in testWatches {
                var watch = watchData.watch

                // Add placeholder image if specified
                if watchData.addPhoto {
                    let img = generatePlaceholderImage(text: watchData.imageText, color: watchData.imageColor)
                    let pipeline = PhotoPipelineV2()
                    let (_, updated) = try pipeline.addPhoto(watchId: watch.id, sourceImage: img, makePrimary: true, existingPhotos: [])
                    watch.photos = updated
                }

                try repo.create(watch)
            }
        } catch {
            print("Error generating test data: \(error)")
        }
    }

    private static func generateTestWatches() -> [TestWatchData] {
        [
            TestWatchData(
                watch: WatchV2(
                    manufacturer: "Omega",
                    line: "Speedmaster",
                    modelName: "Professional",
                    referenceNumber: "311.30.42.30.01.005",
                    nickname: "Moonwatch",
                    serialNumber: "OM123456",
                    productionYear: 2_020,
                    tags: ["chronograph", "space", "heritage"],
                    watchCase: WatchCase(
                        material: .steel,
                        finish: .brushed,
                        shape: .round,
                        diameterMM: 42.0,
                        thicknessMM: 13.2,
                        lugToLugMM: 48.0,
                        lugWidthMM: 20,
                        bezelType: .tachymeter,
                        bezelMaterial: .aluminum,
                        casebackType: .exhibition,
                        casebackMaterial: .sapphire
                    ),
                    dial: WatchDial(
                        color: "Black",
                        finish: .matte,
                        indicesStyle: .applied,
                        indicesMaterial: .metal,
                        handsStyle: .dauphine,
                        handsMaterial: .steel,
                        lumeType: .superLuminova("C3"),
                        complications: ["chronograph", "small seconds"]
                    ),
                    crystal: WatchCrystal(
                        material: .sapphire,
                        shapeProfile: .domed,
                        arCoating: .bothSides
                    ),
                    movement: MovementSpec(
                        type: .manual,
                        caliber: "Omega 1861",
                        powerReserveHours: 48,
                        frequencyVPH: 21_600,
                        jewelCount: 18,
                        accuracySpecPPD: 4.0,
                        chronometerCert: .cosc
                    ),
                    water: WatchWater(
                        waterResistanceM: 50,
                        crownType: .pushPull,
                        crownGuard: false
                    ),
                    strapCurrent: WatchStrapCurrent(
                        type: .bracelet,
                        material: "Steel",
                        color: "Steel",
                        endLinks: .solid,
                        claspType: .deployant,
                        braceletLinkCount: 12,
                        quickRelease: false
                    ),
                    ownership: WatchOwnership(
                        dateAcquired: Date().addingTimeInterval(-365 * 24 * 60 * 60), // 1 year ago
                        purchasedFrom: "Omega Boutique",
                        purchasePriceAmount: Decimal(6_300),
                        purchasePriceCurrency: "USD",
                        condition: .excellent,
                        boxPapers: .fullSet,
                        currentEstimatedValueAmount: Decimal(6_500),
                        currentEstimatedValueCurrency: "USD",
                        insuranceProvider: "Chubb",
                        insurancePolicyNumber: "CH123456",
                        insuranceRenewalDate: Date().addingTimeInterval(365 * 24 * 60 * 60)
                    ),
                    serviceHistory: [
                        ServiceHistoryEntry(
                            date: Date().addingTimeInterval(-180 * 24 * 60 * 60), // 6 months ago
                            provider: "Omega Service Center",
                            workDescription: "Full service and regulation",
                            costAmount: Decimal(450),
                            costCurrency: "USD",
                            warrantyUntil: Date().addingTimeInterval(365 * 24 * 60 * 60) // 1 year warranty
                        )
                    ],
                    valuations: [
                        ValuationEntry(
                            date: Date().addingTimeInterval(-30 * 24 * 60 * 60), // 1 month ago
                            source: .marketEst,
                            valueAmount: Decimal(6_500),
                            valueCurrency: "USD"
                        )
                    ],
                    straps: [
                        StrapInventoryItem(
                            type: .leather,
                            material: "Leather",
                            color: "Brown",
                            widthMM: 20,
                            claspType: .pinBuckle,
                            quickRelease: true
                        )
                    ]
                ),
                addPhoto: true,
                imageText: "Ω",
                imageColor: .systemBlue
            ),

            TestWatchData(
                watch: WatchV2(
                    manufacturer: "Rolex",
                    line: "Submariner",
                    modelName: "Date",
                    referenceNumber: "126610LN",
                    nickname: "Sub",
                    serialNumber: "RL789012",
                    productionYear: 2_021,
                    tags: ["dive", "tool", "classic"],
                    watchCase: WatchCase(
                        material: .steel,
                        finish: .polished,
                        shape: .round,
                        diameterMM: 41.0,
                        thicknessMM: 12.5,
                        lugToLugMM: 47.0,
                        lugWidthMM: 20,
                        bezelType: .diveUni,
                        bezelMaterial: .ceramic,
                        casebackType: .solid,
                        casebackMaterial: .steel
                    ),
                    dial: WatchDial(
                        color: "Black",
                        finish: .matte,
                        indicesStyle: .applied,
                        indicesMaterial: .lume,
                        handsStyle: .mercedes,
                        handsMaterial: .steel,
                        lumeType: .superLuminova("C3"),
                        complications: ["date"]
                    ),
                    crystal: WatchCrystal(
                        material: .sapphire,
                        shapeProfile: .flat,
                        arCoating: ARCoating.none
                    ),
                    movement: MovementSpec(
                        type: .automatic,
                        caliber: "Rolex 3235",
                        powerReserveHours: 70,
                        frequencyVPH: 28_800,
                        jewelCount: 31,
                        accuracySpecPPD: 2.0,
                        chronometerCert: .cosc
                    ),
                    water: WatchWater(
                        waterResistanceM: 300,
                        crownType: .screwDown,
                        crownGuard: true
                    ),
                    strapCurrent: WatchStrapCurrent(
                        type: .bracelet,
                        material: "Steel",
                        color: "Steel",
                        endLinks: .solid,
                        claspType: .deployant,
                        braceletLinkCount: 13,
                        quickRelease: false
                    ),
                    ownership: WatchOwnership(
                        dateAcquired: Date().addingTimeInterval(-200 * 24 * 60 * 60), // ~7 months ago
                        purchasedFrom: "Authorized Dealer",
                        purchasePriceAmount: Decimal(9_100),
                        purchasePriceCurrency: "USD",
                        condition: .excellent,
                        boxPapers: .fullSet,
                        currentEstimatedValueAmount: Decimal(12_000),
                        currentEstimatedValueCurrency: "USD"
                    )
                ),
                addPhoto: true,
                imageText: "R",
                imageColor: .systemGreen
            ),

            TestWatchData(
                watch: WatchV2(
                    manufacturer: "Seiko",
                    line: "Prospex",
                    modelName: "Turtle",
                    referenceNumber: "SRP777",
                    nickname: "Turtle",
                    serialNumber: "SK345678",
                    productionYear: 2_019,
                    tags: ["dive", "affordable", "reliable"],
                    watchCase: WatchCase(
                        material: .steel,
                        finish: .brushed,
                        shape: .round,
                        diameterMM: 45.0,
                        thicknessMM: 14.0,
                        lugToLugMM: 48.0,
                        lugWidthMM: 22,
                        bezelType: .diveUni,
                        bezelMaterial: .aluminum,
                        casebackType: .solid,
                        casebackMaterial: .steel
                    ),
                    dial: WatchDial(
                        color: "Black",
                        finish: .matte,
                        indicesStyle: .applied,
                        indicesMaterial: .lume,
                        handsStyle: .sword,
                        handsMaterial: .steel,
                        lumeType: .superLuminova("C3"),
                        complications: ["date"]
                    ),
                    crystal: WatchCrystal(
                        material: .mineral,
                        shapeProfile: .domed,
                        arCoating: ARCoating.none
                    ),
                    movement: MovementSpec(
                        type: .automatic,
                        caliber: "Seiko 4R36",
                        powerReserveHours: 41,
                        frequencyVPH: 21_600,
                        jewelCount: 24,
                        accuracySpecPPD: 15.0,
                        chronometerCert: ChronometerCert.none
                    ),
                    water: WatchWater(
                        waterResistanceM: 200,
                        crownType: .screwDown,
                        crownGuard: true
                    ),
                    strapCurrent: WatchStrapCurrent(
                        type: .rubber,
                        material: "Rubber",
                        color: "Black",
                        endLinks: .straight,
                        claspType: .pinBuckle,
                        braceletLinkCount: 0,
                        quickRelease: false
                    ),
                    ownership: WatchOwnership(
                        dateAcquired: Date().addingTimeInterval(-500 * 24 * 60 * 60), // ~1.5 years ago
                        purchasedFrom: "Online Retailer",
                        purchasePriceAmount: Decimal(350),
                        purchasePriceCurrency: "USD",
                        condition: .veryGood,
                        boxPapers: .partial,
                        currentEstimatedValueAmount: Decimal(400),
                        currentEstimatedValueCurrency: "USD"
                    )
                ),
                addPhoto: true,
                imageText: "S",
                imageColor: .systemOrange
            ),

            TestWatchData(
                watch: WatchV2(
                    manufacturer: "Grand Seiko",
                    line: "Heritage",
                    modelName: "Snowflake",
                    referenceNumber: "SBGA211",
                    nickname: "Snowflake",
                    serialNumber: "GS901234",
                    productionYear: 2_022,
                    tags: ["spring-drive", "luxury", "japanese"],
                    watchCase: WatchCase(
                        material: .steel,
                        finish: .polished,
                        shape: .round,
                        diameterMM: 41.0,
                        thicknessMM: 12.5,
                        lugToLugMM: 47.0,
                        lugWidthMM: 20,
                        bezelType: .fixed,
                        bezelMaterial: .steel,
                        casebackType: .exhibition,
                        casebackMaterial: .sapphire
                    ),
                    dial: WatchDial(
                        color: "White",
                        finish: .guilloche,
                        indicesStyle: .applied,
                        indicesMaterial: .metal,
                        handsStyle: .dauphine,
                        handsMaterial: .steel,
                        lumeType: LumeType.none,
                        complications: ["power reserve", "date"]
                    ),
                    crystal: WatchCrystal(
                        material: .sapphire,
                        shapeProfile: .boxed,
                        arCoating: .bothSides
                    ),
                    movement: MovementSpec(
                        type: .springDrive,
                        caliber: "Grand Seiko 9R65",
                        powerReserveHours: 72,
                        frequencyVPH: 0, // Spring Drive doesn't use traditional frequency
                        jewelCount: 30,
                        accuracySpecPPD: 0.5,
                        chronometerCert: ChronometerCert.none
                    ),
                    water: WatchWater(
                        waterResistanceM: 100,
                        crownType: .screwDown,
                        crownGuard: false
                    ),
                    strapCurrent: WatchStrapCurrent(
                        type: .leather,
                        material: "Leather",
                        color: "Black",
                        endLinks: .straight,
                        claspType: .pinBuckle,
                        braceletLinkCount: 0,
                        quickRelease: true
                    ),
                    ownership: WatchOwnership(
                        dateAcquired: Date().addingTimeInterval(-100 * 24 * 60 * 60), // ~3 months ago
                        purchasedFrom: "Grand Seiko Boutique",
                        purchasePriceAmount: Decimal(5_800),
                        purchasePriceCurrency: "USD",
                        condition: .excellent,
                        boxPapers: .fullSet,
                        currentEstimatedValueAmount: Decimal(6_000),
                        currentEstimatedValueCurrency: "USD"
                    )
                ),
                addPhoto: true,
                imageText: "GS",
                imageColor: .systemPurple
            )
        ]
    }

    private static func generatePlaceholderImage(text: String, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1_200, height: 1_200))
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1_200, height: 1_200))

            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 120, weight: .bold)
            ]
            let size = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: (1_200 - size.width) / 2.0, y: (1_200 - size.height) / 2.0), withAttributes: attrs)
        }
    }
}

private struct TestWatchData {
    let watch: WatchV2
    let addPhoto: Bool
    let imageText: String
    let imageColor: UIColor
}
#endif
