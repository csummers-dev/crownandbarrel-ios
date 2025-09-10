import Foundation
import UIKit

/// ViewModel for creating and editing watches.
/// - What: Exposes form fields, validation, and save orchestration.
/// - Why: Keeps formatting/validation logic out of the view so the UI stays simple.
/// - How: Builds a `Watch` from inputs, saves via repository, and handles image persistence.
@MainActor
final class WatchFormViewModel: ObservableObject {
    // Basic
    @Published var manufacturer: String = ""
    @Published var model: String = ""
    @Published var category: WatchCategory? = nil
    @Published var serialNumber: String = ""
    @Published var referenceNumber: String = ""
    @Published var movement: WatchMovement? = nil
    @Published var isFavorite: Bool = false

    // Additional details
    @Published var isDetailsExpanded: Bool = false
    @Published var purchaseDate: Date? = nil
    @Published var serviceIntervalMonths: String = ""
    @Published var warrantyExpirationDate: Date? = nil
    @Published var lastServiceDate: Date? = nil
    @Published var purchasePrice: String = ""
    @Published var currentValue: String = ""
    @Published var notes: String = ""
    @Published var saleDate: Date? = nil
    @Published var salePrice: String = ""

    // Image
    @Published var selectedImage: UIImage? = nil
    @Published var imageAssetId: String? = nil
    @Published var existingWatchId: UUID? = nil
    @Published var existingCreatedAt: Date? = nil

    // UI
    @Published var errorMessage: String? = nil
    @Published var isSaving: Bool = false

    private let repository: WatchRepository

    /// Injects a repository for persistence (default Core Data).
    init(repository: WatchRepository = WatchRepositoryCoreData()) {
        self.repository = repository
    }

    /// Validates required form inputs.
    /// - Returns: True if inputs are acceptable; sets `errorMessage` on failure.
    func validate() -> Bool {
        if manufacturer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Manufacturer is required."
            return false
        }
        return true
    }

    /// Saves the watch (insert/update) and persists an image if provided.
    /// - Returns: True on success; false on validation or persistence error (with `errorMessage`).
    func save() async -> Bool {
        guard validate() else { return false }
        isSaving = true
        defer { isSaving = false }

        do {
            var assetId: String? = imageAssetId
            if let image = selectedImage {
                let squared = ImageStore.squareCropped(image)
                let id = UUID().uuidString
                _ = try ImageStore.saveImage(squared, assetId: id)
                assetId = id
            }

            let watch = Watch(
                id: existingWatchId ?? UUID(),
                manufacturer: manufacturer,
                model: model.isEmpty ? nil : model,
                category: category,
                serialNumber: serialNumber.isEmpty ? nil : serialNumber,
                referenceNumber: referenceNumber.isEmpty ? nil : referenceNumber,
                movement: movement,
                isFavorite: isFavorite,
                purchaseDate: purchaseDate,
                serviceIntervalMonths: parseInt(serviceIntervalMonths),
                warrantyExpirationDate: warrantyExpirationDate,
                lastServiceDate: lastServiceDate,
                purchasePrice: parseDecimal(purchasePrice),
                currentValue: parseDecimal(currentValue),
                notes: notes.isEmpty ? nil : notes,
                imageAssetId: assetId,
                timesWorn: 0,
                lastWornDate: nil,
                saleDate: saleDate,
                salePrice: parseDecimal(salePrice),
                createdAt: existingCreatedAt ?? Date(),
                updatedAt: Date()
            )

            try await repository.upsert(watch)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Prefills the form with an existing watch for editing.
    func configure(with watch: Watch) {
        existingWatchId = watch.id
        existingCreatedAt = watch.createdAt
        manufacturer = watch.manufacturer
        model = watch.model ?? ""
        category = watch.category
        serialNumber = watch.serialNumber ?? ""
        referenceNumber = watch.referenceNumber ?? ""
        movement = watch.movement
        isFavorite = watch.isFavorite
        purchaseDate = watch.purchaseDate
        serviceIntervalMonths = watch.serviceIntervalMonths.map { String($0) } ?? ""
        warrantyExpirationDate = watch.warrantyExpirationDate
        lastServiceDate = watch.lastServiceDate
        purchasePrice = watch.purchasePrice.map { "\($0 as NSDecimalNumber)" } ?? ""
        currentValue = watch.currentValue.map { "\($0 as NSDecimalNumber)" } ?? ""
        notes = watch.notes ?? ""
        saleDate = watch.saleDate
        salePrice = watch.salePrice.map { "\($0 as NSDecimalNumber)" } ?? ""
        imageAssetId = watch.imageAssetId
    }

    /// Parses a localized decimal string, returning nil for empty input.
    private func parseDecimal(_ text: String) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        if let num = formatter.number(from: trimmed) {
            return num.decimalValue
        }
        return Decimal(string: trimmed)
    }

    /// Parses an integer string, returning nil for empty input.
    private func parseInt(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Int(trimmed)
    }
}


