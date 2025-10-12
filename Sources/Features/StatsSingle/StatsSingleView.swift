import SwiftUI

/// Single-page Stats container (no filters, no drill-ins).
/// Renders all sections (Collection, Wearing, Finance, Fun) in one long scroll.
public struct StatsSingleView: View {
    public init() {}

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header with title to match other pages (settings gear via RootView toolbar)
                    Text("Stats")
                        .font(.largeTitle).bold()
                        .padding(.top, 8)

                    // Sections (placeholders for now)
                    sectionHeader("Collection")
                        .id(SectionID.collection)
                    CollectionSection()

                    sectionHeader("Wearing")
                        .id(SectionID.wearing)
                    WearingSection()

                    sectionHeader("Finance")
                        .id(SectionID.finance)
                    FinanceSection()

                    sectionHeader("Fun")
                        .id(SectionID.fun)
                    FunSection()
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                .foregroundStyle(AppColors.textPrimary)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2).bold()
            .padding(.top, 8)
    }

    private func placeholderCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

}

private enum SectionID: Hashable {
    case collection, wearing, finance, fun
}


