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
                                .foregroundStyle(AppColors.accent)
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
                            Text("Stats").font(AppTypography.titleCompact).foregroundStyle(AppColors.accent)
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
                            Text("Calendar").font(AppTypography.titleCompact).foregroundStyle(AppColors.accent)
                        }
                    }
            }
            .tabItem { Label("Calendar", systemImage: "calendar") }
        }
        .tint(AppColors.accent)
        .id(themeToken + "-tabs")
        .background(AppColors.background.ignoresSafeArea())
        // Expose minimal theme info for UITests in DEBUG via an invisible, accessible element
        .overlay(alignment: .topLeading) {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--uiTestExposeThemeInfo") {
                let forcedArg = ProcessInfo.processInfo.arguments.first { $0.hasPrefix("--uiTestForceSystemStyle=") }
                let forcedValue = forcedArg?.split(separator: "=").last.map(String.init)
                let detectedStyle: String = {
                    if let v = forcedValue?.lowercased(), v == "dark" { return "dark" }
                    if let v = forcedValue?.lowercased(), v == "light" { return "light" }
                    return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
                }()
                let themeId = UserDefaults.standard.string(forKey: "selectedThemeId") ?? ""
                Text("system:\(detectedStyle);theme:\(themeId)")
                    .accessibilityIdentifier("UITestThemeInfo")
                    .opacity(0.01)
            }
            #endif
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .settings: NavigationStack { SettingsView().id(themeToken + "-settings") }
            case .appData: NavigationStack { AppDataView() }
            case .privacy: NavigationStack { PrivacyPolicyView() }
            case .about: NavigationStack { AboutView() }
            }
        }
        .onAppear {
            #if DEBUG
            // Allow UI tests to open Settings directly without tapping toolbar UI
            if ProcessInfo.processInfo.arguments.contains("--uiTestOpenSettings") {
                // Present only if not already shown
                if activeSheet == nil { activeSheet = .settings }
            }
            // Allow UI tests to open Privacy Policy directly without tapping the toolbar menu
            if ProcessInfo.processInfo.arguments.contains("--uiTestOpenPrivacy") {
                if activeSheet == nil { activeSheet = .privacy }
            }
            // Allow UI tests to open App Data directly without tapping the toolbar menu
            if ProcessInfo.processInfo.arguments.contains("--uiTestOpenAppData") {
                if activeSheet == nil { activeSheet = .appData }
            }
            #endif
        }
    }

    /// Settings and utilities menu shown on the trailing side of the navigation bar.
    /// - What: Presents app-level destinations (Settings, App Data, Privacy, About) as a `Menu`.
    /// - Why: Keeps the primary navigation uncluttered while exposing infrequent actions.
    /// - How: Uses a stable accessibility identifier on the label for robust UI tests.
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
                    .accessibilityIdentifier("SettingsMenuButton")
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}


