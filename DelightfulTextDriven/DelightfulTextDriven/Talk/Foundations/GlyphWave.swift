import SwiftUI

struct GlyphWave: View {
    var body: some View {
        Split(label: "Move each glyph", caption: ".textRenderer(Wave())") {
            CodeBlock(Snippets.wave)
        } live: {
            Text("Hello, world")
                .textRenderer(Wave())
                .slideText(SlideText.displayDemo.color(Theme.accentText))
        }
    }
}

struct Wave: TextRenderer {
    var phase = 0.0

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout {
            for run in line {
                for (i, glyph) in run.enumerated() {
                    var copy = ctx
                    let y = sin(phase + Double(i) / 1.5)
                    copy.translateBy(x: 0, y: y * 24)
                    copy.draw(glyph)
                }
            }
        }
    }
}

extension Snippets {
    static let wave = """
        for line in layout {
          for run in line {
            for (i, glyph) in run.enumerated() {
              var copy = ctx
              let y = sin(Double(i) / 1.5)
              copy.translateBy(x: 0, y: y * 24)
              copy.draw(glyph)
            }
          }
        }
        """
}

#Preview {
    SlidePreview(part: .lines) {
        GlyphWave()
    }
}
