import SwiftUI

struct Greeting {
    let languageCode: String?
    let text: String

    var name: String {
        languageCode.flatMap { Locale(identifier: $0).localizedString(forLanguageCode: $0) } ?? "Emoji"
    }

    static let english = Greeting(languageCode: "en", text: "Hello, world")
    static let arabic = Greeting(languageCode: "ar", text: "مرحبا بالعالم")
    static let hebrew = Greeting(languageCode: "he", text: "שלום עולם")
    static let japanese = Greeting(languageCode: "ja", text: "こんにちは、世界")
    static let hindi = Greeting(languageCode: "hi", text: "नमस्ते दुनिया")
    static let emoji = Greeting(languageCode: nil, text: "👋🏽 🌍")
    static let all = [english, arabic, hebrew, japanese, hindi, emoji]
}

struct EveryLanguage: View {
    @Environment(\.slideStep) private var step

    var body: some View {
        Slide(label: "Layout direction") {
            VStack(alignment: .leading) {
                Text(greeting.text)
                    .slideText(.languageSample)
                    .textRenderer(GlyphInspector())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack(spacing: Theme.Layout.legendSpacing) {
                    Text(greeting.name)
                        .foregroundStyle(Theme.ink)
                    LegendKey(title: "run", color: Theme.muted)
                    LegendKey(title: "glyph and its character index", color: Theme.ink2)
                }
                .slideText(.meta)
            }
            .padding(.top, Theme.Layout.contentTop)
            .padding(.bottom, Theme.Layout.bottom)
        }
    }

    private var greeting: Greeting {
        Greeting.all[min(step, Greeting.all.count - 1)]
    }
}

struct GlyphInspector: TextRenderer {
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let firstIndex = layout.flatMap { $0 }.flatMap(\.characterIndices).min()
        for line in layout {
            // Fallback fonts can rise or drop past the line's own bounds, so measure the line from its runs.
            let lineRect = line.map(\.typographicBounds.rect).reduce(line.typographicBounds.rect) { $0.union($1) }
                .insetBy(dx: -Theme.Layout.runInset, dy: -Theme.Layout.runInset)
            let direction = line.first.map { String(describing: $0.layoutDirection) } ?? ""
            ctx.draw(
                caption(direction, color: Theme.muted),
                at: CGPoint(x: lineRect.minX, y: lineRect.minY - Theme.Layout.runLabelGap),
                anchor: .bottomLeading
            )
            var rowEnds: [CGFloat] = []
            for run in line {
                ctx.draw(run)
                let runRect = run.typographicBounds.rect.insetBy(dx: -Theme.Layout.runInset, dy: -Theme.Layout.runInset)
                ctx.stroke(Path(runRect), with: .color(Theme.muted), lineWidth: Theme.Layout.diagramStrokeWidth)
                for glyph in run {
                    let glyphRect = glyph.typographicBounds.rect
                    ctx.stroke(Path(glyphRect), with: .color(Theme.ink2), lineWidth: Theme.Layout.glyphStrokeWidth)
                    guard let firstIndex, let characterIndex = glyph.characterIndices.first else { continue }
                    let number = ctx.resolve(caption("\(firstIndex.distance(to: characterIndex))", color: Theme.ink2))
                    let size = number.measure(in: CGSize(width: CGFloat.infinity, height: .infinity))
                    let minX = glyphRect.midX - size.width / 2
                    // Zero-width marks share an x with their base glyph, so their numbers drop to the next free row.
                    let row = rowEnds.firstIndex { $0 <= minX } ?? rowEnds.count
                    if row == rowEnds.count { rowEnds.append(0) }
                    rowEnds[row] = minX + size.width + Theme.Layout.runInset
                    let y = lineRect.maxY + Theme.Layout.runLabelGap + CGFloat(row) * size.height
                    ctx.draw(number, at: CGPoint(x: minX, y: y), anchor: .topLeading)
                }
            }
        }
    }

    private func caption(_ string: String, color: Color) -> Text {
        Text(string)
            .font(SlideText.caption.font)
            .foregroundStyle(color)
    }
}

#Preview {
    SlidePreview(step: 4, part: .lines) {
        EveryLanguage()
    }
}
