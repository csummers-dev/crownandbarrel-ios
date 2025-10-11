import SwiftUI

public struct EnumPickerWithOther<Value>: View where Value: Hashable {
    public let title: String
    @Binding public var selection: Value?
    public let options: [Value]
    public let display: (Value) -> String
    public let otherFromString: (String) -> Value
    public let isOther: (Value) -> Bool

    @State private var isChoosingOther: Bool = false
    @State private var otherText: String = ""

    public init(title: String,
                selection: Binding<Value?>,
                options: [Value],
                display: @escaping (Value) -> String,
                otherFromString: @escaping (String) -> Value,
                isOther: @escaping (Value) -> Bool) {
        self.title = title
        self._selection = selection
        self.options = options
        self.display = display
        self.otherFromString = otherFromString
        self.isOther = isOther
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Picker(title, selection: Binding(get: {
                if let selection { return display(selection) }
                return ""
            }, set: { label in
                if label == "Other…" {
                    isChoosingOther = true
                    selection = nil
                } else if let matched = options.first(where: { display($0) == label }) {
                    selection = matched
                    isChoosingOther = false
                }
            })) {
                Text("")
                    .tag("")
                ForEach(options, id: \.self) { value in
                    Text(display(value)).tag(display(value))
                }
                Text("Other…").tag("Other…")
            }
            .pickerStyle(.menu)

            if isChoosingOther || (selection.map { isOther($0) } ?? false) {
                TextField("Enter other", text: $otherText)
                    .onChange(of: otherText) { _, newValue in
                        if !newValue.isEmpty {
                            selection = otherFromString(newValue)
                        }
                    }
            }
        }
    }
}
