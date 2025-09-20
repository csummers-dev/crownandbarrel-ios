import SwiftUI
import PhotosUI
import UIKit

/// Watch creation/edit form.
/// - What: Presents fields for core details, expandable additional details, and optional image selection.
/// - Why: Keeps data entry focused and validates minimal required input (manufacturer).
/// - How: Binds to `WatchFormViewModel`; supports editing via prefill; uses `PhotosPicker` for image selection.

struct WatchFormView: View {
    @Environment(\.themeToken) private var themeToken
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WatchFormViewModel()
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var isConfirmingDelete: Bool = false

    // Date selection UI state: start with no date selected; only apply to ViewModel on Save
    @State private var hasPurchaseDate: Bool = false
    @State private var tempPurchaseDate: Date = Date()
    @State private var hasWarrantyExpirationDate: Bool = false
    @State private var tempWarrantyExpirationDate: Date = Date()
    @State private var hasLastServiceDate: Bool = false
    @State private var tempLastServiceDate: Date = Date()
    @State private var hasSaleDate: Bool = false
    @State private var tempSaleDate: Date = Date()

    init(existingWatch: Watch? = nil) {
        _prefill = State(initialValue: existingWatch)
    }

    @State private var prefill: Watch? = nil

    var body: some View {
        Form {
            headerRow("Details")
            Section {
                TextField("Manufacturer", text: $viewModel.manufacturer)
                    .accessibilityIdentifier("manufacturerField")
                    .listRowBackground(AppColors.background)
                    .onTapGesture {
                        Haptics.formInteraction()
                    }
                TextField("Model", text: $viewModel.model)
                    .listRowBackground(AppColors.background)
                    .onTapGesture {
                        Haptics.formInteraction()
                    }

                Picker("Category", selection: Binding<WatchCategory>(
                    get: { viewModel.category ?? .other },
                    set: { newValue in
                        Haptics.formInteraction()
                        viewModel.category = newValue
                    }
                )) {
                    ForEach(WatchCategory.allCases) { cat in
                        Text(cat.rawValue.capitalized).tag(cat)
                    }
                }
                .listRowBackground(AppColors.background)

                TextField("Serial number", text: $viewModel.serialNumber)
                    .listRowBackground(AppColors.background)
                    .onTapGesture {
                        Haptics.formInteraction()
                    }
                TextField("Reference number", text: $viewModel.referenceNumber)
                    .listRowBackground(AppColors.background)
                    .onTapGesture {
                        Haptics.formInteraction()
                    }

                Picker("Movement", selection: Binding<WatchMovement>(
                    get: { viewModel.movement ?? .other },
                    set: { newValue in
                        Haptics.formInteraction()
                        viewModel.movement = newValue
                    }
                )) {
                    ForEach(WatchMovement.allCases) { m in
                        Text(m.rawValue.capitalized).tag(m)
                    }
                }
                .listRowBackground(AppColors.background)

                Toggle("Favorite", isOn: Binding<Bool>(
                    get: { viewModel.isFavorite },
                    set: { newValue in
                        Haptics.formInteraction()
                        viewModel.isFavorite = newValue
                    }
                ))
                    .listRowBackground(AppColors.background)
            }
            header: { EmptyView() }

            headerRow("Additional details")
            Section {
                Button(viewModel.isDetailsExpanded ? "Hide additional details" : "Show additional details") {
                    Haptics.formInteraction()
                    withAnimation { viewModel.isDetailsExpanded.toggle() }
                }
                .listRowBackground(AppColors.background)

                if viewModel.isDetailsExpanded {
                    Toggle("Purchase date", isOn: Binding<Bool>(
                        get: { hasPurchaseDate },
                        set: { newValue in
                            Haptics.formInteraction()
                            hasPurchaseDate = newValue
                        }
                    ))
                        .listRowBackground(AppColors.background)
                    if hasPurchaseDate {
                        DatePicker("Select date", selection: Binding<Date>(
                            get: { tempPurchaseDate },
                            set: { newValue in
                                Haptics.formInteraction()
                                tempPurchaseDate = newValue
                            }
                        ), displayedComponents: .date)
                            .listRowBackground(AppColors.background)
                    }
                    TextField("Service interval (months)", text: $viewModel.serviceIntervalMonths)
                        .keyboardType(.numberPad)
                        .listRowBackground(AppColors.background)
                        .onTapGesture {
                            Haptics.formInteraction()
                        }
                    Toggle("Warranty expiration", isOn: Binding<Bool>(
                        get: { hasWarrantyExpirationDate },
                        set: { newValue in
                            Haptics.formInteraction()
                            hasWarrantyExpirationDate = newValue
                        }
                    ))
                        .listRowBackground(AppColors.background)
                    if hasWarrantyExpirationDate {
                        DatePicker("Select date", selection: Binding<Date>(
                            get: { tempWarrantyExpirationDate },
                            set: { newValue in
                                Haptics.formInteraction()
                                tempWarrantyExpirationDate = newValue
                            }
                        ), displayedComponents: .date)
                            .listRowBackground(AppColors.background)
                    }
                    Toggle("Last service date", isOn: Binding<Bool>(
                        get: { hasLastServiceDate },
                        set: { newValue in
                            Haptics.formInteraction()
                            hasLastServiceDate = newValue
                        }
                    ))
                        .listRowBackground(AppColors.background)
                    if hasLastServiceDate {
                        DatePicker("Select date", selection: Binding<Date>(
                            get: { tempLastServiceDate },
                            set: { newValue in
                                Haptics.formInteraction()
                                tempLastServiceDate = newValue
                            }
                        ), displayedComponents: .date)
                            .listRowBackground(AppColors.background)
                    }
                    TextField("Purchase price", text: $viewModel.purchasePrice)
                        .keyboardType(.decimalPad)
                        .listRowBackground(AppColors.background)
                        .onTapGesture {
                            Haptics.formInteraction()
                        }
                    TextField("Current value", text: $viewModel.currentValue)
                        .keyboardType(.decimalPad)
                        .listRowBackground(AppColors.background)
                        .onTapGesture {
                            Haptics.formInteraction()
                        }
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .frame(minHeight: 88)
                        .listRowBackground(AppColors.background)
                        .onTapGesture {
                            Haptics.formInteraction()
                        }
                    Toggle("Sale date", isOn: Binding<Bool>(
                        get: { hasSaleDate },
                        set: { newValue in
                            Haptics.formInteraction()
                            hasSaleDate = newValue
                        }
                    ))
                        .listRowBackground(AppColors.background)
                    if hasSaleDate {
                        DatePicker("Select date", selection: Binding<Date>(
                            get: { tempSaleDate },
                            set: { newValue in
                                Haptics.formInteraction()
                                tempSaleDate = newValue
                            }
                        ), displayedComponents: .date)
                            .listRowBackground(AppColors.background)
                    }
                    TextField("Sale price", text: $viewModel.salePrice)
                        .keyboardType(.decimalPad)
                        .listRowBackground(AppColors.background)
                        .onTapGesture {
                            Haptics.formInteraction()
                        }
                }
            }
            header: { EmptyView() }

            headerRow("Image")
            Section {
                // Shows the existing image (if any). Once a new image is picked,
                // the preview switches to `selectedImage` immediately so users can
                // confirm the change prior to saving.
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .listRowBackground(AppColors.background)
                } else if let assetId = viewModel.imageAssetId {
                    WatchImageView(imageAssetId: assetId)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .listRowBackground(AppColors.background)
                }
                PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                    Label("Select from Photos", systemImage: "photo")
                }
                .listRowBackground(AppColors.background)
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("UITEST_INJECT_IMAGE") {
                    Button("Inject Test Image") {
                        let size = CGSize(width: 128, height: 128)
                        UIGraphicsBeginImageContextWithOptions(size, false, 1)
                        UIColor.green.setFill()
                        UIRectFill(CGRect(origin: .zero, size: size))
                        let img = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        if let ui = img { viewModel.selectedImage = ui }
                    }
                    .listRowBackground(AppColors.background)
                }
                #endif
            }
            header: { EmptyView() }

            // Danger Zone
            if viewModel.existingWatchId != nil {
                headerRow("Danger Zone")
                Section {
                    Button(role: .destructive) {
                        isConfirmingDelete = true
                    } label: {
                        Text("Delete watch")
                    }
                    .listRowBackground(AppColors.background)
                }
                header: { EmptyView() }
            }
        }
        .listSectionSeparator(.hidden, edges: .all)
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .listStyle(.insetGrouped)
        .listSectionSpacing(.custom(0))
        .contentMargins(.top, -8, for: .scrollContent)
        .navigationTitle(viewModel.existingWatchId == nil ? "Add Watch" : "Edit Watch")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.existingWatchId == nil ? "Add Watch" : "Edit Watch")
                    .font(AppTypography.titleCompact)
                    .foregroundStyle(AppColors.accent)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        applyDateSelectionsToViewModel()
                        if await viewModel.save() {
                            Haptics.successNotification()
                            dismiss()
                        } else {
                            Haptics.error()
                        }
                    }
                }
                    .disabled(viewModel.isSaving)
            }
        }
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onChange(of: pickerItem) { _, newValue in
            guard let item = newValue else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    // Enforce square crop on selection
                    let cropped = ImageStore.squareCropped(image)
                    viewModel.selectedImage = cropped
                    Haptics.success()
                }
                // Reset picker selection so user can pick again next time without stale state
                DispatchQueue.main.async { pickerItem = nil }
            }
        }
        .onAppear { configureIfNeeded() }
        .onChange(of: prefill) { _, _ in configureIfNeeded() }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .confirmationDialog("Delete this watch?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.delete() { dismiss() }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .id(themeToken + "-watchform")
    }
}

// MARK: - Helpers
private func bindingDate(_ source: Binding<Date?>, default defaultValue: Date = Date()) -> Binding<Date> {
    Binding<Date>(
        get: { source.wrappedValue ?? defaultValue },
        set: { source.wrappedValue = $0 }
    )
}

private extension WatchFormView {
    /// Applies the toggled temp dates into the view model only when saving.
    func applyDateSelectionsToViewModel() {
        viewModel.purchaseDate = hasPurchaseDate ? tempPurchaseDate : nil
        viewModel.warrantyExpirationDate = hasWarrantyExpirationDate ? tempWarrantyExpirationDate : nil
        viewModel.lastServiceDate = hasLastServiceDate ? tempLastServiceDate : nil
        viewModel.saleDate = hasSaleDate ? tempSaleDate : nil
    }
    /// Plain header row mirroring Settings style to avoid UIKit grouped header backgrounds.
    /// - Why: Ensures primary background behind headers and tight spacing to the section content.
    /// - How: Render as a normal row above a `Section` with an empty header.
    func headerRow(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.none)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, -6)
        .listRowSeparator(.hidden)
        .listRowBackground(AppColors.background)
    }
    @State private static var _confirmDeleteHolder: Bool = false
    var confirmDelete: Binding<Bool> {
        Binding<Bool>(
            get: { WatchFormView._confirmDeleteHolder },
            set: { WatchFormView._confirmDeleteHolder = $0 }
        )
    }
    func configureIfNeeded() {
        if let w = prefill {
            if viewModel.existingWatchId != w.id {
                viewModel.configure(with: w)
                viewModel.selectedImage = nil
                // Initialize date toggles and temps to reflect existing values without committing changes yet
                if let d = viewModel.purchaseDate { hasPurchaseDate = true; tempPurchaseDate = d } else { hasPurchaseDate = false; tempPurchaseDate = Date() }
                if let d = viewModel.warrantyExpirationDate { hasWarrantyExpirationDate = true; tempWarrantyExpirationDate = d } else { hasWarrantyExpirationDate = false; tempWarrantyExpirationDate = Date() }
                if let d = viewModel.lastServiceDate { hasLastServiceDate = true; tempLastServiceDate = d } else { hasLastServiceDate = false; tempLastServiceDate = Date() }
                if let d = viewModel.saleDate { hasSaleDate = true; tempSaleDate = d } else { hasSaleDate = false; tempSaleDate = Date() }
            }
        }
    }
}


