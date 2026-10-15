import SwiftUI

struct StrikethroughLines: View {
    @Environment(\.slideStep) private var step
    @State private var progress = 0.0

    var body: some View {
        Split(label: "A delightful strikethrough", caption: "Strikethrough(progress: \(progress.formatted(.number.precision(.fractionLength(0...2)))))") {
            CodeBlock(Snippets.strikethrough, focus: focus)
        } live: {
            Text(Foundations.sample)
                .textRenderer(Strikethrough(progress: progress))
                .tint(Theme.ink)
                .slideText(SlideText.displayDemo.color(Theme.accentText))
            Slider(value: $progress, in: 0...1)
                .controlSize(.large)
                .tint(Theme.accent)
        }
        .onChange(of: step, initial: true) {
            progress = stepProgress
        }
    }

    private var stepProgress: Double {
        switch step {
        case 0: 0
        case 1: 0.5
        default: 1
        }
    }

    private var focus: ClosedRange<Int>? {
        switch step {
        case 0: 1...3
        case 1: 4...14
        default: nil
        }
    }
}

struct Strikethrough: TextRenderer {
    var progress: Double

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        // slide: strikethrough
        var left = progress * layout.reduce(0) {
            $0 + $1.typographicBounds.width
        }
        for line in layout {
            let r = line.typographicBounds.rect
            let length = min(left, r.width)
            left -= length
            let strike = CGRect(
                x: r.minX, y: r.midY - 3,
                width: length, height: 6)
            ctx.draw(line)
            ctx.fill(Capsule().path(in: strike),
                with: .style(.tint))
        }
        // slide: end
    }
}

extension Snippets {
    static var strikethrough: String { region("strikethrough") }
}
