import SwiftUI
import Charts

struct WeekdayDatum: Identifiable { let id = UUID(); let label: String; let count: Int }

public struct WeekdayWeekendBreakdownView: View {
    public let breakdown: WeekdayWeekendBreakdown

    public init(breakdown: WeekdayWeekendBreakdown) { self.breakdown = breakdown }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekday vs Weekend").font(.headline).foregroundStyle(.secondary)
            HStack {
                Text("Weekday")
                Spacer()
                Text("\(breakdown.weekdayTotal)").foregroundStyle(.secondary)
            }
            HStack {
                Text("Weekend")
                Spacer()
                Text("\(breakdown.weekendTotal)").foregroundStyle(.secondary)
            }

            Chart(data) { item in
                BarMark(x: .value("Day", item.label), y: .value("Count", item.count))
            }
            .frame(height: 160)
        }
    }

    private var data: [WeekdayDatum] {
        let labels = [1:"Sun",2:"Mon",3:"Tue",4:"Wed",5:"Thu",6:"Fri",7:"Sat"]
        return (1...7).map { wd in
            WeekdayDatum(label: labels[wd]!, count: breakdown.countsByWeekday[wd] ?? 0)
        }
    }
}


