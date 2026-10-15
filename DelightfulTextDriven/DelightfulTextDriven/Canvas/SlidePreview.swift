import SwiftUI

/// Renders a slide at full canvas size for `#Preview`, at a given step and part.
struct SlidePreview<Content: View>: View {
    var step = 0
    var part = TalkPart.hook
    @ViewBuilder var content: Content

    var body: some View {
        SlideCanvas {
            content
                .environment(\.slideStep, step)
                .environment(\.talkPart, part)
        }
        .frame(width: Theme.Layout.canvas.width, height: Theme.Layout.canvas.height)
    }
}
