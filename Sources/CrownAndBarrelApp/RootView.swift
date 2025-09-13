import SwiftUI

/// RootView is the shell of the application.
/// - What: Hosts a `NavigationStack` with a `TabView` for the main sections (Collection, Stats, Calendar) and a trailing settings menu.
/// - Why: A tabbed structure offers clear, predictable navigation and keeps top-level actions (settings/app data) readily accessible.
/// - How: Each tab embeds a feature entry view. The settings menu uses `NavigationLink`s, so screens push on the current stack.

struct RootView: View {
    private enum PresentedSheet: Identifiable {
        case settings, appData, privacy, about
        var id: String {
            switch self { case .settings: "settings"; case .appData: "appData"; case .privacy: "privacy"; case .about: "about" }
        }
    }

    @State private var activeSheet: PresentedSheet? = nil
    /// Theme change token injected at the app level.
    /// - What: A simple `String` environment value that changes whenever the user selects a different theme.
    /// - Why: Forces SwiftUI to re-render views that depend on theme tokens without rebuilding navigation stacks.
    /// - How: Applied as an `.id(themeToken)` on containers and sheet roots so headers and bodies update in sync.
    @Environment(\.themeToken) private var themeToken

    var body: some View {
        TabView {
            NavigationStack {
                CollectionView()
                    .navigationTitle(Brand.appDisplayName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        settingsToolbar
                        ToolbarItem(placement: .principal) {
                            Text(Brand.appDisplayName)
                                .font(AppTypography.titleCompact)
                                .foregroundStyle(AppColors.textSecondary)
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
                            Text("Stats").font(AppTypography.titleCompact).foregroundStyle(AppColors.textSecondary)
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
                            Text("Calendar").font(AppTypography.titleCompact).foregroundStyle(AppColors.textSecondary)
                        }
                    }
            }
            .tabItem { Label("Calendar", systemImage: "calendar") }
        }
        .background(AppColors.background.ignoresSafeArea())
        // Tag the tab container so all tabs and their headers react instantly to theme changes
        .id(themeToken)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            // Tag the sheet's NavigationStack with the theme token so its header refreshes at the same time as the body.
            case .settings: NavigationStack { SettingsView() }.id(themeToken)
            case .appData: NavigationStack { AppDataView() }
            case .privacy: NavigationStack { PrivacyPolicyView() }
            case .about: NavigationStack { AboutView() }
            }
        }
    }

    private var settingsToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button("Settings") { activeSheet = .settings }
                Button("App Data") { activeSheet = .appData }
                Button("Privacy Policy") { activeSheet = .privacy }
                Button("About") { activeSheet = .about }
            } label: {
                Image(systemName: "gearshape").foregroundStyle(AppColors.accent)
                    .symbolRenderingMode(.monochrome)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}


