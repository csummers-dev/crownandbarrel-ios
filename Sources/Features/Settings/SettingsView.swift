import SwiftUI

/// SettingsView presents user preferences that affect global app behavior.
/// - What: Currently exposes the theme preference (System/Light/Dark).
/// - Why: Users expect control over appearance; tying to `@AppStorage` persists
///   the choice across launches without custom persistence code.
/// - How: The picker binds to a raw `String` stored in `AppStorage` that
///   corresponds to `ThemePreference.rawValue`. The `ThemeManager` reads this
///   value at app start and applies the appropriate color scheme.
struct SettingsView: View {
    @Environment(\.themeToken) private var themeToken
    /// Persisted raw value for the selected theme preference.
    /// Using `@AppStorage` keeps the setting in `UserDefaults` under the key
    /// `themePreference` and automatically updates the UI when changed.
    /// Combined theme selector: stores the selected theme id (drives color scheme and palette)
    @AppStorage("selectedThemeId") private var selectedThemeId: String = ThemeCatalog.shared.defaultThemeId

    /// The root content view for settings. Uses a `Form` to match iOS
    /// conventions and to ensure dynamic type and accessibility work out of the box.
    var body: some View {
        // What: Build the Settings form with a custom header row and a native Section beneath.
        // Why: UIKit's grouped Section headers use system backgrounds and can resist live theme
        //      updates. A plain row gives us precise control over color while the native Section
        //      preserves correct inline picker layout.
        // How: Render `appearanceHeaderRow` (a normal row) immediately followed by
        //      `appearanceSection` (native Section). Collapse inter-section spacing and theme
        //      backgrounds at the row level.
        Form {
            appearanceHeaderRow
            appearanceSection
        }
        .listSectionSeparator(.hidden, edges: .all)
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .listStyle(.insetGrouped)
        // Reduce vertical space between our custom header row and the following section
        .listSectionSpacing(.custom(0))
        // What: Pull the entire form content slightly upward to reduce the gap under the
        //       navigation bar while preserving spacing between individual rows/sections.
        // Why: InsetGrouped lists add a comfortable top margin; design calls for a tighter top.
        // How: Apply a small negative top content margin to the scroll content only.
        .contentMargins(.top, -8, for: .scrollContent)
        .id(themeToken + "-settings-form")
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(AppTypography.titleCompact)
                    .foregroundStyle(AppColors.accent)
            }
        }
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .id(themeToken)
    }
}

// MARK: - Subviews
private extension SettingsView {
    /// The native Section containing the theme inline picker.
    /// - What: Keeps UIKit/SwiftUI defaults so the inline list behaves correctly.
    /// - Why: Wrapping this in custom containers can collapse the inline layout.
    /// - How: Style rows with theme primary background; omit the native header and use
    ///        a custom row right above to fully control color and spacing.
    var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $selectedThemeId) {
                ForEach(ThemeCatalog.shared.orderedThemes) { theme in
                    ThemeRow(theme: theme)
                        .tag(theme.id)
                }
            }
            .pickerStyle(.inline)
            .tint(AppColors.textPrimary)
            .foregroundStyle(AppColors.textPrimary)
            .listRowBackground(AppColors.background)
            .id(themeToken + "-settings-picker")
        } header: { EmptyView() }
    }

    /// A standalone header row that mimics grouped header styling but is a normal row,
    /// so we fully control its background without involving UIKit's header containers.
    /// A compact, theme-colored row that visually serves as the "Appearance" header.
    /// - What: Drawn as a normal row so we can set the exact background color.
    /// - Why: Avoids relying on UIKit's grouped header containers which can use system tints.
    /// - How: Tight paddings + negative bottom padding minimize gap to the inline picker.
    var appearanceHeaderRow: some View {
        HStack {
            Text("Appearance")
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.none)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        // Tight gap under the header while keeping layout stable
        .padding(.bottom, -6)
        .listRowSeparator(.hidden)
        .listRowBackground(AppColors.background)
        .accessibilityIdentifier("SettingsAppearanceHeaderRow")
    }
}

private struct ThemeRow: View {
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 8) {
            Text(theme.name)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Swatches(hexes: Array(theme.colors.chartPalette.prefix(5)))
        }
    }
}

/// A local header view that paints the theme's primary background behind the section title
/// without affecting other screens via UIAppearance. Typography and spacing are close to the
/// default grouped style so it blends with system expectations.
private struct SettingsHeader: View {
    let title: String

    var body: some View {
        // Header-bleed overlay (Option B): Paint the theme primary background and
        // extend it slightly to the grouped list's horizontal edges using a
        // conservative negative padding. This visually covers the system tint
        // seen behind the header without changing other sections.
        ZStack(alignment: .leading) {
            AppColors.background
            Text(title)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.none)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // Bleed horizontally toward grouped list edges. Using AppSpacing.md to
        // stay token-driven; increase to -AppSpacing.lg if a wider bleed is needed.
        .padding(.horizontal, -AppSpacing.md)
        // Probe and theme the UIKit header container that wraps this SwiftUI header,
        // without affecting other screens. This sets the parent UITableViewHeaderFooterView
        // backgrounds to the theme primary color. Remove after validation if desired.
        .background(HeaderContainerProbe())
        .accessibilityIdentifier("SettingsAppearanceHeaderContainer")
    }
}

// MARK: - UIKit header container probe
/// A zero-size UIView that climbs its superview chain to find the enclosing
/// UITableViewHeaderFooterView (the grouped section header container) and
/// applies the theme primary background to its relevant views. Scoped to where
/// it is inserted (only the Settings "Appearance" header).
private struct HeaderContainerProbe: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Walk up to find the grouped header container
        var parent: UIView? = uiView.superview
        while let p = parent, !(p is UITableViewHeaderFooterView) { parent = p.superview }
        guard let header = parent as? UITableViewHeaderFooterView else { return }
        let primary = UIColor(AppColors.background)
        header.tintColor = primary
        header.backgroundView?.backgroundColor = primary
        header.contentView.backgroundColor = primary
        // Subviews sometimes carry system backgrounds; clear them defensively
        for sub in header.contentView.subviews { sub.backgroundColor = sub.backgroundColor == .systemGroupedBackground ? primary : sub.backgroundColor }
        header.setNeedsLayout(); header.layoutIfNeeded()

        // Also adjust immediate ancestor containers that may render the larger frame behind the header
        var ancestor: UIView? = header.superview
        while let a = ancestor, !(a is UITableView) {
            a.backgroundColor = primary
            ancestor = a.superview
        }
    }
}
private struct Swatches: View {
    let hexes: [String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(hexes.enumerated()), id: \.offset) { _, hex in
                Circle()
                    .fill(Color(themeString: hex) ?? .clear)
                    .frame(width: 10, height: 10)
            }
        }
    }
}
