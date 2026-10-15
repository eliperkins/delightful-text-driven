import SwiftUI

struct StripedLines: View {
    var body: some View {
        Split(label: "Drawing text", caption: ".textRenderer(Striped())") {
            CodeBlock(Snippets.striped, focus: 6...12)
        } live: {
            Text(Foundations.sample)
                .slideText(SlideText.displayDemo.color(Theme.accentText))
                .textRenderer(Striped())
        }
    }
}

// slide: striped
struct Striped: TextRenderer {
    func draw(
        layout: Text.Layout,
        in ctx: inout GraphicsContext
    ) {
        for (i, line) in layout.enumerated() {
            var copy = ctx
            if i % 2 == 1 {
                copy.opacity = 0.5
            }
            copy.draw(line)
        }
    }
}
// slide: end

extension Snippets {
    static var striped: String { region("striped") }
}
