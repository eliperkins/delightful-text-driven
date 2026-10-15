import SwiftUI

struct MeetTextRenderer: View {
    @Environment(\.slideStep) private var step

    var body: some View {
        Split(label: "Meet TextRenderer", caption: ".textRenderer(Passthrough())") {
            CodeBlock(Snippets.passthrough, focus: step == 0 ? 1...5 : 6...8)
        } live: {
            Text(Foundations.sample)
                .slideText(SlideText.displayDemo.color(Theme.accentText))
                .textRenderer(Passthrough())
        }
    }
}

// slide: passthrough
struct Passthrough: TextRenderer {
    func draw(
        layout: Text.Layout,
        in ctx: inout GraphicsContext
    ) {
        for line in layout {
            ctx.draw(line)
        }
    }
}
// slide: end

extension Snippets {
    static var passthrough: String { region("passthrough") }
}
