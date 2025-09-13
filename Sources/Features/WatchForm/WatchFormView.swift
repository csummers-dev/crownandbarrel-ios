import SwiftUI
import PhotosUI
import UIKit

/// Watch creation/edit form.
/// - What: Presents fields for core details, expandable additional details, and optional image selection.
/// - Why: Keeps data entry focused and validates minimal required input (manufacturer).
/// - How: Binds to `WatchFormViewModel`; supports editing via prefill; uses `PhotosPicker` for image selection.

struct WatchFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WatchFormViewModel()
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var isConfirmingDelete: Bool = false

    init(existingWatch: Watch? = nil) {
        _prefill = State(initialValue: existingWatch)
    }

    @State private var prefill: Watch? = nil

    var body: some View {
        Form {
            Section("Details") {
                TextField("Manufacturer", text: $viewModel.manufacturer)
                TextField("Model", text: $viewModel.model)

                Picker("Category", selection: Binding<WatchCategory>(
                    get: { viewModel.category ?? .other },
                    set: { viewModel.category = $0 }
                )) {
                    ForEach(WatchCategory.allCases) { cat in
                        Text(cat.rawValue.capitalized).tag(cat)
                    }
                }

                TextField("Serial number", text: $viewModel.serialNumber)
                TextField("Reference number", text: $viewModel.referenceNumber)

                Picker("Movement", selection: Binding<WatchMovement>(
                    get: { viewModel.movement ?? .other },
                    set: { viewModel.movement = $0 }
                )) {
                    ForEach(WatchMovement.allCases) { m in
                        Text(m.rawValue.capitalized).tag(m)
                    }
                }

                Toggle("Favorite", isOn: $viewModel.isFavorite)
            }

            Section {
                Button(viewModel.isDetailsExpanded ? "Hide additional details" : "Show additional details") {
                    withAnimation { viewModel.isDetailsExpanded.toggle() }
                }

                if viewModel.isDetailsExpanded {
                    DatePicker("Purchase date", selection: bindingDate($viewModel.purchaseDate), displayedComponents: .date)
                    TextField("Service interval (months)", text: $viewModel.serviceIntervalMonths)
                        .keyboardType(.numberPad)
                    DatePicker("Warranty expiration", selection: bindingDate($viewModel.warrantyExpirationDate), displayedComponents: .date)
                    DatePicker("Last service date", selection: bindingDate($viewModel.lastServiceDate), displayedComponents: .date)
                    TextField("Purchase price", text: $viewModel.purchasePrice)
                        .keyboardType(.decimalPad)
                    TextField("Current value", text: $viewModel.currentValue)
                        .keyboardType(.decimalPad)
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    DatePicker("Sale date", selection: bindingDate($viewModel.saleDate), displayedComponents: .date)
                    TextField("Sale price", text: $viewModel.salePrice)
                        .keyboardType(.decimalPad)
                }
            }

            Section("Image") {
                // Shows the existing image (if any). Once a new image is picked,
                // the preview switches to `selectedImage` immediately so users can
                // confirm the change prior to saving.
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if let assetId = viewModel.imageAssetId {
                    WatchImageView(imageAssetId: assetId)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                    Label("Select from Photos", systemImage: "photo")
                }
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
                }
                #endif
            }

            // Danger Zone
            if viewModel.existingWatchId != nil {
                Section("Danger Zone") {
                    Button(role: .destructive) {
                        isConfirmingDelete = true
                    } label: {
                        Text("Delete watch")
                    }
                }
            }
        }
        .navigationTitle(viewModel.existingWatchId == nil ? "Add Watch" : "Edit Watch")
        .navigationBarItems(
            leading: Button("Cancel") { dismiss() },
            trailing: Button("Save") { Task { if await viewModel.save() { dismiss() } } }.disabled(viewModel.isSaving).tint(AppColors.textSecondary)
        )
        .onChange(of: pickerItem) { _, newValue in
            guard let item = newValue else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    // Enforce square crop on selection
                    let cropped = ImageStore.squareCropped(image)
                    viewModel.selectedImage = cropped
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
            }
        }
    }
}


