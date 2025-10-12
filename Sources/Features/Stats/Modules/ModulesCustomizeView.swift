import SwiftUI

public struct ModulesCustomizeView: View {
    public init() {}

    @State private var selected: Tab = .collection

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Tab", selection: $selected) {
                Text("Collection").tag(Tab.collection)
                Text("Wearing").tag(Tab.wearing)
                Text("Finance").tag(Tab.finance)
                Text("Fun").tag(Tab.fun)
            }
            .pickerStyle(.segmented)

            switch selected {
            case .collection: CollectionToggles()
            case .wearing: WearingToggles()
            case .finance: FinanceToggles()
            case .fun: FunToggles()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Customize Modules")
        .navigationBarTitleDisplayMode(.inline)
    }

    public enum Tab { case collection, wearing, finance, fun }
}

// MARK: - Toggles

private struct CollectionToggles: View {
    @AppStorage("stats.collection.showSummary") private var showSummary: Bool = true
    @AppStorage("stats.collection.showComposition") private var showComposition: Bool = true
    @AppStorage("stats.collection.showTimeline") private var showTimeline: Bool = true
    @AppStorage("stats.collection.showDistributions") private var showDistributions: Bool = true
    @AppStorage("stats.collection.showService") private var showService: Bool = true
    @AppStorage("stats.collection.showBoxPapers") private var showBoxPapers: Bool = true

    var body: some View {
        Form {
            Section("Collection Modules") {
                Toggle("Summary", isOn: $showSummary)
                Toggle("Composition", isOn: $showComposition)
                Toggle("Acquisition Timeline", isOn: $showTimeline)
                Toggle("Distributions", isOn: $showDistributions)
                Toggle("Service Overview", isOn: $showService)
                Toggle("Box/Papers", isOn: $showBoxPapers)
            }
        }
    }
}

private struct WearingToggles: View {
    @AppStorage("stats.wearing.showMostWorn") private var showMostWorn: Bool = true
    @AppStorage("stats.wearing.showRotationBalance") private var showRotationBalance: Bool = true
    @AppStorage("stats.wearing.showNeglect") private var showNeglect: Bool = true
    @AppStorage("stats.wearing.showStreaks") private var showStreaks: Bool = true
    @AppStorage("stats.wearing.showHeatmap") private var showHeatmap: Bool = true
    @AppStorage("stats.wearing.showWeekdayWeekend") private var showWeekdayWeekend: Bool = true

    var body: some View {
        Form {
            Section("Wearing Modules") {
                Toggle("Most Worn", isOn: $showMostWorn)
                Toggle("Rotation Balance", isOn: $showRotationBalance)
                Toggle("Neglect Index", isOn: $showNeglect)
                Toggle("Streaks", isOn: $showStreaks)
                Toggle("Calendar Heatmap", isOn: $showHeatmap)
                Toggle("Weekday vs Weekend", isOn: $showWeekdayWeekend)
            }
        }
    }
}

private struct FinanceToggles: View {
    @AppStorage("stats.finance.showPortfolio") private var showPortfolio: Bool = true
    @AppStorage("stats.finance.showSpend") private var showSpend: Bool = true
    @AppStorage("stats.finance.showLiquidity") private var showLiquidity: Bool = true

    var body: some View {
        Form {
            Section("Finance Modules") {
                Toggle("Portfolio vs Cost", isOn: $showPortfolio)
                Toggle("Spend by Year/Brand", isOn: $showSpend)
                Toggle("Liquidity Scenario", isOn: $showLiquidity)
            }
        }
    }
}

private struct FunToggles: View {
    @AppStorage("stats.fun.showHeatmaps") private var showHeatmaps: Bool = true
    @AppStorage("stats.fun.showRotationHealth") private var showRotationHealth: Bool = true
    @AppStorage("stats.fun.showBrandBingo") private var showBrandBingo: Bool = true
    @AppStorage("stats.fun.showComplicationRadar") private var showComplicationRadar: Bool = true
    @AppStorage("stats.fun.showTopEvents") private var showTopEvents: Bool = true
    @AppStorage("stats.fun.showNeglectedNudge") private var showNeglectedNudge: Bool = true
    @AppStorage("stats.fun.showAchievements") private var showAchievements: Bool = true

    var body: some View {
        Form {
            Section("Fun Modules") {
                Toggle("Heatmap Recaps", isOn: $showHeatmaps)
                Toggle("Rotation Health", isOn: $showRotationHealth)
                Toggle("Brand Bingo", isOn: $showBrandBingo)
                Toggle("Complication Radar", isOn: $showComplicationRadar)
                Toggle("Top Events", isOn: $showTopEvents)
                Toggle("Neglected Nudge", isOn: $showNeglectedNudge)
                Toggle("Achievements", isOn: $showAchievements)
            }
        }
    }
}


