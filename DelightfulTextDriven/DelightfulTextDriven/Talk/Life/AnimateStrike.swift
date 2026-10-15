import SwiftUI

struct AnimateStrike: View {
    @State private var struck = false

    var body: some View {
        Split(label: "Animatable", caption: "withAnimation(.bouncy)") {
            CodeBlock(Snippets.animatableStrike)
        } live: {
            Text(Foundations.sample)
                .textRenderer(Strikethrough(progress: struck ? 1 : 0))
                .tint(Theme.ink)
                .slideText(SlideText.displayDemo.color(Theme.accentText))
            // slide: strikeButton
            Button(struck ? "Restore" : "Strike") {
                withAnimation(.bouncy) {
                    struck.toggle()
                }
            }
            // slide: end
            .buttonStyle(.demo)
        }
    }
}

// A bouncy spring dips below 0 on the way back, which would draw the strike backward.
// slide: animatableStrike
extension Strikethrough {
    var animatableData: Double {
        get { progress }
        set { progress = max(0, newValue) }
    }
}
// slide: end

extension Snippets {
    static var animatableStrike: String { region("animatableStrike") + "\n\n" + region("strikeButton") }
}
