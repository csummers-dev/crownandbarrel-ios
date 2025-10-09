import SwiftUI

public struct WatchV2ListView: View {
    @StateObject private var viewModel = WatchV2ListViewModel()
    @State private var showFilters: Bool = false
    @State private var showAddWatch: Bool = false
    @State private var isGridView: Bool = true
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Search Bar and Controls - Always visible
                HStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search watches...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($isSearchFocused)
                            .onSubmit {
                                isSearchFocused = false
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                    // Sort Button
                    Menu {
                        Button("Manufacturer A-Z") { 
                            viewModel.sort = .manufacturerLineModel
                            viewModel.load()
                        }
                        Button("Recently Updated") { 
                            viewModel.sort = .updatedAtDesc
                            viewModel.load()
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundStyle(.primary)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    
                    // View Toggle - Always reserve space to prevent layout shifts
                    Button(action: { 
                        if !viewModel.watches.isEmpty {
                            isGridView.toggle() 
                        }
                    }) {
                        Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                            .foregroundStyle(viewModel.watches.isEmpty ? .clear : .primary)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.watches.isEmpty)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
                
                // Content - Use consistent ScrollView wrapper for both states
                // FIXED: Search bar repositioning bug - both empty and populated states now use
                // the same ScrollView container to prevent layout shifts when switching between
                // search results and empty state. Previously empty state used VStack while
                // populated state used ScrollView/LazyVGrid or List, causing different layout
                // calculations and search bar position changes.
                ScrollView {
                    if viewModel.watches.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("No watches found")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("Add your first watch to get started")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                            
                            Button(action: { showAddWatch = true }) {
                                Label("Add Watch", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.accentColor)
                                    .cornerRadius(8)
                            }
                            
                            #if DEBUG
                            Button("Generate Test Data") {
                                DevSeedV2.generateTestData()
                                viewModel.load()
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            #endif
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 400) // Ensure consistent height
                    } else {
                        if isGridView {
                            // Grid View - Fixed-size square items in 2-column layout
                            LazyVGrid(columns: [
                                GridItem(.fixed(176), spacing: AppSpacing.sm),
                                GridItem(.fixed(176), spacing: AppSpacing.sm)
                            ], spacing: AppSpacing.lg) {
                                ForEach(viewModel.watches, id: \.id) { watch in
                                    NavigationLink(destination: WatchV2DetailView(watch: watch)) {
                                        WatchGridCard(watch: watch)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.top, AppSpacing.sm)
                        } else {
                            // List View - Fixed-height items with tighter spacing for cleaner visual clarity
                            LazyVStack(spacing: AppSpacing.xs) {
                                ForEach(viewModel.watches, id: \.id) { watch in
                                    NavigationLink(destination: WatchV2DetailView(watch: watch)) {
                                        WatchListRow(watch: watch)
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                }
                .onTapGesture {
                    isSearchFocused = false
                }
            }
            .onAppear { viewModel.load() }
            .onChange(of: searchText) { _, newValue in
                viewModel.filters.searchText = newValue.isEmpty ? nil : newValue
                viewModel.load()
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showAddWatch, onDismiss: {
                // Reload watches after form is dismissed (watch may have been added)
                viewModel.load()
            }) {
                NavigationView {
                    WatchV2FormView(watch: WatchV2(manufacturer: "", modelName: ""))
                }
            }
            
            // Floating Add Button
            Button(action: { showAddWatch = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(Circle().fill(Color.accentColor))
                    .shadow(radius: 6)
            }
            .padding()
            .accessibilityLabel("Add watch")
        }
    }
    
    private struct FilterSheet: View {
        @ObservedObject var viewModel: WatchV2ListViewModel
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationView {
                Form {
                    Section("Identity") {
                        TextField("Manufacturer", text: Binding(get: { viewModel.filters.manufacturer ?? "" }, set: { viewModel.filters.manufacturer = $0.isEmpty ? nil : $0 }))
                        TextField("Line/Collection", text: Binding(get: { viewModel.filters.line ?? "" }, set: { viewModel.filters.line = $0.isEmpty ? nil : $0 }))
                        TextField("Country of Origin", text: Binding(get: { viewModel.filters.countryOfOrigin ?? "" }, set: { viewModel.filters.countryOfOrigin = $0.isEmpty ? nil : $0 }))
                        Toggle("Has Photos", isOn: Binding(get: { viewModel.filters.hasPhotos ?? false }, set: { viewModel.filters.hasPhotos = $0 }))
                    }
                    Section("Specs") {
                        TextField("Movement Type", text: Binding(get: { viewModel.filters.movementType ?? "" }, set: { viewModel.filters.movementType = $0.isEmpty ? nil : $0 }))
                        HStack {
                            Stepper(value: Binding(get: { viewModel.filters.waterResistanceMin ?? 0 }, set: { viewModel.filters.waterResistanceMin = $0 == 0 ? nil : $0 }), in: 0...2000) { Text("WR min: \(viewModel.filters.waterResistanceMin.map(String.init) ?? "—")") }
                            Stepper(value: Binding(get: { viewModel.filters.waterResistanceMax ?? 0 }, set: { viewModel.filters.waterResistanceMax = $0 == 0 ? nil : $0 }), in: 0...2000) { Text("WR max: \(viewModel.filters.waterResistanceMax.map(String.init) ?? "—")") }
                        }
                    }
                    Section("Ownership") {
                        TextField("Condition", text: Binding(get: { viewModel.filters.condition ?? "" }, set: { viewModel.filters.condition = $0.isEmpty ? nil : $0 }))
                        DatePicker("Purchased After", selection: Binding(get: { viewModel.filters.purchaseDateStart ?? Date() }, set: { viewModel.filters.purchaseDateStart = $0 }), displayedComponents: .date)
                            .labelsHidden()
                        Button(viewModel.filters.purchaseDateStart == nil ? "Set Start" : "Clear Start") { viewModel.filters.purchaseDateStart = viewModel.filters.purchaseDateStart == nil ? Date() : nil }
                        DatePicker("Purchased Before", selection: Binding(get: { viewModel.filters.purchaseDateEnd ?? Date() }, set: { viewModel.filters.purchaseDateEnd = $0 }), displayedComponents: .date)
                            .labelsHidden()
                        Button(viewModel.filters.purchaseDateEnd == nil ? "Set End" : "Clear End") { viewModel.filters.purchaseDateEnd = viewModel.filters.purchaseDateEnd == nil ? Date() : nil }
                    }
                    Section("Tags") {
                        TextField("Include tags (comma separated)", text: Binding(get: { viewModel.filters.tags.joined(separator: ", ") }, set: {
                            let parts = $0.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                            viewModel.filters.tags = WatchValidation.normalizeTags(parts)
                        }))
                    }
                    if viewModel.lastLoadMs > 0 {
                        Section("Performance") { Text("Last load: \(viewModel.lastLoadMs) ms") }
                    }
                }
                .navigationTitle("Filters")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Apply") { viewModel.load(); dismiss() }
                    }
                }
            }
        }
    }
}

