import SwiftUI

struct StyleSwap: View {
    /// Mid-"join", in "for you to join us."
    static let startTime = 11.77

    var transcript = Clip.transcript
    var text = Clip.text
    @State private var style = TranscriptRenderer.HighlightStyle.deepPill
    @State private var time = 0.0

    var body: some View {
        Split(label: "Declarative customization", caption: "style: .\(style)") {
            CodeBlock(Snippets.styleSwap)
        } live: {
            if let transcript, let text {
                TranscriptViewport(text: text, time: time, style: style, height: Theme.Layout.transcriptDemoViewport, textStyle: .displayDemo)
                HStack(spacing: Theme.Layout.transcriptChromeSpacing) {
                    Slider(value: $time, in: 0...transcript.duration)
                        .controlSize(.large)
                        .tint(Theme.accent)
                        .onAppear {
                            time = Self.startTime
                        }
                    Button("Swap style") {
                        style = style.toggled
                    }
                    .buttonStyle(.demo)
                    .fixedSize()
                }
            } else {
                Clip.missing
            }
        }
    }
}
