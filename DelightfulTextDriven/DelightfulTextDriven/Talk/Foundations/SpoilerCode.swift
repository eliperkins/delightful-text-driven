import SwiftUI

struct SpoilerCode: View {
    @Environment(\.slideStep) private var step
    @State private var revealed = 0.0

    var body: some View {
        Split(label: "Blur a phrase", caption: "SpoilerRenderer(revealed: \(revealed.formatted(.number.precision(.fractionLength(0...2)))))") {
            if step == 0 {
                CodeBlock(Snippets.spoilerBlur, focus: 6...7)
            } else {
                CodeBlock(Snippets.spoilerPadding)
            }
        } live: {
            let butler = Text("the butler").customAttribute(Spoiler())
            Text("It was \(butler) all along.")
                .textRenderer(SpoilerRenderer(revealed: revealed))
                .slideText(SlideText.displayDemo.color(Theme.accentText))
            Slider(value: $revealed, in: 0...1)
                .controlSize(.large)
                .tint(Theme.accent)
        }
    }
}

extension Snippets {
    static var spoilerBlur: String { region("spoilerBlur", file: Self.replicasFile) }
    static var spoilerPadding: String { region("spoilerPadding", file: Self.replicasFile) }

    static var replicasFile: String {
        URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "Hook/Replicas.swift")
            .path(percentEncoded: false)
    }
}

#Preview {
    SlidePreview(part: .drawing) {
        SpoilerCode()
    }
}
