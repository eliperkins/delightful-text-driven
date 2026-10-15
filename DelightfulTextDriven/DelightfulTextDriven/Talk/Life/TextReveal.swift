import SwiftUI

struct TextReveal: Transition {
    nonisolated static var properties: TransitionProperties {
        TransitionProperties(hasMotion: true)
    }

    func body(content: Content, phase: TransitionPhase) -> some View {
        content.transaction {
            if !$0.disablesAnimations {
                $0.animation = .linear(duration: RevealRenderer.duration)
            }
        } body: {
            $0.textRenderer(RevealRenderer(progress: phase.isIdentity ? 1 : 0))
        }
    }
}

extension AnyTransition {
    static func textReveal(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : AnyTransition(TextReveal())
    }
}

struct RevealRenderer: TextRenderer {
    static let duration: TimeInterval = 0.9
    private static let plainFadeDuration: TimeInterval = 0.3

    var progress: Double
    let glyphTime: TimeInterval = 0.4
    let spring = Spring(duration: 0.4, bounce: 0.35)

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    private var elapsed: TimeInterval { progress * Self.duration }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        // slide: reveal
        for line in layout {
            for run in line {
                guard run[Emphasis.self] != nil else {
                    fade(run, at: elapsed, in: ctx)
                    continue
                }
                let gap = stagger(for: run)
                for (i, glyph) in run.enumerated() {
                    var copy = ctx
                    let t = elapsed - Double(i) * gap
                    rise(glyph, at: t, in: &copy)
                }
            }
        }
        // slide: end
    }

    private func fade(_ run: Text.Layout.Run, at elapsed: TimeInterval, in ctx: GraphicsContext) {
        var ctx = ctx
        ctx.opacity = min(elapsed / Self.plainFadeDuration, 1)
        ctx.draw(run)
    }

    private func stagger(for run: Text.Layout.Run) -> TimeInterval {
        (Self.duration - glyphTime) / Double(max(run.count - 1, 1))
    }

    // slide: rise
    func rise(
        _ glyph: Text.Layout.RunSlice,
        at t: TimeInterval,
        in ctx: inout GraphicsContext
    ) {
        let p = min(max(t / glyphTime, 0), 1)
        let y = spring.value(
            target: 40.0, time: max(t, 0))
        ctx.translateBy(x: 0, y: 40 - y)
        ctx.addFilter(.blur(radius: 8 - 8 * p))
        ctx.opacity = p
        ctx.draw(glyph, options:
            .disablesSubpixelQuantization)
    }
    // slide: end
}

extension Snippets {
    static var reveal: String { region("reveal") }
    static var rise: String { region("rise") }
}
