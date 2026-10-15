import SwiftUI

struct StrikeComparison: View {
    static let todo = "Measure twice, cut once"

    @State private var struck = false

    var body: some View {
        Split(label: "Use the platform", caption: "withAnimation(.bouncy)") {
            CodeBlock(Snippets.strikeComparison)
        } live: {
            VStack(spacing: Theme.Layout.comparisonSpacing) {
                example(".strikethrough") {
                    // slide: builtInStrike
                    Text(Self.todo)
                        .strikethrough(struck,
                            color: .white)
                    // slide: end
                }
                example("Strikethrough") {
                    // slide: rendererStrike
                    Text(Self.todo)
                        .textRenderer(Strikethrough(
                            progress: struck ? 1 : 0))
                    // slide: end
                }
            }
            Button(struck ? "Restore" : "Strike") {
                withAnimation(.bouncy) {
                    struck.toggle()
                }
            }
            .buttonStyle(.demo)
        }
    }

    private func example(_ name: String, @ViewBuilder text: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Theme.Layout.liveTagSpacing) {
            Text(name)
                .slideText(.caption)
            text()
                .tint(.white)
                .slideText(SlideText.displayDemoCompact.color(Theme.accentText))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension Snippets {
    static var strikeComparison: String { region("builtInStrike") + "\n\n" + region("rendererStrike") }
}
