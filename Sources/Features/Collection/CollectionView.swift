import SwiftUI

/// Displays the watch collection with search, sorting, and grid/list toggle.
/// - What: Hosts a `CollectionViewModel`, renders results in a grid or list, and presents the add form.
/// - Why: Keeps UI interactions focused while delegating data logic to the ViewModel.
/// - How: Uses `.searchable`, pull-to-refresh, and `NavigationLink` to details. Grid tiles use a standardized width
///        and truncate long text with ellipses. A bottom-right star indicates favorite entries.

struct CollectionView: View {
    @Environment(\.themeToken) private var themeToken
    @StateObject private var viewModel = CollectionViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    /// Local grid sizing token to avoid project regeneration for new files.
    /// Move to `Sources/DesignSystem` if project is regenerated via XcodeGen.
    /// Grid tile width tokens to standardize card sizing (avoid magic numbers).
    fileprivate enum GridTileWidth {
        case small, medium, large, xLarge
        var width: CGFloat {
            switch self {
            case .small: return 100
            case .medium: return 120
            case .large: return 140
            case .xLarge: return 160
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: AppSpacing.xs) {
                sortAndLayoutBar
                Color.clear.frame(height: 2)
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
        .background(AppColors.background.ignoresSafeArea())
        .id(themeToken)
    }

    private var sortAndLayoutBar: some View {
        HStack(spacing: AppSpacing.sm) {
            // Why: `.pickerStyle(.menu)` relies on UIKit's menu chevrons which may not retint
            //      mid-session on theme changes. A custom Menu label lets us explicitly control
            //      the chevron color and guarantees it follows `AppColors.accent`.
            Menu {
                Picker("Sort", selection: Binding<WatchSortOption>(
                    get: { viewModel.sortOption },
                    set: { newValue in
                        Haptics.searchInteraction(.filterChange)
                        viewModel.sortOption = newValue
                    }
                )) {
                    Text("Entry ↑").tag(WatchSortOption.entryDateAscending)
                    Text("Entry ↓").tag(WatchSortOption.entryDateDescending)
                    Text("A–Z").tag(WatchSortOption.manufacturerAZ)
                    Text("Z–A").tag(WatchSortOption.manufacturerZA)
                    Text("Most worn").tag(WatchSortOption.mostWorn)
                    Text("Least worn").tag(WatchSortOption.leastWorn)
                    Text("Last worn").tag(WatchSortOption.lastWornDate)
                }
            } label: {
                HStack(spacing: 6) {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                    Image(systemName: "chevron.down")
                }
                // What: Color the label chevron and text explicitly.
                // Why: Prevents reliance on global tint for this element; ensures immediate theme update.
                .foregroundStyle(AppColors.accent)
            }
            // Force refresh of menu indicator color when theme changes
            .id(themeToken + "-sortmenu")

            Spacer()

            Picker("View", selection: Binding<CollectionViewMode>(
                get: { viewModel.viewMode },
                set: { newValue in
                    Haptics.collectionInteraction()
                    viewModel.viewMode = newValue
                }
            )) {
                Image(systemName: "rectangle.grid.2x2").tag(CollectionViewMode.grid)
                Image(systemName: "list.bullet").tag(CollectionViewMode.list)
            }
            .pickerStyle(.segmented)
            .controlSize(.small)
            .frame(maxWidth: 160)
            .tint(AppColors.accent)
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
                        .onTapGesture {
                            Haptics.debouncedHaptic {
                                Haptics.collectionInteraction()
                            }
                        }
                    }
                }
                .padding(.bottom, 80)
            }
            .refreshable { 
                await viewModel.load()
                Haptics.success()
            }
        } else {
            List(viewModel.watches) { watch in
                NavigationLink(destination: WatchDetailView(watch: watch)) {
                    ListRow(watch: watch)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                }
                .onTapGesture {
                    Haptics.debouncedHaptic {
                        Haptics.collectionInteraction()
                    }
                }
                .accessibilityIdentifier("CollectionCard")
                // Ensure equal padding around chevron by applying horizontal inset to the row
                .listRowInsets(EdgeInsets(top: AppSpacing.xs - 2, leading: AppSpacing.md, bottom: AppSpacing.xs - 2, trailing: AppSpacing.md))
                // Use a full-width background so it extends under the chevron
                .listRowBackground(
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.large)
                            .fill(AppColors.secondaryBackground)
                    }
                    .padding(.vertical, AppSpacing.xxs)
                )
                // Extra defensive: hide any residual UIKit separators at the row level
                .listRowSeparator(.hidden, edges: .all)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .listSectionSeparator(.hidden, edges: .all)
            .listRowSeparator(.hidden, edges: .all)
            .refreshable { 
                await viewModel.load()
                Haptics.success()
            }
            // Extra defensive: remove any UIAppearance-driven separators at runtime
            .onAppear {
                UITableView.appearance().separatorStyle = .none
                UITableView.appearance().separatorColor = .clear
                UITableView.appearance().separatorEffect = nil
                UITableView.appearance().separatorInset = .zero
                UITableView.appearance().separatorInsetReference = .fromCellEdges
            }
        }
    }

    private var addButton: some View {
        Button(action: { 
            // Provide haptic feedback for important add action
            // Use medium impact for significant user action that opens a form
            Haptics.mediumImpact()
            viewModel.isPresentingAdd = true 
        }) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.brandWhite)
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

// moved to Common/Components/WatchImageView

private struct GridCell: View {
    let watch: Watch

    var body: some View {
        let tileSize: CGFloat = CollectionView.GridTileWidth.xLarge.width
        let containerWidth: CGFloat = tileSize + 20 // match 10pt horizontal padding on each side
        // What: Grid tile showing name and a square image with subtle border
        // Why: Maintains visual uniformity across all items, regardless of image aspect ratio
        // How: Use `WatchImageView` scaledToFill and clip to a rounded rect of fixed size. Apply a fixed
        //      container width so layout does not shift based on text length. Truncate long text.
        VStack(alignment: .leading, spacing: 6) {
            Text(watch.manufacturer)
                .font(AppTypography.luxury)
                .foregroundStyle(AppColors.accent)
                .lineLimit(1)
                .truncationMode(.tail)
                .accessibilityIdentifier("GridCellManufacturer")
            Text(watch.model ?? "")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .accessibilityIdentifier("GridCellModel")
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(AppColors.secondaryBackground)
                    .frame(width: tileSize, height: tileSize)
                WatchImageView(imageAssetId: watch.imageAssetId)
                    .frame(width: tileSize, height: tileSize)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.medium)
                            .stroke(AppColors.brandSilver.opacity(0.6), lineWidth: 0.5)
                    )
            }
            Text(watch.timesWorn > 0 ? "Worn \(watch.timesWorn)x" : "Not worn yet")
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(10)
        .frame(width: containerWidth, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: AppRadius.large).fill(AppColors.secondaryBackground))
        .overlay(alignment: .bottomTrailing) {
            if watch.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .padding(6)
            }
        }
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
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .fill(AppColors.secondaryBackground)
                WatchImageView(imageAssetId: watch.imageAssetId)
                    .frame(width: thumbSize, height: thumbSize)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))
            }
            .frame(width: thumbSize, height: thumbSize)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .stroke(AppColors.brandSilver.opacity(0.6), lineWidth: 0.5)
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(watch.manufacturer)
                    .font(AppTypography.luxury)
                    .foregroundStyle(AppColors.accent)
                    .lineLimit(1)
                Text(watch.model ?? "")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: watch.isFavorite ? "star.fill" : "star")
                .foregroundStyle(watch.isFavorite ? .yellow : AppColors.textSecondary)
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
                .foregroundStyle(AppColors.accent)
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


