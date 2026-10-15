import SwiftUI

struct RevealCode: View {
    @Environment(\.slideStep) private var step
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var replays = 0

    var body: some View {
        Split(label: "Animations with time", caption: ".transition(TextReveal())") {
            CodeBlock(step == 0 ? Snippets.reveal : Snippets.rise)
        } live: {
            Text(SlideText.emphasized("Delightful *Text-Driven*"))
                .attributedTextFormattingDefinition(SlideTextFormatting())
                .slideText(SlideText.displayDemo)
                .id(replays)
                .transition(.asymmetric(insertion: .textReveal(reduceMotion: reduceMotion), removal: .identity))
            Button("Replay") {
                withAnimation(Theme.Motion.reveal) {
                    replays += 1
                }
            }
            .buttonStyle(.demo)
        }
    }
}
