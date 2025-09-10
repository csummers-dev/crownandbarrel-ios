import SwiftUI

/// RootView is the shell of the application.
/// - What: Hosts a `NavigationStack` with a `TabView` for the main sections (Collection, Stats, Calendar) and a trailing settings menu.
/// - Why: A tabbed structure offers clear, predictable navigation and keeps top-level actions (settings/app data) readily accessible.
/// - How: Each tab embeds a feature entry view. The settings menu uses `NavigationLink`s, so screens push on the current stack.

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                CollectionView()
                    .navigationTitle("Good Watch")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        settingsToolbar
                        ToolbarItem(placement: .principal) {
                            Text("Good Watch")
                                .font(AppTypography.titleCompact)
                                .foregroundStyle(AppColors.brandGold)
                        }
                    }
            }
            .tabItem { Label("Collection", systemImage: "rectangle.grid.2x2") }

            NavigationStack {
                StatsView()
                    .navigationTitle("Stats")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        settingsToolbar
                        ToolbarItem(placement: .principal) {
                            Text("Stats").font(AppTypography.titleCompact).foregroundStyle(AppColors.brandGold)
                        }
                    }
            }
            .tabItem { Label("Stats", systemImage: "chart.bar") }

            NavigationStack {
                CalendarView()
                    .navigationTitle("Calendar")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        settingsToolbar
                        ToolbarItem(placement: .principal) {
                            Text("Calendar").font(AppTypography.titleCompact).foregroundStyle(AppColors.brandGold)
                        }
                    }
            }
            .tabItem { Label("Calendar", systemImage: "calendar") }
        }
    }

    private var settingsToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                NavigationLink("Settings") { SettingsView() }
                NavigationLink("App Data") { AppDataView() }
                NavigationLink("Privacy Policy") { PrivacyPolicyView() }
                NavigationLink("About") { AboutView() }
            } label: {
                Image(systemName: "gearshape")
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}


