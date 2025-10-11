import SwiftUI

/// Component for displaying key-value specification pairs with smart visibility.
/// - What: Renders a specification detail as a labeled key-value pair.
/// - Why: Provides consistent styling for technical specifications throughout detail views.
/// - How: Shows label on left, value on right, with proper typography hierarchy. Only renders when value is non-nil.
public struct SpecificationRow: View {
    public let label: String
    public let value: String
    
    @Environment(\.themeToken) private var themeToken
    
    /// Creates a specification row that only displays when value is present.
    /// - Parameters:
    ///   - label: The specification label (e.g., "Material", "Diameter")
    ///   - value: The specification value (e.g., "Stainless Steel", "40mm")
    /// - Note: If value is nil or empty, this row will not be displayed.
    public init?(label: String, value: String?) {
        // Smart visibility: return nil if no value to display
        guard let value = value, !value.isEmpty else {
            return nil
        }
        self.label = label
        self.value = value
    }
    
    /// Creates a specification row with guaranteed non-nil value.
    /// - Parameters:
    ///   - label: The specification label
    ///   - value: The specification value (non-optional)
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.md) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, AppSpacing.xxs)
        .id(themeToken) // Force refresh on theme change
    }
}

// MARK: - Convenience Initializers

public extension SpecificationRow {
    /// Creates a specification row from an optional Int value.
    init?(label: String, value: Int?) {
        guard let value = value else { return nil }
        self.init(label: label, value: String(value))
    }
    
    /// Creates a specification row from an optional Double value with formatting.
    /// - Parameters:
    ///   - label: The specification label
    ///   - value: The double value
    ///   - precision: Number of decimal places (default: 1)
    init?(label: String, value: Double?, precision: Int = 1) {
        guard let value = value else { return nil }
        // Show decimals only if non-zero
        let formatted = value.truncatingRemainder(dividingBy: 1) == 0 
            ? String(format: "%.0f", value)
            : String(format: "%.\(precision)f", value)
        self.init(label: label, value: formatted)
    }
    
    /// Creates a specification row from an optional Bool value (only shows if true).
    /// - Parameters:
    ///   - label: The specification label
    ///   - value: The boolean value
    ///   - trueText: Text to display when true (default: "Yes")
    init?(label: String, boolValue value: Bool?, trueText: String = "Yes") {
        guard let value = value, value == true else { return nil }
        self.init(label: label, value: trueText)
    }
    
    /// Creates a specification row from a RawRepresentable enum (e.g., enums with string raw values).
    init?<T: RawRepresentable>(label: String, enum value: T?) where T.RawValue == String {
        guard let value = value else { return nil }
        let formatted = value.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        self.init(label: label, value: formatted)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Specification Rows") {
    ScrollView {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            DetailSectionHeader(title: "Case Specifications")
            
            VStack(spacing: 0) {
                SpecificationRow(label: "Material", value: "Stainless Steel")
                SpecificationRow(label: "Finish", value: "Brushed")
                SpecificationRow(label: "Shape", value: "Round")
                SpecificationRow(label: "Diameter", value: Double(40.5), precision: 1).map { row in
                    row
                }
                SpecificationRow(label: "Thickness", value: Double(12), precision: 1).map { row in
                    row
                }
                SpecificationRow(label: "Lug to Lug", value: Double(48.5), precision: 1).map { row in
                    row
                }
                SpecificationRow(label: "Lug Width", value: 20).map { row in
                    row
                }
            }
            
            DetailSectionHeader(title: "Water Resistance")
            
            VStack(spacing: 0) {
                SpecificationRow(label: "Water Resistance", value: "100m")
                SpecificationRow(label: "Crown Type", value: "Screw-down")
                SpecificationRow(label: "Crown Guard", boolValue: true).map { row in
                    row
                }
            }
            
            DetailSectionHeader(title: "Movement")
            
            VStack(spacing: 0) {
                SpecificationRow(label: "Type", value: "Automatic")
                SpecificationRow(label: "Caliber", value: "ETA 2824-2")
                SpecificationRow(label: "Power Reserve", value: "38 hours")
                SpecificationRow(label: "Frequency", value: "28,800 vph")
                SpecificationRow(label: "Jewels", value: 25).map { row in
                    row
                }
            }
            
            Text("Note: Empty/nil values are automatically hidden")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.top, AppSpacing.lg)
            
            Spacer()
        }
        .padding()
    }
    .background(AppColors.background)
}
#endif

