import SwiftUI

public struct StatsFilterBar: View {
    @EnvironmentObject private var filters: StatsFiltersState
    @State private var showingSheet: Bool = false

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Preset range selector
            Picker("Range", selection: $filters.selectedPreset) {
                Text("7D").tag(StatsDateRangePreset.sevenDays)
                Text("30D").tag(StatsDateRangePreset.thirtyDays)
                Text("90D").tag(StatsDateRangePreset.ninetyDays)
                Text("YTD").tag(StatsDateRangePreset.ytd)
                Text("All").tag(StatsDateRangePreset.all)
                Text("Custom").tag(StatsDateRangePreset.custom)
            }
            .pickerStyle(.segmented)

            if filters.selectedPreset == .custom {
                HStack {
                    DatePicker("Start", selection: Binding(get: { filters.customStartDate ?? Date() }, set: { filters.customStartDate = $0 }), displayedComponents: .date)
                    DatePicker("End", selection: Binding(get: { filters.customEndDate ?? Date() }, set: { filters.customEndDate = $0 }), displayedComponents: .date)
                }
            }

            // Selected filter chips (display only; future: open filter sheet)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Button {
                        showingSheet = true
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .buttonStyle(.bordered)
                    .sheet(isPresented: $showingSheet) {
                        StatsFilterSheet().environmentObject(filters)
                    }

                    ForEach(Array(filters.selectedBrands).sorted(), id: \.self) { brand in
                        chip(brand) { filters.selectedBrands.remove(brand) }
                    }
                    ForEach(Array(filters.selectedMovementTypes).sorted(), id: \.self) { mt in
                        chip(mt) { filters.selectedMovementTypes.remove(mt) }
                    }
                    ForEach(Array(filters.selectedComplications).sorted(), id: \.self) { c in
                        chip(c) { filters.selectedComplications.remove(c) }
                    }
                    ForEach(Array(filters.selectedConditions).sorted(), id: \.self) { cond in
                        chip(cond) { filters.selectedConditions.remove(cond) }
                    }
                    if let bracket = filters.priceBracketUSD {
                        chip("$\(bracket.0)–$\(bracket.1)") { filters.priceBracketUSD = nil }
                    }
                    if let inRot = filters.inRotationOnly {
                        chip(inRot ? "In Rotation" : "Vaulted") { filters.inRotationOnly = nil }
                    }
                    if isAnyFilterActive {
                        Button("Clear") { clearFilters() }.buttonStyle(.borderless)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var isAnyFilterActive: Bool {
        !filters.selectedBrands.isEmpty ||
        !filters.selectedMovementTypes.isEmpty ||
        !filters.selectedComplications.isEmpty ||
        !filters.selectedConditions.isEmpty ||
        filters.priceBracketUSD != nil ||
        filters.inRotationOnly != nil
    }

    private func clearFilters() {
        filters.selectedBrands.removeAll()
        filters.selectedMovementTypes.removeAll()
        filters.selectedComplications.removeAll()
        filters.selectedConditions.removeAll()
        filters.priceBracketUSD = nil
        filters.inRotationOnly = nil
    }

    private func chip(_ text: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(text).font(.caption)
            Image(systemName: "xmark.circle.fill").font(.caption2).onTapGesture { onRemove() }
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Color.secondary.opacity(0.15))
        .clipShape(Capsule())
    }
}


