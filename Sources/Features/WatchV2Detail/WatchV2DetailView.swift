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
                
                // Placeholder for remaining sections (will be implemented in subsequent tasks)
                Text("Additional sections coming soon...")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.vertical, AppSpacing.md)
                
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
