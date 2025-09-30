import SwiftUI

public struct WatchV2DetailView: View {
    public let watch: WatchV2
    @State private var galleryIndex: Int = 0
    @State private var showEditForm: Bool = false
    @State private var achievements: [(achievement: Achievement, state: AchievementState?)] = []
    
    private let achievementRepository: AchievementRepository = AchievementRepositoryGRDB()
    private let watchRepository: WatchRepositoryV2 = WatchRepositoryGRDB()

    public init(watch: WatchV2) {
        self.watch = watch
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                photoGallery
                CollapsibleSection(title: "Core", initiallyExpanded: false) {
                    KeyValueRow("Manufacturer", watch.manufacturer)
                    KeyValueRow("Line", watch.line)
                    KeyValueRow("Model", watch.modelName)
                    KeyValueRow("Reference", watch.referenceNumber)
                    KeyValueRow("Nickname", watch.nickname)
                }
                CollapsibleSection(title: "Additional Details", initiallyExpanded: false) {
                    KeyValueRow("Serial Number", watch.serialNumber)
                    KeyValueRow("Production Year", watch.productionYear.map(String.init))
                    KeyValueRow("Country", watch.countryOfOrigin)
                    KeyValueRow("Limited Edition", watch.limitedEditionNumber)
                    KeyValueRow("Notes", watch.notes)
                    if !watch.tags.isEmpty { KeyValueRow("Tags", watch.tags.joined(separator: ", ")) }
                }
                
                if !watchAchievements.isEmpty {
                    CollapsibleSection(title: "Achievements", initiallyExpanded: false) {
                        achievementsContent
                    }
                }
            }
            .padding()
        }
        .navigationTitle(watch.nickname ?? watch.modelName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showEditForm = true
                }
            }
        }
        .sheet(isPresented: $showEditForm) {
            NavigationView {
                WatchV2FormView(watch: watch)
            }
        } onDismiss: {
            // Reload achievements after edit (watch data may have changed)
            Task {
                await loadAchievements()
            }
        }
        .task {
            await loadAchievements()
        }
    }
    
    private var achievementsContent: some View {
        VStack(spacing: 12) {
            ForEach(watchAchievements, id: \.achievement.id) { item in
                AchievementCard(
                    achievement: item.achievement,
                    state: item.state
                )
            }
        }
    }
    
    private var watchAchievements: [(achievement: Achievement, state: AchievementState?)] {
        // Filter to only show unlocked achievements related to this watch
        achievements.filter { $0.state?.isUnlocked == true }
    }
    
    private func loadAchievements() async {
        do {
            // Initialize achievement states if needed
            try await achievementRepository.initializeUserStates()
            
            // Load achievements - for now, load watch-specific achievements
            // like "Favorite Watch" (worn 10 times), "True Love" (worn 50 times), etc.
            let allAchievements = try await achievementRepository.fetchAchievementsWithStates()
            let wearCount = try await watchRepository.wearCountForWatch(watchId: watch.id)
            
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

private struct KeyValueRow: View {
    let key: String
    let value: String

    init(_ key: String, _ value: String?) {
        self.key = key
        self.value = value ?? "—"
    }

    var body: some View {
        HStack {
            Text(key).foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}


