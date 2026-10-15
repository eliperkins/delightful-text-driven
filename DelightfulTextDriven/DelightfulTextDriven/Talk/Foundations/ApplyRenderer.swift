import SwiftUI

struct ApplyRenderer: View {
    var body: some View {
        Split(label: "Apply a renderer", caption: ".textRenderer(_:)") {
            CodeBlock(Snippets.applyRenderer)
        } live: {
            // slide: applyRenderer
            Text("Hello, world")
                .textRenderer(Passthrough())
            // slide: end
                .slideText(SlideText.displayDemo.color(Theme.accentText))
        }
    }
}

extension Snippets {
    static var applyRenderer: String { region("applyRenderer") }
}

#Preview {
    SlidePreview(part: .lines) {
        ApplyRenderer()
    }
}
