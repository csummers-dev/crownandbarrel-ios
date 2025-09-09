import SwiftUI

/// RootView is the shell of the application.
/// - What: Hosts a `NavigationStack` with a `TabView` for the main sections (Collection, Stats, Calendar) and a trailing settings menu.
/// - Why: A tabbed structure offers clear, predictable navigation and keeps top-level actions (settings/app data) readily accessible.
/// - How: Each tab embeds a feature entry view. The settings menu uses `NavigationLink`s, so screens push on the current stack.

struct RootView: View {
    var body: some View {
        NavigationStack {
            TabView {
                CollectionView()
                    .tabItem { Label("Collection", systemImage: "rectangle.grid.2x2") }

                StatsView()
                    .tabItem { Label("Stats", systemImage: "chart.bar") }

                CalendarView()
                    .tabItem { Label("Calendar", systemImage: "calendar") }
            }
            .navigationTitle("Good Watch")
            .toolbar {
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
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}


