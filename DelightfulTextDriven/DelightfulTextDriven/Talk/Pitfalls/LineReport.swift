import SwiftUI

struct LineReport: View {
    enum Handoff {
        case state
        case reference
    }

    var handoff: Handoff

    @Environment(\.slideStep) private var step
    @State private var lineY: CGFloat = 0
    @State private var tracker = LineTracker()

    private let sentence = "One line lights up each second, and the marker follows it down the text."

    var body: some View {
        Split(label: label, caption: caption) {
            CodeBlock(code)
        } live: {
            Group {
                switch handoff {
                case .state: stateDemo
                case .reference: referenceDemo
                }
            }
            .slideText(SlideText.statementTile.color(Theme.accentText))
            .padding(.leading, Theme.Layout.lineMarkerGutter)
            .onAppear { StateWrites.shared.count = 0 }
            TimelineView(.animation) { _ in
                VStack(spacing: Theme.Layout.frameTileSpacing) {
                    Label {
                        Text("Modifying state during view update")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, handoff == .state ? Theme.runtimeIssue : Theme.muted)
                    }
                    .slideText(SlideText.meta.color(handoff == .state ? Theme.ink : Theme.muted))
                    Text(warnings)
                        .slideText(.caption)
                }
            }
        }
    }

    private var stateDemo: some View {
        // slide: stateMarker
        TimelineView(.animation) { context in
            let tick = Int(context.date
                .timeIntervalSinceReferenceDate)
            Text(sentence)
                .textRenderer(StateLines(
                    tick: tick, lineY: $lineY))
                .overlay(alignment: .topLeading) {
                    LineMarker(y: lineY)
                }
        }
        // slide: end
    }

    private var referenceDemo: some View {
        // slide: referenceMarker
        TimelineView(.animation) { context in
            let tick = Int(context.date
                .timeIntervalSinceReferenceDate)
            Text(sentence)
                .textRenderer(TrackedLines(
                    tick: tick, tracker: tracker))
                .overlay(alignment: .topLeading) {
                    LineMarker(y: tracker.lineY)
                }
        }
        // slide: end
    }

    private var warnings: String {
        "×\(handoff == .state ? StateWrites.shared.count : 0)"
    }

    private var label: String {
        switch handoff {
        case .state: "Report the line from draw"
        case .reference: "Hand it over in a reference"
        }
    }

    private var caption: String {
        switch handoff {
        case .state: "lineY: Binding<CGFloat>"
        case .reference: "tracker: LineTracker"
        }
    }

    private var code: String {
        switch (handoff, step) {
        case (.state, 0): Snippets.stateLines
        case (.state, _): Snippets.stateMarker
        case (.reference, 0): Snippets.trackedLines
        default: Snippets.referenceMarker
        }
    }
}

/// Not observed, so counting doesn't redraw.
final class StateWrites {
    static let shared = StateWrites()
    var count = 0
}

/// Not observed, so writing it from `draw` doesn't redraw.
final class LineTracker {
    var lineY: CGFloat = 0
}

struct StateLines: TextRenderer {
    var tick: Int
    var lineY: Binding<CGFloat>

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        StateWrites.shared.count += 1
        // slide: stateLines
        let current = tick % layout.count
        for (i, line) in layout.enumerated() {
            var copy = ctx
            copy.opacity = i == current ? 1 : 0.5
            copy.draw(line)
        }
        lineY.wrappedValue = layout[current]
            .typographicBounds.rect.midY
        // slide: end
    }
}

struct TrackedLines: TextRenderer {
    var tick: Int
    var tracker: LineTracker

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        // slide: trackedLines
        let current = tick % layout.count
        for (i, line) in layout.enumerated() {
            var copy = ctx
            copy.opacity = i == current ? 1 : 0.5
            copy.draw(line)
        }
        tracker.lineY = layout[current]
            .typographicBounds.rect.midY
        // slide: end
    }
}

private struct LineMarker: View {
    var y: CGFloat

    var body: some View {
        Image(systemName: "arrowtriangle.right.fill")
            .font(.system(size: Theme.Layout.lineMarkerSize))
            .foregroundStyle(Theme.accent)
            .frame(width: Theme.Layout.lineMarkerSize, height: Theme.Layout.lineMarkerSize)
            .offset(x: -Theme.Layout.lineMarkerGutter, y: y - Theme.Layout.lineMarkerSize / 2)
    }
}

extension Snippets {
    static var stateLines: String { region("stateLines") }
    static var stateMarker: String { region("stateMarker") }
    static var trackedLines: String { region("trackedLines") }
    static var referenceMarker: String { region("referenceMarker") }
}

#Preview("State") {
    SlidePreview(part: .pitfalls) {
        LineReport(handoff: .state)
    }
}

#Preview("Reference") {
    SlidePreview(part: .pitfalls) {
        LineReport(handoff: .reference)
    }
}
