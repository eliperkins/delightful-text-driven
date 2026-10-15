import SwiftUI

struct Replica<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        Slide {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

/// `content` gets the loop's phase, from 0 to 1.
struct Loop<Content: View>: View {
    var period: TimeInterval = 6
    @ViewBuilder var content: (Double) -> Content

    @Environment(\.slideRenderMode) private var renderMode
    @State private var start = Date.now

    var body: some View {
        TimelineView(.animation(paused: renderMode != .live)) { context in
            content(phase(at: context.date))
        }
    }

    private func phase(at date: Date) -> Double {
        guard renderMode == .live else { return Self.thumbnailPhase }
        return date.timeIntervalSince(start).truncatingRemainder(dividingBy: period) / period
    }

    private static var thumbnailPhase: Double { 0.6 }
}

func ramp(_ phase: Double, from start: Double, to end: Double) -> Double {
    UnitCurve.easeInOut.value(at: min(max((phase - start) / (end - start), 0), 1))
}
