import SwiftUI
import PhotosUI
// Collections sections


public struct WatchV2FormView: View {
    @StateObject private var viewModel: WatchV2FormViewModel
    @State private var showPhotoPicker: Bool = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPhotosDeniedAlert: Bool = false
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss
    
    private let repository: WatchRepositoryV2 = WatchRepositoryGRDB()
    private let isNewWatch: Bool

    public init(watch: WatchV2) {
        _viewModel = StateObject(wrappedValue: WatchV2FormViewModel(watch: watch))
        // Check if this is a new watch (empty manufacturer means new)
        self.isNewWatch = watch.manufacturer.isEmpty
    }

    public var body: some View {
        Form {
            // Core fields
            Section("Core") {
                TextField("Manufacturer", text: Binding(
                    get: { viewModel.watch.manufacturer },
                    set: { viewModel.watch.manufacturer = $0 }
                ))
                TextField("Line", text: Binding(
                    get: { viewModel.watch.line ?? "" },
                    set: { viewModel.watch.line = $0.isEmpty ? nil : $0 }
                ))
                TextField("Model Name", text: Binding(
                    get: { viewModel.watch.modelName },
                    set: { viewModel.watch.modelName = $0 }
                ))
                TextField("Reference Number", text: Binding(
                    get: { viewModel.watch.referenceNumber ?? "" },
                    set: { viewModel.watch.referenceNumber = $0.isEmpty ? nil : $0 }
                ))
                TextField("Nickname", text: Binding(
                    get: { viewModel.watch.nickname ?? "" },
                    set: { viewModel.watch.nickname = $0.isEmpty ? nil : $0 }
                ))
                photosGrid
            }

            // Additional Details (collapsed by default)
            CollapsibleSection(title: "Additional Details", initiallyExpanded: false) {
                detailsCase
                detailsDial
                detailsCrystal
                detailsMovement
                detailsWater
                detailsStrap
                detailsOwnership

                // Collections UI
                ServiceHistorySection(entries: Binding(get: { viewModel.watch.serviceHistory }, set: { viewModel.watch.serviceHistory = $0 }))
                ValuationsSection(entries: Binding(get: { viewModel.watch.valuations }, set: { viewModel.watch.valuations = $0 }))
                StrapsSection(entries: Binding(get: { viewModel.watch.straps }, set: { viewModel.watch.straps = $0 }))

                TextField("Serial Number", text: Binding(
                    get: { viewModel.watch.serialNumber ?? "" },
                    set: { viewModel.watch.serialNumber = $0.isEmpty ? nil : $0 }
                ))
                Stepper(value: Binding(
                    get: { viewModel.watch.productionYear ?? 0 },
                    set: { viewModel.watch.productionYear = $0 == 0 ? nil : $0 }
                ), in: 0...Calendar.current.component(.year, from: Date())) {
                    Text("Production Year: \(viewModel.watch.productionYear.map(String.init) ?? "—")")
                }
                TextField("Country of Origin", text: Binding(
                    get: { viewModel.watch.countryOfOrigin ?? "" },
                    set: { viewModel.watch.countryOfOrigin = $0.isEmpty ? nil : $0 }
                ))
                TextField("Limited Edition Number", text: Binding(
                    get: { viewModel.watch.limitedEditionNumber ?? "" },
                    set: { viewModel.watch.limitedEditionNumber = $0.isEmpty ? nil : $0 }
                ))
                TextField("Notes", text: Binding(
                    get: { viewModel.watch.notes ?? "" },
                    set: { viewModel.watch.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .lineLimit(3, reservesSpace: true)
                TextField("Tags (comma separated)", text: Binding(
                    get: { viewModel.watch.tags.joined(separator: ", ") },
                    set: {
                        let parts = $0.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                        viewModel.watch.tags = WatchValidation.normalizeTags(parts)
                    }
                ))
            }
        }
        .navigationTitle("Watch")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    Task {
                        await saveWatch()
                    }
                }
                .accessibilityLabel("Done")
                .disabled(viewModel.watch.manufacturer.isEmpty || viewModel.watch.modelName.isEmpty)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task { @MainActor in
                if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    // Attempt native edit elsewhere if available; fallback crops here
                    viewModel.addPhoto(from: image)
                }
            }
        }
    }

    private var photosGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Photos (\(viewModel.watch.photos.count) / 10)")
                Spacer()
                Button(action: {
                    guard viewModel.watch.photos.count < 10 else { return }
                    PhotosPermissionV2.ensureAuthorized { ok in
                        if ok { showPhotoPicker = true }
                        else { showPhotosDeniedAlert = true }
                    }
                }) {
                    Label("Add Photo", systemImage: "plus")
                }
                .disabled(viewModel.watch.photos.count >= 10)
                .accessibilityLabel("Add Photo \(viewModel.watch.photos.count) of 10")
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 160), spacing: 8)], spacing: 8) {
                ForEach(viewModel.watch.photos) { photo in
                    ZStack(alignment: .topTrailing) {
                        let img = PhotoStoreV2.loadThumb(watchId: viewModel.watch.id, photoId: photo.id)
                        Group {
                            if let img { Image(uiImage: img).resizable().scaledToFill() }
                            else { Rectangle().fill(Color.secondary.opacity(0.2)) }
                        }
                        .frame(width: 100, height: 100)
                        .clipped()
                        .overlay(
                            photo.isPrimary ? Image(systemName: "star.fill").foregroundColor(.yellow).padding(4) : nil,
                            alignment: .bottomLeading
                        )
                        .accessibilityLabel(photo.isPrimary ? "Primary photo" : "Photo")
                        Menu {
                            Button("Set as Primary") { viewModel.setPrimary(photo.id) }
                            Button("Delete", role: .destructive) { viewModel.deletePhoto(photo) }
                        } label: {
                            Image(systemName: "ellipsis.circle").imageScale(.large).padding(4)
                        }
                        .accessibilityLabel("Photo actions")
                    }
                }
                .onMove(perform: viewModel.movePhoto)
            }
        }
        .alert("Photos Access Required", isPresented: $showPhotosDeniedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We use your Photos access only to let you import pictures into your on-device collection. Nothing leaves your device.")
        }
    }

    // MARK: - Detail groups

    private var detailsCase: some View {
        CollapsibleSection(title: "Case") {
            Stepper(value: Binding(get: { viewModel.watch.watchCase.diameterMM ?? 0 }, set: { viewModel.watch.watchCase.diameterMM = $0 == 0 ? nil : Double($0) }), in: 0...60) { Text("Diameter mm: \(viewModel.watch.watchCase.diameterMM.map { String(format: "%.1f", $0) } ?? "—")") }
            Stepper(value: Binding(get: { viewModel.watch.watchCase.thicknessMM ?? 0 }, set: { viewModel.watch.watchCase.thicknessMM = $0 == 0 ? nil : Double($0) }), in: 0...25) { Text("Thickness mm: \(viewModel.watch.watchCase.thicknessMM.map { String(format: "%.1f", $0) } ?? "—")") }
            Stepper(value: Binding(get: { viewModel.watch.watchCase.lugToLugMM ?? 0 }, set: { viewModel.watch.watchCase.lugToLugMM = $0 == 0 ? nil : Double($0) }), in: 0...70) { Text("Lug-to-lug mm: \(viewModel.watch.watchCase.lugToLugMM.map { String(format: "%.1f", $0) } ?? "—")") }
            Stepper(value: Binding(get: { viewModel.watch.watchCase.lugWidthMM ?? 0 }, set: { viewModel.watch.watchCase.lugWidthMM = $0 == 0 ? nil : Int($0) }), in: 0...30) { Text("Lug width mm: \(viewModel.watch.watchCase.lugWidthMM.map(String.init) ?? "—")") }
        }
    }

    private var detailsDial: some View {
        CollapsibleSection(title: "Dial & Hands") {
            TextField("Dial Color", text: Binding(get: { viewModel.watch.dial.color ?? "" }, set: { viewModel.watch.dial.color = $0.isEmpty ? nil : $0 }))
        }
    }

    private var detailsCrystal: some View {
        CollapsibleSection(title: "Crystal") { EmptyView() }
    }

    private var detailsMovement: some View {
        CollapsibleSection(title: "Movement") {
            Stepper(value: Binding(get: { viewModel.watch.movement.powerReserveHours ?? 0 }, set: { viewModel.watch.movement.powerReserveHours = $0 == 0 ? nil : Double($0) }), in: 0...2000) { Text("Power Reserve (h): \(viewModel.watch.movement.powerReserveHours.map { String(format: "%.0f", $0) } ?? "—")") }
        }
    }

    private var detailsWater: some View {
        CollapsibleSection(title: "Water & Crown") {
            Stepper(value: Binding(get: { viewModel.watch.water.waterResistanceM ?? 0 }, set: { viewModel.watch.water.waterResistanceM = $0 == 0 ? nil : Int($0) }), in: 0...2000) { Text("Water Resistance (m): \(viewModel.watch.water.waterResistanceM.map(String.init) ?? "—")") }
        }
    }

    private var detailsStrap: some View {
        CollapsibleSection(title: "Strap / Bracelet") {
            Toggle("Quick Release", isOn: Binding(get: { viewModel.watch.strapCurrent.quickRelease }, set: { viewModel.watch.strapCurrent.quickRelease = $0 }))
        }
    }

    private var detailsOwnership: some View {
        CollapsibleSection(title: "Ownership & Provenance") {
            DatePicker("Date Acquired", selection: Binding(get: { viewModel.watch.ownership.dateAcquired ?? Date() }, set: { viewModel.watch.ownership.dateAcquired = $0 }), displayedComponents: .date)
                .labelsHidden()
                .opacity(viewModel.watch.ownership.dateAcquired == nil ? 0.5 : 1.0)
            Button(viewModel.watch.ownership.dateAcquired == nil ? "Set Date" : "Clear Date") {
                if viewModel.watch.ownership.dateAcquired == nil { viewModel.watch.ownership.dateAcquired = Date() }
                else { viewModel.watch.ownership.dateAcquired = nil }
            }
            EnumPickerWithOther(title: "Condition",
                                selection: Binding(get: { viewModel.watch.ownership.condition }, set: { viewModel.watch.ownership.condition = $0 }),
                                options: [.new, .unworn, .excellent, .veryGood, .good, .fair, .poor],
                                display: { $0.asString() },
                                otherFromString: { .other($0) },
                                isOther: { if case .other = $0 { return true } else { return false } })
        }
    }
    
    // MARK: - Actions
    
    private func saveWatch() async {
        do {
            // Normalize and validate
            viewModel.normalizeTags()
            
            // Save to repository
            if isNewWatch {
                try repository.create(viewModel.watch)
            } else {
                try repository.update(viewModel.watch)
            }
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


