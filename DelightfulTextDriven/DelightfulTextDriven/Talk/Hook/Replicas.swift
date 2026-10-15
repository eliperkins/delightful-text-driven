import SwiftUI

struct SpoilerReplica: View {
    var body: some View {
        Replica {
            SpoilerEffect(style: .statement)
        }
    }
}

struct SpoilerEffect: View {
    let style: SlideText

    var body: some View {
        Loop { phase in
            let spoiler = Text("the butler").customAttribute(Spoiler())
            Text("It was \(spoiler) all along.")
                .textRenderer(SpoilerRenderer(revealed: ramp(phase, from: 0.35, to: 0.5) - ramp(phase, from: 0.85, to: 1)))
                .slideText(style)
        }
    }
}

nonisolated struct Spoiler: TextAttribute {}

struct SpoilerRenderer: TextRenderer {
    var revealed: Double

    private let hiddenBlur: CGFloat = 28

    // slide: spoilerPadding
    var displayPadding: EdgeInsets {
        let room = hiddenBlur * 2
        return EdgeInsets(
            top: room,
            leading: room,
            bottom: room,
            trailing: room
        )
    }
    // slide: end

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        // slide: spoilerBlur
        let radius = hiddenBlur * (1 - revealed)
        for line in layout {
            for run in line {
                var copy = ctx
                if run[Spoiler.self] != nil {
                    copy.addFilter(.blur(
                        radius: radius))
                }
                copy.draw(run)
            }
        }
        // slide: end
    }
}

struct HighlighterReplica: View {
    var body: some View {
        Replica {
            HighlighterEffect(style: .statementCompact)
        }
    }
}

struct HighlighterEffect: View {
    let style: SlideText

    var body: some View {
        Loop { phase in
            let marked = Text("keeps its highlight from one line to the next").customAttribute(Marked())
            Text("Text that wraps \(marked) as the layout changes.")
                .textRenderer(MarkerSweep(progress: ramp(phase, from: 0.1, to: 0.55) - ramp(phase, from: 0.85, to: 1)))
                .slideText(style)
        }
    }
}

nonisolated struct Marked: TextAttribute {}

struct MarkerSweep: TextRenderer {
    var progress: Double

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let marked = layout.flatMap { $0 }.filter { $0[Marked.self] != nil }
        var remaining = progress * marked.reduce(0) { $0 + $1.typographicBounds.rect.width }
        for run in marked {
            let rect = run.typographicBounds.rect
            let width = min(rect.width, max(remaining, 0))
            remaining -= rect.width
            guard width > 0 else { continue }
            let x = run.layoutDirection == .rightToLeft ? rect.maxX - width : rect.minX
            ctx.fill(
                RoundedRectangle(cornerRadius: Theme.Layout.panelCornerRadius).path(in: CGRect(x: x, y: rect.minY, width: width, height: rect.height)),
                with: .color(Theme.deep)
            )
        }
        for line in layout {
            ctx.draw(line)
        }
    }
}

struct FocusReplica: View {
    var body: some View {
        Replica {
            FocusEffect(style: .statementCompact)
        }
    }
}

struct FocusEffect: View {
    let style: SlideText

    var body: some View {
        Loop(period: 8) { phase in
            Text("Only the line you're reading stays sharp. Everything else steps back, so your eye knows where to go next.")
                .textRenderer(Focus(phase: phase))
                .slideText(style)
        }
    }
}

struct Focus: TextRenderer {
    var phase: Double

    private let blur: CGFloat = 6
    private let fade = 0.5

    var displayPadding: EdgeInsets {
        EdgeInsets(top: blur * 2, leading: blur * 2, bottom: blur * 2, trailing: blur * 2)
    }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        // slide: focus
        let current = currentLine(in: layout)
        for (i, line) in layout.enumerated() {
            let distance = abs(Double(i) - current)
            let dim = min(distance, 1)
            let radius = dim * blur
            var copy = ctx
            copy.opacity = 1 - dim * fade
            copy.addFilter(.blur(radius: radius))
            copy.draw(line)
        }
        // slide: end
    }

    private func currentLine(in layout: Text.Layout) -> Double {
        let position = phase * Double(layout.count)
        let step = ramp(position.truncatingRemainder(dividingBy: 1), from: 0.7, to: 1)
        return min(position.rounded(.down) + step, Double(layout.count - 1))
    }
}

struct LyricReplica: View {
    var body: some View {
        Replica {
            LyricEffect(style: .statement)
        }
    }
}

struct LyricEffect: View {
    let style: SlideText

    static let lyric = WordTime.spoken("Every word fills in as it's sung")
    private static let pause: TimeInterval = 1.5
    static let duration = lyric.runs[WordTime.self].compactMap { $0.0?.range.upperBound }.max() ?? 0

    var body: some View {
        Loop(period: Self.duration + Self.pause) { phase in
            Text(Self.lyric)
                .attributedTextFormattingDefinition(SlideTextFormatting())
                .textRenderer(LyricFill(time: phase * (Self.duration + Self.pause)))
                .slideText(style)
        }
    }
}

struct LyricFill: TextRenderer {
    var time: TimeInterval

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        var dim = ctx
        dim.opacity = 0.5
        // slide: lyric
        for run in layout.flatMap({ $0 }) {
            dim.draw(run)
            guard let progress = run[WordTime.self]?
                .progress(at: time) else { continue }
            let r = run.typographicBounds.rect
            let isRTL = run.layoutDirection
                == .rightToLeft
            let sung = r.divided(
                atDistance: r.width * progress,
                from: isRTL ? .maxXEdge : .minXEdge)
            var lit = ctx
            lit.clip(to: Path(sung.slice))
            lit.draw(run)
        }
        // slide: end
    }
}
