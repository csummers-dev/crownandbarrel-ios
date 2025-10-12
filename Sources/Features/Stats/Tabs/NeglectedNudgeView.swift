import SwiftUI

public struct NeglectedNudgeSuggestion: Identifiable, Equatable {
    public let id = UUID()
    public let watchName: String
    public let suggestedDate: Date
}

public struct NeglectedNudgeView: View {
    public let suggestions: [NeglectedNudgeSuggestion]

    public init(suggestions: [NeglectedNudgeSuggestion]) {
        self.suggestions = suggestions
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upcoming Suggestions").font(.headline).foregroundStyle(.secondary)
            if suggestions.isEmpty {
                Text("No neglected watches—nice rotation!").foregroundStyle(.secondary)
            } else {
                ForEach(suggestions) { s in
                    HStack {
                        Text(s.watchName)
                        Spacer()
                        Text(formatDate(s.suggestedDate))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
}


