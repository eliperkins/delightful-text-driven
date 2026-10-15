import SwiftUI

struct TranscriptRenderer: TextRenderer {
    // slide: highlightStyle
    enum HighlightStyle {
        case deepPill
        case spotlight
    }
    // slide: end

    struct Tuning: Equatable {
        var blurs = true
        var culls = true
        var drawsGlyphs = false
    }

    var time: TimeInterval
    var style = HighlightStyle.deepPill
    var tuning = Tuning()
    /// The viewport's height; the current line's center sits halfway down.
    var height: CGFloat

    private let lineFade: TimeInterval = 0.35
    private let wordFade: TimeInterval = 0.12
    /// Words shorter than this are over before a fade would finish, so their pill appears at full opacity.
    private let shortWord: TimeInterval = 0.2
    private let dimBlur: CGFloat = 5
    private let dimOpacity = 0.8
    private let spotlightPastOpacity = 0.55

    var displayPadding: EdgeInsets {
        EdgeInsets(top: Theme.Layout.transcriptBleed, leading: Theme.Layout.transcriptBleed, bottom: Theme.Layout.transcriptBleed, trailing: Theme.Layout.transcriptBleed)
    }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let lines = Array(layout)
        let starts = lines.map { line in
            line.compactMap { $0[WordTime.self]?.range.lowerBound }.min()
        }
        let current = starts.lastIndex { ($0 ?? .infinity) <= time } ?? 0
        let previous = max(current - 1, 0)
        let focus = UnitCurve.easeInOut.value(at: clamp((time - (starts[current] ?? 0)) / lineFade))
        // The latest word to start stays current until the next one starts, so short words and pauses never leave a gap.
        let wordStart = lines[current].compactMap { $0[WordTime.self]?.range.lowerBound }.filter { $0 <= time }.max()

        let from = lines[previous].typographicBounds.rect.midY
        let to = lines[current].typographicBounds.rect.midY
        let offset = height / 2 - (from + (to - from) * focus)
        ctx.translateBy(x: 0, y: offset)

        let visible = lines.indices.filter { i in
            !tuning.culls || isVisible(lines[i].typographicBounds.rect, offset: offset)
        }

        // One layer, so one blur pass, for every line that is fully dimmed.
        ctx.drawLayer { layer in
            layer.opacity = dimOpacity
            if tuning.blurs {
                layer.addFilter(.blur(radius: dimBlur))
            }
            for i in visible where i != current && i != previous {
                draw(lines[i], tinted: Theme.future, in: layer)
            }
        }

        // The two lines mid-fade keep their own layers, since their blur and opacity differ.
        for i in visible where i == current || i == previous {
            let lit = i == current ? focus : 1 - focus
            if lit < 1 {
                ctx.drawLayer { layer in
                    layer.opacity = (1 - lit) * dimOpacity
                    if tuning.blurs {
                        layer.addFilter(.blur(radius: dimBlur * (1 - lit)))
                    }
                    draw(lines[i], tinted: Theme.future, in: layer)
                }
            }
            if lit > 0 {
                var bright = ctx
                bright.opacity = lit
                drawWords(of: lines[i], wordStart: wordStart, in: bright)
            }
        }

        // The current word skips its line's fade, so a short word at the start of a line shows at once.
        if focus < 1 {
            for run in lines[current] {
                if let word = run[WordTime.self], word.range.lowerBound == wordStart {
                    self.current(run, since: word, in: ctx)
                }
            }
        }
    }

    private func drawWords(of line: Text.Layout.Line, wordStart: TimeInterval?, in ctx: GraphicsContext) {
        // slide: words
        for run in line {
            guard let word = run[WordTime.self]
            else { continue }
            if word.range.lowerBound == wordStart {
                current(run, since: word, in: ctx)
            } else if word.range.lowerBound > time {
                upcoming(run, in: ctx)
            } else {
                past(run, in: ctx)
            }
        }
        // slide: end
    }

    private func current(_ run: Text.Layout.Run, since word: WordTime, in ctx: GraphicsContext) {
        // slide: current
        switch style {
        case .deepPill:
            pill(behind: run, since: word, in: ctx)
            draw(run, tinted: Theme.onDeep, in: ctx)
        case .spotlight:
            draw(run, tinted: Theme.ink, in: ctx)
        }
        // slide: end
    }

    private func pill(behind run: Text.Layout.Run, since word: WordTime, in ctx: GraphicsContext) {
        let pill = run.typographicBounds.rect.insetBy(dx: -Theme.Layout.transcriptPillPadding, dy: 0)
        let isShort = word.range.upperBound - word.range.lowerBound < shortWord
        let fade = isShort ? 1 : UnitCurve.easeOut.value(at: clamp((time - word.range.lowerBound) / wordFade))
        ctx.fill(Path(roundedRect: pill, cornerRadius: Theme.Layout.transcriptPillCornerRadius), with: .color(Theme.deep.opacity(fade)))
    }

    func isVisible(_ line: CGRect, offset: CGFloat) -> Bool {
        let rect = line.offsetBy(dx: 0, dy: offset)
        return rect.maxY > -Theme.Layout.transcriptBleed && rect.minY < height + Theme.Layout.transcriptBleed
    }

    private func upcoming(_ run: Text.Layout.Run, in ctx: GraphicsContext) {
        draw(run, tinted: Theme.future, in: ctx)
    }

    private func past(_ run: Text.Layout.Run, in ctx: GraphicsContext) {
        var copy = ctx
        if style == .spotlight {
            copy.opacity *= spotlightPastOpacity
        }
        draw(run, tinted: Theme.ink, in: copy)
    }

    /// The text is white, so multiplying by a role color draws the glyphs in exactly that color.
    private func draw(_ line: Text.Layout.Line, tinted color: Color, in ctx: GraphicsContext) {
        guard !tuning.drawsGlyphs else {
            for run in line {
                draw(run, tinted: color, in: ctx)
            }
            return
        }
        var copy = ctx
        copy.addFilter(.colorMultiply(color))
        copy.draw(line, options: .disablesSubpixelQuantization)
    }

    private func draw(_ run: Text.Layout.Run, tinted color: Color, in ctx: GraphicsContext) {
        guard !tuning.drawsGlyphs else {
            for glyph in run {
                var copy = ctx
                copy.addFilter(.colorMultiply(color))
                copy.draw(glyph, options: .disablesSubpixelQuantization)
            }
            return
        }
        var copy = ctx
        copy.addFilter(.colorMultiply(color))
        copy.draw(run, options: .disablesSubpixelQuantization)
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}

struct TranscriptViewport: View {
    let text: AttributedString
    let time: TimeInterval
    var style = TranscriptRenderer.HighlightStyle.deepPill
    var tuning = TranscriptRenderer.Tuning()
    let height: CGFloat
    let textStyle: SlideText

    @Environment(\.slideRenderMode) private var renderMode

    var body: some View {
        Text(text)
            .attributedTextFormattingDefinition(SlideTextFormatting())
            .textRenderer(Counted(
                TranscriptRenderer(time: time, style: style, tuning: tuning, height: height),
                counter: renderMode == .live ? .shared : nil
            ))
            .slideText(textStyle.color(.white))
            .fixedSize(horizontal: false, vertical: true)
            // Vertically fixed text lays out wider by the renderer's horizontal `displayPadding`, so reserve it on the trailing side.
            .padding(.leading, Theme.Layout.transcriptBleed)
            .padding(.trailing, 3 * Theme.Layout.transcriptBleed)
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .topLeading)
            .clipped()
            .mask {
                let fade = min(Theme.Layout.transcriptEdgeFade / height, 0.5)
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: fade),
                        .init(color: .black, location: 1 - fade),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .padding(.horizontal, -Theme.Layout.transcriptBleed)
    }
}

extension TranscriptRenderer.HighlightStyle {
    var toggled: Self { self == .deepPill ? .spotlight : .deepPill }
}

extension Snippets {
    static var words: String { region("words") }
    static var styleSwap: String { region("highlightStyle") + "\n\n" + region("current") }
}
