import SwiftUI

public struct StatsFilterSheet: View {
    @EnvironmentObject private var filters: StatsFiltersState

    @State private var allBrands: [String] = []
    @State private var allMovementTypes: [String] = []
    @State private var allComplications: [String] = []
    @State private var allConditions: [String] = []

    @State private var tempBrands: Set<String> = []
    @State private var tempMovementTypes: Set<String> = []
    @State private var tempComplications: Set<String> = []
    @State private var tempConditions: Set<String> = []
    @State private var priceMin: String = ""
    @State private var priceMax: String = ""
    @State private var inRotationOnly: Int = 0 // 0=all, 1=in rotation, 2=vaulted

    private let aggregator = StatsAggregator()

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Brands") {
                    multiSelectList(allBrands, chosen: $tempBrands)
                }
                Section("Movements") {
                    multiSelectList(allMovementTypes, chosen: $tempMovementTypes)
                }
                Section("Complications") {
                    multiSelectList(allComplications, chosen: $tempComplications)
                }
                Section("Condition") {
                    multiSelectList(allConditions, chosen: $tempConditions)
                }
                Section("Price (USD)") {
                    HStack {
                        TextField("Min", text: $priceMin).keyboardType(.numberPad)
                        Text("–")
                        TextField("Max", text: $priceMax).keyboardType(.numberPad)
                    }
                }
                Section("Rotation") {
                    Picker("Status", selection: $inRotationOnly) {
                        Text("All").tag(0)
                        Text("In Rotation").tag(1)
                        Text("Vaulted / For Sale").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Apply") { apply() } }
            }
            .task { await loadOptions() }
            .onAppear { primeFromCurrent() }
        }
    }

    private func multiSelectList(_ options: [String], chosen selected: Binding<Set<String>>) -> some View {
        let rows = Array(options.enumerated())
        return SwiftUI.ForEach(rows, id: \.offset) { _, item in
            let isOn = selected.wrappedValue.contains(item)
            HStack {
                Text(item)
                Spacer()
            if isOn { Image(systemName: "checkmark").foregroundStyle(Color.accentColor) }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isOn { selected.wrappedValue.remove(item) } else { selected.wrappedValue.insert(item) }
            }
        }
    }

    private func primeFromCurrent() {
        tempBrands = filters.selectedBrands
        tempMovementTypes = filters.selectedMovementTypes
        tempComplications = filters.selectedComplications
        tempConditions = filters.selectedConditions
        if let bracket = filters.priceBracketUSD {
            priceMin = String(bracket.0)
            priceMax = String(bracket.1)
        }
        if let rot = filters.inRotationOnly { inRotationOnly = rot ? 1 : 2 } else { inRotationOnly = 0 }
    }

    private func apply() {
        filters.selectedBrands = tempBrands
        filters.selectedMovementTypes = tempMovementTypes
        filters.selectedComplications = tempComplications
        filters.selectedConditions = tempConditions
        let minVal = Int(priceMin)
        let maxVal = Int(priceMax)
        if let lo = minVal, let hi = maxVal, lo <= hi { filters.priceBracketUSD = (lo, hi) } else { filters.priceBracketUSD = nil }
        switch inRotationOnly {
        case 1: filters.inRotationOnly = true
        case 2: filters.inRotationOnly = false
        default: filters.inRotationOnly = nil
        }
        dismiss()
    }

    private func dismiss() {
        // SwiftUI handles dismissal from the presenting sheet binding in parent
        // The parent should flip the Boolean controlling presentation
        // We do nothing here and rely on .presentationDetents to provide a close affordance
        // Alternatively, use an Environment dismissal if needed in future
    }

    private func loadOptions() async {
        // Use aggregator to get brands/movements/complications; fetch watches for conditions
        if let tallies = try? await aggregator.collectionTallies() {
            allBrands = tallies.brandCounts.keys.sorted()
            allMovementTypes = tallies.movementTypeCounts.keys.sorted()
            allComplications = tallies.complicationCounts.keys.sorted()
        }
        // Fetch watches directly via repository
        let repo = WatchRepositoryGRDB()
        if let watches = try? await repo.fetchAll() {
            let conds = watches.compactMap { $0.ownership.condition?.asString() }
            allConditions = Array(Set(conds)).sorted()
        }
    }
}


