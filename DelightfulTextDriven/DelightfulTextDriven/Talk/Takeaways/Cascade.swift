import SwiftUI

struct Cascade: View {
    @Environment(\.slideStep) private var step
    @Environment(\.slideRenderMode) private var renderMode
    @State private var phase = 0.0

    var body: some View {
        Split(label: "Combining renderers", caption: step == 0 ? "The closest renderer wins" : "Wrap to combine") {
            CodeBlock(step == 0 ? Snippets.cascade : Snippets.counted)
        } live: {
            // slide: cascade
            VStack {
                Text("Every Text")
                Text("gets the wave,")
                Text("but this one")
                    .textRenderer(
                        Strikethrough(progress: 1))
            }
            .textRenderer(Wave(phase: phase))
            // slide: end
            .tint(Theme.ink)
            .slideText(SlideText.displayDemo.color(Theme.accentText))
            .onAppear {
                guard renderMode == .live else { return }
                withAnimation(.linear(duration: Self.wavePeriod).repeatForever(autoreverses: false)) {
                    phase = 2 * .pi
                }
            }
        }
    }

    static let wavePeriod = 2.0
}

extension Snippets {
    static var cascade: String { region("cascade") }
}
