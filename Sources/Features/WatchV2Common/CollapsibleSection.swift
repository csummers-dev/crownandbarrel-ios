import SwiftUI

public struct CollapsibleSection<Content: View>: View {
    private let title: String
    @State private var isExpanded: Bool
    private let content: () -> Content

    public init(title: String, initiallyExpanded: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self._isExpanded = State(initialValue: initiallyExpanded)
        self.content = content
    }

    public var body: some View {
        Section {
            DisclosureGroup(isExpanded: $isExpanded) {
                content()
            } label: {
                Text(title)
            }
        }
    }
}


