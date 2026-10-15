import SwiftUI

struct WaveText: View {
    @Environment(\.slideRenderMode) private var renderMode
    @State private var phase = 0.0

    var body: some View {
        Split(label: "Animatable", caption: "Wave(phase: 0 → 2π)") {
            CodeBlock(Snippets.waveAnimation)
        } live: {
            if renderMode == .live {
                // slide: waveAnimation
                Text("Hello, world")
                    .textRenderer(Wave(phase: phase))
                    .onAppear {
                        withAnimation(
                            .linear(duration: 2)
                            .repeatForever(autoreverses: false)
                        ) {
                            phase = 2 * .pi
                        }
                    }
                // slide: end
                    .slideText(SlideText.displayDemo.color(Theme.accentText))
            } else {
                Text("Hello, world")
                    .slideText(SlideText.displayDemo.color(Theme.accentText))
            }
        }
    }
}

extension Snippets {
    static var waveAnimation: String { region("waveAnimation") }
}
