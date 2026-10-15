import SwiftUI

struct LyricCode: View {
    @State private var time = LyricEffect.duration * Clip.thumbnailFraction

    var body: some View {
        Split(label: "Fill each word as it's sung", caption: "LyricFill(time: \(time.formatted(.number.precision(.fractionLength(1)))))") {
            CodeBlock(Snippets.lyric)
        } live: {
            Text(LyricEffect.lyric)
                .attributedTextFormattingDefinition(SlideTextFormatting())
                .textRenderer(LyricFill(time: time))
                .slideText(SlideText.displayDemo.color(Theme.accentText))
            Slider(value: $time, in: 0...LyricEffect.duration)
                .controlSize(.large)
                .tint(Theme.accent)
        }
    }
}

extension Snippets {
    static var lyric: String { region("lyric", file: Self.replicasFile) }
}

#Preview {
    SlidePreview(part: .animation) {
        LyricCode()
    }
}
