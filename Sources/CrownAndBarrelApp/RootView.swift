import SwiftUI

/// RootView is the shell of the application.
/// - What: Hosts a `NavigationStack` with a `TabView` for the main sections (Collection, Stats, Calendar) and a trailing settings menu.
/// - Why: A tabbed structure offers clear, predictable navigation and keeps top-level actions (settings/app data) readily accessible.
/// - How: Each tab embeds a feature entry view. The settings menu uses `NavigationLink`s, so screens push on the current stack.

struct RootView: View {
    // MARK: - Types

    /// Represents the different sheet presentations available from the settings menu.
    /// - What: Defines the possible modal sheets that can be presented.
    /// - Why: Type-safe sheet management with clear identification.
    /// - How: Conforms to Identifiable for use with SwiftUI sheet presentation.
    private enum PresentedSheet: Identifiable {
        case settings, appData, privacy, about

        var id: String {
            switch self {
            case .settings: return "settings"
            case .appData: return "appData"
            case .privacy: return "privacy"
            case .about: return "about"
            }
        }
    }

    /// Represents the main navigation tabs in the app.
    /// - What: Defines the three primary navigation destinations.
    /// - Why: Type-safe tab management with haptic feedback integration.
    /// - How: String raw values match display names for consistency.
    private enum Tab: String, CaseIterable {
        case collection = "Collection"
        case stats = "Stats"
        case calendar = "Calendar"
    }

    // MARK: - State Properties

    /// Currently presented modal sheet, if any.
    /// - What: Tracks which settings-related sheet is currently being displayed.
    /// - Why: Manages modal presentation state for settings, app data, privacy, and about screens.
    @State private var activeSheet: PresentedSheet?

    /// Currently selected tab in the main navigation.
    /// - What: Tracks which tab is currently active (Collection, Stats, or Calendar).
    /// - Why: Enables haptic feedback on tab changes and maintains tab state.
    @State private var selectedTab: Tab = .collection

    /// Controls the visibility of the settings menu confirmation dialog.
    /// - What: Boolean state for showing/hiding the settings menu options.
    /// - Why: Enables haptic feedback when the gear icon is tapped to open the menu.
    @State private var showingSettingsMenu: Bool = false

    // MARK: - Environment Properties

    /// Theme change token injected at the app level.
    /// - What: A simple `String` environment value that changes whenever the user selects a different theme.
    /// - Why: Forces SwiftUI to re-render views that depend on theme tokens without rebuilding navigation stacks.
    /// - How: Applied as an `.id(themeToken)` on containers and sheet roots so headers and bodies update in sync.
    @Environment(\.themeToken) private var themeToken

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                WatchV2ListView()
                .navigationTitle(Brand.appDisplayName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    settingsToolbar
                }
            }
            .tabItem { Label("Collection", systemImage: "rectangle.grid.2x2") }
            .tag(Tab.collection)

            NavigationStack {
                StatsView()
                    .navigationTitle("Stats")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        settingsToolbar
                    }
            }
            .tabItem { Label("Stats", systemImage: "chart.bar") }
            .tag(Tab.stats)

            NavigationStack {
                CalendarView()
                    .navigationTitle("Calendar")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        settingsToolbar
                    }
            }
            .tabItem { Label("Calendar", systemImage: "calendar") }
            .tag(Tab.calendar)
        }
        .id(themeToken) // Force TabView rebuild when theme changes for immediate color updates
        .background(AppColors.background.ignoresSafeArea())
        .onChange(of: selectedTab) { _, _ in
            // What: Provide haptic feedback when user switches between tabs
            // Why: Gives tactile confirmation of navigation changes for improved UX
            // How: Use debounced haptic to prevent overwhelming feedback during rapid tab switching
            Haptics.debouncedHaptic {
                Haptics.navigationInteraction(.tabChanged)
            }
        }
        // Expose minimal theme info for UITests in DEBUG via an invisible, accessible element
        .overlay(alignment: .topLeading) {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--uiTestExposeThemeInfo") {
                let forcedArg = ProcessInfo.processInfo.arguments.first { $0.hasPrefix("--uiTestForceSystemStyle=") }
                let forcedValue = forcedArg?.split(separator: "=").last.map(String.init)
                let detectedStyle: String = {
                    if let v = forcedValue?.lowercased(), v == "dark" { return "dark" }
                    if let v = forcedValue?.lowercased(), v == "light" { return "light" }
                    return UITraitCollection.current.userInterfaceStyle == .dark ? "dark" : "light"
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

    // MARK: - UI Components

    /// Settings and utilities menu shown on the trailing side of the navigation bar.
    /// - What: Presents app-level destinations (Settings, App Data, Privacy, About) via a confirmation dialog.
    /// - Why: Keeps the primary navigation uncluttered while exposing infrequent actions with haptic feedback.
    /// - How: Uses a Button that triggers a confirmation dialog, providing haptic feedback on gear tap.
    ///        Includes stable accessibility identifier for robust UI tests.
    private var settingsToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: openSettingsMenu) {
                Image(systemName: "gearshape")
                    .foregroundStyle(AppColors.accent)
                    .symbolRenderingMode(.monochrome)
                    .accessibilityIdentifier("SettingsMenuButton")
            }
            .confirmationDialog(
                "Settings",
                isPresented: $showingSettingsMenu,
                titleVisibility: .hidden
            ) {
                Button("Settings") {
                    handleMenuSelection(.settings)
                }
                Button("App Data") {
                    handleMenuSelection(.appData)
                }
                Button("Privacy Policy") {
                    handleMenuSelection(.privacy)
                }
                Button("About") {
                    handleMenuSelection(.about)
                }
                Button("Cancel", role: .cancel) {
                    // No action needed for cancel
                }
            }
        }
    }

    // MARK: - Private Methods

    /// Handles opening the settings menu with haptic feedback.
    /// - What: Triggers haptic feedback and shows the settings menu dialog.
    /// - Why: Provides tactile confirmation when user taps the settings gear icon.
    /// - How: Uses `navigationInteraction(.menuOpened)` for selection feedback.
    private func openSettingsMenu() {
        Haptics.navigationInteraction(.menuOpened)
        showingSettingsMenu = true
    }

    /// Handles menu item selection with haptic feedback and sheet presentation.
    /// - Parameter sheet: The sheet to present after providing haptic feedback.
    /// - What: Provides haptic feedback and presents the selected sheet.
    /// - Why: Ensures consistent haptic feedback for all menu selections.
    /// - How: Uses `navigationInteraction(.menuItemSelected)` for collection interaction feedback.
    private func handleMenuSelection(_ sheet: PresentedSheet) {
        Haptics.navigationInteraction(.menuItemSelected)
        activeSheet = sheet
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
