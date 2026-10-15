import SwiftUI

struct StrikethroughDirection: View {
    @Environment(\.slideStep) private var step
    @State private var progress = 0.5

    var body: some View {
        Split(label: "Layout direction", caption: "progress: \(progress.formatted(.number.precision(.fractionLength(0...2))))") {
            if step == 0 {
                CodeBlock(Snippets.strikethrough, focus: 8...10)
            } else {
                CodeBlock(Snippets.directionalStrikethrough, focus: 5...8)
            }
        } live: {
            Group {
                let text = Text(Greeting.hebrew.text)
                if step == 0 {
                    text.textRenderer(Strikethrough(progress: progress))
                } else {
                    text.textRenderer(DirectionalStrikethrough(progress: progress))
                }
            }
            .tint(Theme.ink)
            .slideText(SlideText.displayDemo.color(Theme.accentText))
            Slider(value: $progress, in: 0...1)
                .environment(\.layoutDirection, step == 0 ? .leftToRight : .rightToLeft)
                .controlSize(.large)
                .tint(Theme.accent)
        }
    }
}

struct DirectionalStrikethrough: TextRenderer {
    var progress: Double

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        var left = progress * layout.reduce(0) {
            $0 + $1.typographicBounds.width
        }
        // slide: directionalStrikethrough
        for line in layout {
            let r = line.typographicBounds.rect
            let length = min(left, r.width)
            left -= length
            let isRTL = line.first?.layoutDirection
                == .rightToLeft
            let strike = CGRect(
                x: isRTL ? r.maxX - length : r.minX,
                y: r.midY - 3,
                width: length, height: 6)
            ctx.draw(line)
            ctx.fill(Capsule().path(in: strike),
                with: .style(.tint))
        }
        // slide: end
    }
}

extension Snippets {
    static var directionalStrikethrough: String { region("directionalStrikethrough") }
}
