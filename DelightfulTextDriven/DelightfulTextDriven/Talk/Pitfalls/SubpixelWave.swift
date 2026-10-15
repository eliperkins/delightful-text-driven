import SwiftUI

/// Enlarged 1× pixels: at full size on a Retina display, the one-pixel jumps are too small to see.
struct SubpixelWave: View {
    @Environment(\.slideStep) private var step

    var body: some View {
        Split(label: "Smooth glyph motion", caption: "1× pixels, enlarged") {
            CodeBlock(step == 0 ? Snippets.snappedDrift : Snippets.smoothDrift, focus: step == 0 ? 7...7 : 7...8)
        } live: {
            TimelineView(.animation) { context in
                let phase = context.date.timeIntervalSinceReferenceDate * Self.speed
                VStack(spacing: Theme.Layout.livePaneSpacing) {
                    sample(SnappedDrift(phase: phase), caption: "draw(glyph)")
                    sample(SmoothDrift(phase: phase), caption: ".disablesSubpixelQuantization")
                }
            }
        }
    }

    private static let speed = 1.2

    private func sample(_ renderer: some TextRenderer, caption: String) -> some View {
        VStack(spacing: Theme.Layout.frameTileSpacing) {
            Group {
                if let pixels = pixels(of: renderer) {
                    Image(nsImage: pixels)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(height: Theme.Layout.pixelZoomHeight)
            Text(caption)
                .slideText(.caption)
        }
    }

    private func pixels(of renderer: some TextRenderer) -> NSImage? {
        let image = ImageRenderer(content: Text("Hello")
            .textRenderer(renderer)
            .slideText(SlideText.pixelZoomSample.color(Theme.accentText))
            .padding(Theme.Layout.pixelZoomBleed))
        image.scale = 1
        return image.nsImage
    }
}

struct SnappedDrift: TextRenderer {
    var phase: Double

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        // slide: snappedDrift
        for line in layout {
            for run in line {
                for (i, glyph) in run.enumerated() {
                    var copy = ctx
                    let y = sin(phase + Double(i) / 1.5)
                    copy.translateBy(x: 0, y: y * 3)
                    copy.draw(glyph)
                }
            }
        }
        // slide: end
    }
}

struct SmoothDrift: TextRenderer {
    var phase: Double

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        // slide: smoothDrift
        for line in layout {
            for run in line {
                for (i, glyph) in run.enumerated() {
                    var copy = ctx
                    let y = sin(phase + Double(i) / 1.5)
                    copy.translateBy(x: 0, y: y * 3)
                    copy.draw(glyph, options:
                        .disablesSubpixelQuantization)
                }
            }
        }
        // slide: end
    }
}

extension Snippets {
    static var snappedDrift: String { region("snappedDrift") }
    static var smoothDrift: String { region("smoothDrift") }
}

#Preview {
    SlidePreview(step: 1, part: .pitfalls) {
        SubpixelWave()
    }
}
