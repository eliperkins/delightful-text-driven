import SwiftUI

struct HighlightRuns: View {
    @Environment(\.slideStep) private var step

    var body: some View {
        Split(label: "Custom attributes", caption: ".customAttribute(Highlight())") {
            CodeBlock(step == 0 ? Snippets.highlightUsage : Snippets.highlighter)
        } live: {
            // slide: highlightUsage
            let fox = Text("quick brown fox")
                .customAttribute(Highlight())
            Text("The \(fox) jumps over a lazy dog.")
                .textRenderer(Highlighter())
            // slide: end
                .tint(Theme.deep)
                .slideText(SlideText.displayDemo.color(Theme.ink))
        }
    }
}

// slide: highlightAttribute
struct Highlight: TextAttribute {}
// slide: end

struct Highlighter: TextRenderer {
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        // slide: highlighter
        for line in layout {
            for run in line {
                if run[Highlight.self] != nil {
                    let r = run.typographicBounds.rect
                    ctx.fill(
                        Path(r),
                        with: .style(.tint)
                    )
                }
                ctx.draw(run)
            }
        }
        // slide: end
    }
}

extension Snippets {
    static var highlightUsage: String { region("highlightAttribute") + "\n\n" + region("highlightUsage") }
    static var highlighter: String { region("highlighter") }
}
