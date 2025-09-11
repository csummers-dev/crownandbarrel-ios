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
            VStack(spacing: AppSpacing.xs) {
                sortAndLayoutBar
                content
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .task { await viewModel.load() }
            .onAppear { Task { await viewModel.load() } }
            .onChange(of: viewModel.isPresentingAdd) { _, newValue in
                if newValue == false {
                    Task { await viewModel.load() }
                }
            }

            addButton
        }
        .overlay(alignment: .bottom) {
            if let msg = viewModel.infoMessage {
                ToastBanner(message: msg)
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.35, dampingFraction: 0.9), value: viewModel.infoMessage)
            }
        }
        .onChange(of: viewModel.infoMessage) { _, newValue in
            guard newValue != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { viewModel.infoMessage = nil }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var sortAndLayoutBar: some View {
        HStack(spacing: AppSpacing.sm) {
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
            .controlSize(.small)
            .frame(maxWidth: 160)
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
                .foregroundStyle(AppColors.brandWhite)
                .padding(18)
                .background(Circle().fill(AppColors.brandGold))
                .shadow(radius: 6)
        }
        .padding()
        .accessibilityLabel("Add watch")
        .sheet(isPresented: $viewModel.isPresentingAdd) {
            NavigationStack { WatchFormView() }
        }
    }
}

// moved to Common/Components/WatchImageView

private struct GridCell: View {
    let watch: Watch

    var body: some View {
        let tileSize: CGFloat = 120
        // What: Grid tile showing name and a square image with subtle border
        // Why: Maintains visual uniformity across all items, regardless of image aspect ratio
        // How: Use `WatchImageView` scaledToFill and clip to a rounded rect of fixed size
        VStack(alignment: .leading, spacing: 6) {
            Text(watch.manufacturer)
                .font(.headline)
                .lineLimit(1)
            Text(watch.model ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: tileSize, height: tileSize)
                WatchImageView(imageAssetId: watch.imageAssetId)
                    .frame(width: tileSize, height: tileSize)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.brandSilver.opacity(0.6), lineWidth: 0.5)
                    )
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
        let thumbSize: CGFloat = 56
        // What: Compact row with square thumbnail and key metadata
        // Why: Improves scan-ability and keeps heights consistent between rows
        // How: Thumbnail uses the same image component and clipped fixed frame
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
                WatchImageView(imageAssetId: watch.imageAssetId)
                    .frame(width: thumbSize, height: thumbSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(width: thumbSize, height: thumbSize)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.brandSilver.opacity(0.6), lineWidth: 0.5)
            )
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

// MARK: - Toast
private struct ToastBanner: View {
    enum ToastStyle { case info, success, warning, error }
    let message: String
    var style: ToastStyle = .info

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColors.brandGold)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(radius: 4)
        .accessibilityLabel(message)
    }
}


