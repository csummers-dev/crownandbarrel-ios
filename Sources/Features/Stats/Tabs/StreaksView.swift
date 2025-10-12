import SwiftUI

public struct StreaksView: View {
    public let streaks: StreaksResult

    public init(streaks: StreaksResult) { self.streaks = streaks }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Streaks").font(.headline).foregroundStyle(.secondary)
            HStack { Text("Daily streak"); Spacer(); Text("\(streaks.currentDailyStreak) d").foregroundStyle(.secondary) }
            HStack { Text("No-repeat streak"); Spacer(); Text("\(streaks.currentNoRepeatStreakDistinctWatches) d").foregroundStyle(.secondary) }
            if !streaks.currentBrandStreaks.isEmpty {
                Text("Brand streaks").font(.subheadline).foregroundStyle(.secondary)
                ForEach(streaks.currentBrandStreaks.sorted(by: { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }), id: \.key) { brand, count in
                    HStack { Text(brand); Spacer(); Text("\(count) d").foregroundStyle(.secondary) }
                }
            }
        }
    }
}


