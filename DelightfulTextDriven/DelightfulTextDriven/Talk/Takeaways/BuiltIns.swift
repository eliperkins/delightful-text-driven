import SwiftUI

struct BuiltIns: View {
    @State private var count = 99

    var body: some View {
        Split(label: "Use the platform", caption: "No TextRenderer") {
            CodeBlock(Snippets.builtIns)
        } live: {
            Group {
                // slide: numericText
                Text(count, format: .number)
                    .contentTransition(.numericText(
                        value: Double(count)))
                // slide: end
                // slide: gradient
                Text("Delight")
                    .foregroundStyle(.linearGradient(
                        colors: [
                            Theme.accentText, Theme.ink2],
                        startPoint: .leading,
                        endPoint: .trailing))
                // slide: end
            }
            .slideText(.displayDemo)
            Button("Add one") {
                withAnimation {
                    count += 1
                }
            }
            .buttonStyle(.demo)
        }
    }
}

extension Snippets {
    static var builtIns: String { region("numericText") + "\n\n" + region("gradient") }
}
