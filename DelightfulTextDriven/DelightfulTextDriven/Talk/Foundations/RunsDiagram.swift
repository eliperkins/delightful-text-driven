import SwiftUI

struct RunsDiagram: View {
    var level: LayoutInspector.Layer?

    @Environment(\.slideStep) private var step

    var body: some View {
        Slide(label: "Lines, runs, and glyphs") {
            VStack(alignment: .leading) {
                sentence
                    .slideText(.runsDiagram)
                    .lineSpacing(Theme.Layout.runsLineSpacing)
                    .textRenderer(LayoutInspector(layer: layer))
                    .padding(.trailing, Theme.Layout.statementTrailing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                legend
                    .slideText(.meta)
            }
            .padding(.top, Theme.Layout.contentTop)
            .padding(.bottom, Theme.Layout.bottom)
        }
    }

    private var sentence: Text {
        // `.bold()` is a no-op on a font with an explicit weight.
        let bold = Text("bold").fontWeight(.bold)
        let flagged = Text("flagged phrase.").customAttribute(Highlight())
        return Text("Runs split at a \(bold) word, an image \(Image(systemName: "sparkles")), and a \(flagged)")
    }

    private var layer: LayoutInspector.Layer {
        level ?? LayoutInspector.Layer.allCases[min(step, LayoutInspector.Layer.allCases.count - 1)]
    }

    @ViewBuilder private var legend: some View {
        HStack(spacing: Theme.Layout.legendSpacing) {
            switch layer {
            case .lines:
                LegendKey(title: "line bounds", color: Theme.line2, dashed: true)
            case .runs:
                LegendKey(title: "run bounds", color: Theme.muted)
                LegendKey(title: "flagged run", color: Theme.accent)
            case .glyphs:
                LegendKey(title: "glyph bounds", color: Theme.ink2)
            }
        }
    }
}

struct LegendKey: View {
    let title: String
    let color: Color
    var dashed = false

    var body: some View {
        HStack(spacing: Theme.Layout.legendSwatchSpacing) {
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: Theme.Layout.legendSwatchWidth, y: 0))
            }
            .stroke(color, style: StrokeStyle(lineWidth: Theme.Layout.diagramStrokeWidth, dash: dashed ? Theme.Layout.diagramDash : []))
            .frame(width: Theme.Layout.legendSwatchWidth, height: Theme.Layout.diagramStrokeWidth)
            Text(title)
        }
    }
}

struct LayoutInspector: TextRenderer {
    enum Layer: CaseIterable {
        case lines, runs, glyphs
    }

    var layer: Layer

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout {
            ctx.draw(line)
        }
        switch layer {
        case .lines: outlineLines(of: layout, in: ctx)
        case .runs: outlineRuns(of: layout, in: ctx)
        case .glyphs: outlineGlyphs(of: layout, in: ctx)
        }
    }

    private func outlineLines(of layout: Text.Layout, in ctx: GraphicsContext) {
        for line in layout {
            ctx.stroke(
                Path(line.typographicBounds.rect),
                with: .color(Theme.line2),
                style: StrokeStyle(lineWidth: Theme.Layout.diagramStrokeWidth, dash: Theme.Layout.diagramDash)
            )
        }
    }

    /// Runs don't expose bold, so only the attribute gets a label.
    private func outlineRuns(of layout: Text.Layout, in ctx: GraphicsContext) {
        for (index, run) in layout.flatMap({ $0 }).enumerated() {
            let flagged = run[Highlight.self] != nil
            let color = flagged ? Theme.accent : Theme.muted
            let rect = run.typographicBounds.rect.insetBy(dx: Theme.Layout.runInset, dy: 0)
            ctx.stroke(Path(rect), with: .color(color), lineWidth: Theme.Layout.diagramStrokeWidth)
            let label = Text(flagged ? "run \(index) · Highlight" : "run \(index)")
                .font(SlideText.caption.font)
                .foregroundStyle(flagged ? Theme.accentText : Theme.muted)
            ctx.draw(label, at: CGPoint(x: rect.minX, y: rect.minY - Theme.Layout.runLabelGap), anchor: .bottomLeading)
        }
    }

    private func outlineGlyphs(of layout: Text.Layout, in ctx: GraphicsContext) {
        for run in layout.flatMap({ $0 }) {
            for glyph in run {
                ctx.stroke(Path(glyph.typographicBounds.rect), with: .color(Theme.ink2), lineWidth: Theme.Layout.glyphStrokeWidth)
            }
        }
    }
}

#Preview {
    SlidePreview(part: .lines) {
        RunsDiagram()
    }
}
