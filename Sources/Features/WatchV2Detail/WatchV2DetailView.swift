import SwiftUI

public struct WatchV2DetailView: View {
    public let watch: WatchV2
    @State private var galleryIndex: Int = 0
    @State private var showEditForm: Bool = false
    @State private var achievements: [(achievement: Achievement, state: AchievementState?)] = []
    @State private var wearCount: Int = 0
    @State private var lastWorn: Date? = nil
    
    private let achievementRepository: AchievementRepository = AchievementRepositoryGRDB()
    private let watchRepository: WatchRepositoryV2 = WatchRepositoryGRDB()
    
    @Environment(\.themeToken) private var themeToken

    public init(watch: WatchV2) {
        self.watch = watch
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Photo gallery at the top
                photoGallery
                
                // Watch identity section (manufacturer, model, line, reference, nickname)
                watchIdentitySection
                
                // Statistics section (times worn, last worn, achievement progress)
                statisticsSection
                
                // Core details group
                coreDetailsSection
                
                // Case specifications group
                caseSpecificationsSection
                
                // Dial details group
                dialDetailsSection
                
                // Crystal details group
                crystalDetailsSection
                
                // Movement specifications group
                movementSpecificationsSection
                
                // Water resistance group
                waterResistanceSection
                
                // Strap/bracelet details group
                strapDetailsSection
                
                // Ownership information group
                ownershipInfoSection
                
                // Service history
                serviceHistorySection
                
                // Valuations
                valuationsSection
                
                // Strap inventory
                strapInventorySection
                
                // Achievements at bottom (horizontal row)
                achievementsSection
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle(watch.nickname ?? watch.modelName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showEditForm = true
                }
            }
        }
        .sheet(isPresented: $showEditForm, onDismiss: {
            // Reload data after edit (watch data may have changed)
            Task {
                await loadData()
            }
        }) {
            NavigationView {
                WatchV2FormView(watch: watch)
            }
        }
        .task {
            await loadData()
        }
        .id(themeToken) // Force refresh on theme change
    }
    
    // MARK: - Section Views
    
    private var watchIdentitySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Manufacturer + Model (prominent)
            Text("\(watch.manufacturer) \(watch.modelName)")
                .font(AppTypography.luxury)
                .foregroundStyle(AppColors.textPrimary)
            
            // Line + Reference (if available)
            if let line = watch.line, let reference = watch.referenceNumber {
                Text("\(line) • \(reference)")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            } else if let line = watch.line {
                Text(line)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            } else if let reference = watch.referenceNumber {
                Text(reference)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            // Nickname (if available)
            if let nickname = watch.nickname {
                Text("\"\(nickname)\"")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            DetailSectionHeader(title: "Statistics")
            
            StatisticRow(
                label: "Times Worn",
                value: "\(wearCount)",
                icon: "clock.fill"
            )
            
            if let lastWorn = lastWorn {
                StatisticRow(
                    label: "Last Worn",
                    value: DateFormatters.smartFormat(lastWorn),
                    icon: "calendar"
                )
            }
            
            if !watchAchievements.isEmpty {
                let totalAchievements = achievements.count
                let unlockedCount = watchAchievements.count
                StatisticRow(
                    label: "Achievements",
                    value: "\(unlockedCount) of \(totalAchievements) unlocked",
                    icon: "trophy.fill"
                )
            }
        }
    }
    
    private var coreDetailsSection: some View {
        Group {
            if WatchFieldFormatters.hasCoreDetails(watch) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Core Details")
                    
                    SpecificationRow(label: "Serial Number", value: watch.serialNumber)
                    SpecificationRow(label: "Production Year", value: watch.productionYear)
                    SpecificationRow(label: "Country of Origin", value: watch.countryOfOrigin)
                    SpecificationRow(label: "Limited Edition", value: watch.limitedEditionNumber)
                    SpecificationRow(label: "Notes", value: watch.notes)
                    
                    if !watch.tags.isEmpty {
                        HStack(alignment: .top, spacing: AppSpacing.md) {
                            Text("Tags")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                            
                            Spacer()
                            
                            TagPillGroup(tags: watch.tags)
                                .frame(maxWidth: 250, alignment: .trailing)
                        }
                        .padding(.vertical, AppSpacing.xxs)
                    }
                }
            }
        }
    }
    
    private var caseSpecificationsSection: some View {
        Group {
            if WatchFieldFormatters.hasCaseSpecs(watch.watchCase) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Case Specifications")
                    
                    if let material = watch.watchCase.material {
                        SpecificationRow(label: "Material", value: material.asString().capitalized)
                    }
                    if let finish = watch.watchCase.finish {
                        SpecificationRow(label: "Finish", value: finish.asString().capitalized)
                    }
                    if let shape = watch.watchCase.shape {
                        SpecificationRow(label: "Shape", value: shape.asString().capitalized)
                    }
                    SpecificationRow(
                        label: "Diameter",
                        value: WatchFieldFormatters.formatMeasurement(watch.watchCase.diameterMM, unit: "mm")
                    )
                    SpecificationRow(
                        label: "Thickness",
                        value: WatchFieldFormatters.formatMeasurement(watch.watchCase.thicknessMM, unit: "mm")
                    )
                    SpecificationRow(
                        label: "Lug to Lug",
                        value: WatchFieldFormatters.formatMeasurement(watch.watchCase.lugToLugMM, unit: "mm")
                    )
                    SpecificationRow(
                        label: "Lug Width",
                        value: WatchFieldFormatters.formatInt(watch.watchCase.lugWidthMM, unit: "mm")
                    )
                    if let bezelType = watch.watchCase.bezelType {
                        SpecificationRow(label: "Bezel Type", value: bezelType.asString().capitalized)
                    }
                    if let bezelMaterial = watch.watchCase.bezelMaterial {
                        SpecificationRow(label: "Bezel Material", value: bezelMaterial.asString().capitalized)
                    }
                    if let casebackType = watch.watchCase.casebackType {
                        SpecificationRow(label: "Caseback Type", value: casebackType.asString().capitalized)
                    }
                    if let casebackMaterial = watch.watchCase.casebackMaterial {
                        SpecificationRow(label: "Caseback Material", value: casebackMaterial.asString().capitalized)
                    }
                }
            }
        }
    }
    
    private var dialDetailsSection: some View {
        Group {
            if WatchFieldFormatters.hasDialDetails(watch.dial) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Dial Details")
                    
                    SpecificationRow(label: "Color", value: watch.dial.color)
                    if let finish = watch.dial.finish {
                        SpecificationRow(label: "Finish", value: finish.asString().capitalized)
                    }
                    if let indicesStyle = watch.dial.indicesStyle {
                        SpecificationRow(label: "Indices Style", value: indicesStyle.asString().capitalized)
                    }
                    if let indicesMaterial = watch.dial.indicesMaterial {
                        SpecificationRow(label: "Indices Material", value: indicesMaterial.asString().capitalized)
                    }
                    if let handsStyle = watch.dial.handsStyle {
                        SpecificationRow(label: "Hands Style", value: handsStyle.asString().capitalized)
                    }
                    if let handsMaterial = watch.dial.handsMaterial {
                        SpecificationRow(label: "Hands Material", value: handsMaterial.asString().capitalized)
                    }
                    if let lumeType = watch.dial.lumeType {
                        SpecificationRow(label: "Lume Type", value: lumeType.asString().capitalized)
                    }
                    
                    if !watch.dial.complications.isEmpty {
                        SpecificationRow(
                            label: "Complications",
                            value: watch.dial.complications.joined(separator: ", ")
                        )
                    }
                }
            }
        }
    }
    
    private var crystalDetailsSection: some View {
        Group {
            if WatchFieldFormatters.hasCrystalDetails(watch.crystal) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Crystal")
                    
                    if let material = watch.crystal.material {
                        SpecificationRow(label: "Material", value: material.asString().capitalized)
                    }
                    if let shapeProfile = watch.crystal.shapeProfile {
                        SpecificationRow(label: "Shape/Profile", value: shapeProfile.asString().capitalized)
                    }
                    if let arCoating = watch.crystal.arCoating {
                        SpecificationRow(label: "AR Coating", value: arCoating.asString().capitalized)
                    }
                }
            }
        }
    }
    
    private var movementSpecificationsSection: some View {
        Group {
            if WatchFieldFormatters.hasMovementSpecs(watch.movement) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Movement")
                    
                    SpecificationRow(label: "Type", enum: watch.movement.type)
                    SpecificationRow(label: "Caliber", value: watch.movement.caliber)
                    SpecificationRow(
                        label: "Power Reserve",
                        value: WatchFieldFormatters.formatPowerReserve(watch.movement.powerReserveHours)
                    )
                    SpecificationRow(
                        label: "Frequency",
                        value: WatchFieldFormatters.formatFrequency(watch.movement.frequencyVPH)
                    )
                    SpecificationRow(label: "Jewels", value: watch.movement.jewelCount)
                    SpecificationRow(
                        label: "Accuracy",
                        value: WatchFieldFormatters.formatAccuracy(watch.movement.accuracySpecPPD)
                    )
                    if let cert = watch.movement.chronometerCert {
                        SpecificationRow(label: "Chronometer Cert", value: cert.asString().capitalized)
                    }
                }
            }
        }
    }
    
    private var waterResistanceSection: some View {
        Group {
            if WatchFieldFormatters.hasWaterResistance(watch.water) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Water Resistance")
                    
                    SpecificationRow(
                        label: "Water Resistance",
                        value: WatchFieldFormatters.formatWaterResistance(watch.water.waterResistanceM)
                    )
                    if let crownType = watch.water.crownType {
                        SpecificationRow(label: "Crown Type", value: crownType.asString().capitalized)
                    }
                    SpecificationRow(label: "Crown Guard", boolValue: watch.water.crownGuard)
                }
            }
        }
    }
    
    private var strapDetailsSection: some View {
        Group {
            if WatchFieldFormatters.hasStrapDetails(watch.strapCurrent) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Strap/Bracelet")
                    
                    if let type = watch.strapCurrent.type {
                        SpecificationRow(label: "Type", value: type.asString().capitalized)
                    }
                    SpecificationRow(label: "Material", value: watch.strapCurrent.material)
                    SpecificationRow(label: "Color", value: watch.strapCurrent.color)
                    if let endLinks = watch.strapCurrent.endLinks {
                        SpecificationRow(label: "End Links", value: endLinks.asString().capitalized)
                    }
                    if let claspType = watch.strapCurrent.claspType {
                        SpecificationRow(label: "Clasp Type", value: claspType.asString().capitalized)
                    }
                    SpecificationRow(label: "Bracelet Links", value: watch.strapCurrent.braceletLinkCount)
                    SpecificationRow(label: "Quick Release", boolValue: watch.strapCurrent.quickRelease)
                }
            }
        }
    }
    
    private var ownershipInfoSection: some View {
        Group {
            if WatchFieldFormatters.hasOwnershipInfo(watch.ownership) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Ownership")
                    
                    if let dateAcquired = watch.ownership.dateAcquired {
                        SpecificationRow(
                            label: "Date Acquired",
                            value: DateFormatters.absoluteFormat(dateAcquired)
                        )
                    }
                    
                    SpecificationRow(label: "Purchased From", value: watch.ownership.purchasedFrom)
                    
                    if let price = watch.ownership.purchasePriceAmount {
                        SpecificationRow(
                            label: "Purchase Price",
                            value: WatchFieldFormatters.formatCurrency(
                                price,
                                currencyCode: watch.ownership.purchasePriceCurrency
                            )
                        )
                    }
                    
                    if let condition = watch.ownership.condition {
                        SpecificationRow(label: "Condition", value: condition.asString().capitalized)
                    }
                    SpecificationRow(
                        label: "Box & Papers",
                        value: WatchFieldFormatters.formatBoxPapers(watch.ownership.boxPapers)
                    )
                    
                    if let currentValue = watch.ownership.currentEstimatedValueAmount {
                        SpecificationRow(
                            label: "Current Est. Value",
                            value: WatchFieldFormatters.formatCurrency(
                                currentValue,
                                currencyCode: watch.ownership.currentEstimatedValueCurrency
                            )
                        )
                    }
                    
                    SpecificationRow(label: "Insurance Provider", value: watch.ownership.insuranceProvider)
                    SpecificationRow(label: "Policy Number", value: watch.ownership.insurancePolicyNumber)
                    
                    if let renewalDate = watch.ownership.insuranceRenewalDate {
                        SpecificationRow(
                            label: "Insurance Renewal",
                            value: DateFormatters.absoluteFormat(renewalDate)
                        )
                    }
                }
            }
        }
    }
    
    private var serviceHistorySection: some View {
        Group {
            if !watch.serviceHistory.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Service History")
                    
                    ForEach(watch.serviceHistory) { entry in
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            if let date = entry.date {
                                Text(DateFormatters.absoluteFormat(date))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                            
                            if let provider = entry.provider {
                                Text(provider)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            
                            if let work = entry.workDescription {
                                Text(work)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            
                            if let cost = entry.costAmount {
                                Text(WatchFieldFormatters.formatCurrency(cost, currencyCode: entry.costCurrency) ?? "")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        .padding(.vertical, AppSpacing.sm)
                        
                        if entry.id != watch.serviceHistory.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
    
    private var valuationsSection: some View {
        Group {
            if !watch.valuations.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Valuations")
                    
                    ForEach(watch.valuations) { entry in
                        HStack(alignment: .top, spacing: AppSpacing.md) {
                            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                if let date = entry.date {
                                    Text(DateFormatters.absoluteFormat(date))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                                
                                if let source = entry.source {
                                    Text(source.asString().capitalized)
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            if let value = entry.valueAmount {
                                Text(WatchFieldFormatters.formatCurrency(value, currencyCode: entry.valueCurrency) ?? "")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                        }
                        .padding(.vertical, AppSpacing.sm)
                        
                        if entry.id != watch.valuations.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
    
    private var strapInventorySection: some View {
        Group {
            if !watch.straps.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    DetailSectionHeader(title: "Strap Inventory")
                    
                    ForEach(watch.straps) { strap in
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack(spacing: AppSpacing.sm) {
                                if let type = strap.type {
                                    Text(type.asString().capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                                
                                if let material = strap.material {
                                    Text("• \(material)")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                
                                if let color = strap.color {
                                    Text("• \(color)")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                
                                if let width = strap.widthMM {
                                    Text("• \(width)mm")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            
                            if let claspType = strap.claspType {
                                Text("Clasp: \(claspType.asString().capitalized)")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            
                            if strap.quickRelease {
                                Text("Quick Release")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                        .padding(.vertical, AppSpacing.sm)
                        
                        if strap.id != watch.straps.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
    
    private var achievementsSection: some View {
        Group {
            if !watchAchievements.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    DetailSectionHeader(title: "Achievements")
                    
                    FlowLayout(spacing: AppSpacing.md) {
                        ForEach(watchAchievements, id: \.achievement.id) { item in
                            AchievementBadge(
                                achievement: item.achievement,
                                state: item.state
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var watchAchievements: [(achievement: Achievement, state: AchievementState?)] {
        // Filter to only show unlocked achievements related to this watch
        achievements.filter { $0.state?.isUnlocked == true }
    }
    
    // MARK: - Data Loading
    
    private func loadData() async {
        await loadStatistics()
        await loadAchievements()
    }
    
    private func loadStatistics() async {
        do {
            wearCount = try await watchRepository.wearCountForWatch(watchId: watch.id)
            lastWorn = try await watchRepository.lastWornDate(watchId: watch.id)
        } catch {
            print("Failed to load statistics: \(error)")
        }
    }
    
    private func loadAchievements() async {
        do {
            // Initialize achievement states if needed
            try await achievementRepository.initializeUserStates()
            
            // Load achievements - for now, load watch-specific achievements
            // like "Favorite Watch" (worn 10 times), "True Love" (worn 50 times), etc.
            let allAchievements = try await achievementRepository.fetchAchievementsWithStates()
            
            // Filter to achievements that could be related to this specific watch
            achievements = allAchievements.filter { item in
                // Include single-watch wear count achievements if this watch has enough wears
                switch item.achievement.unlockCriteria {
                case .singleWatchWornCount(let count):
                    return wearCount >= count
                default:
                    return false
                }
            }
        } catch {
            // Silently fail - achievements are not critical
            print("Failed to load achievements: \(error)")
        }
    }

    private var photoGallery: some View {
        VStack(alignment: .leading, spacing: 8) {
            if watch.photos.isEmpty {
                Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 220).overlay(Text("No photos").foregroundColor(.secondary))
            } else {
                TabView(selection: $galleryIndex) {
                    ForEach(Array(watch.photos.enumerated()), id: \.offset) { idx, photo in
                        let img = PhotoStoreV2.loadImage(at: (try? PhotoStoreV2.originalURL(watchId: watch.id, photoId: photo.id)) ?? URL(fileURLWithPath: "/dev/null"))
                        Group {
                            if let img { Image(uiImage: img).resizable().scaledToFill() }
                            else { Rectangle().fill(Color.secondary.opacity(0.2)) }
                        }
                        .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: 280)
            }
        }
    }
}
