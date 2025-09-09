import SwiftUI

/// Displays the watch collection with search, sorting, and grid/list toggle.
/// - What: Hosts a `CollectionViewModel`, renders results in a grid or list, and presents the add form.
/// - Why: Keeps UI interactions focused while delegating data logic to the ViewModel.
/// - How: Uses `.searchable`, live refresh on dismissal, and `NavigationLink` to details.

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 8) {
                sortAndLayoutBar
                content
            }
            .padding([.horizontal, .top])
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .task { await viewModel.load() }
            .onChange(of: viewModel.isPresentingAdd) { isPresented, _ in
                if isPresented == false {
                    Task { await viewModel.load() }
                }
            }

            addButton
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var sortAndLayoutBar: some View {
        HStack {
            Picker("Sort", selection: $viewModel.sortOption) {
                Text("Entry ↑").tag(WatchSortOption.entryDateAscending)
                Text("Entry ↓").tag(WatchSortOption.entryDateDescending)
                Text("A–Z").tag(WatchSortOption.manufacturerAZ)
                Text("Z–A").tag(WatchSortOption.manufacturerZA)
                Text("Most worn").tag(WatchSortOption.mostWorn)
                Text("Least worn").tag(WatchSortOption.leastWorn)
                Text("Last worn").tag(WatchSortOption.lastWornDate)
            }
            .pickerStyle(.menu)

            Spacer()

            Picker("View", selection: $viewModel.viewMode) {
                Image(systemName: "rectangle.grid.2x2").tag(CollectionViewMode.grid)
                Image(systemName: "list.bullet").tag(CollectionViewMode.list)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 180)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.viewMode == .grid {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.watches) { watch in
                        NavigationLink(destination: WatchDetailView(watch: watch)) {
                            GridCell(watch: watch)
                        }
                    }
                }
                .padding(.bottom, 80)
            }
        } else {
            List(viewModel.watches) { watch in
                NavigationLink(destination: WatchDetailView(watch: watch)) {
                    ListRow(watch: watch)
                }
            }
            .listStyle(.plain)
        }
    }

    private var addButton: some View {
        Button(action: { viewModel.isPresentingAdd = true }) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .padding(18)
                .background(Circle().fill(AppColors.accent))
                .shadow(radius: 6)
        }
        .padding()
        .accessibilityLabel("Add watch")
        .sheet(isPresented: $viewModel.isPresentingAdd) {
            NavigationStack { WatchFormView() }
        }
    }
}

private struct GridCell: View {
    let watch: Watch

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(watch.manufacturer)
                .font(.headline)
                .lineLimit(1)
            Text(watch.model ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            ZStack {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Image(systemName: "watch.case")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            }
            Text(watch.timesWorn > 0 ? "Worn \(watch.timesWorn)x" : "Not worn yet")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemBackground)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(watch.manufacturer) \(watch.model ?? "")")
        .accessibilityHint(watch.timesWorn > 0 ? "Worn \(watch.timesWorn) times" : "Not worn yet")
    }
}

private struct ListRow: View {
    let watch: Watch

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 56, height: 56)
                Image(systemName: "watch")
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(watch.manufacturer)
                    .font(.body)
                    .lineLimit(1)
                Text(watch.model ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: watch.isFavorite ? "star.fill" : "star")
                .foregroundStyle(watch.isFavorite ? .yellow : .secondary)
                .accessibilityLabel(watch.isFavorite ? "Favorite" : "Not favorite")
        }
        .contentShape(Rectangle())
    }
}


