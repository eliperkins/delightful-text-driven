import SwiftUI

struct TimeTravelCode: View {
    @Environment(\.slideStep) private var step
    var transcript = Clip.transcript
    var text = Clip.text
    @State private var time = 0.0

    var body: some View {
        Split(label: "Audio as an animation value", caption: "TranscriptRenderer(time: \(Clip.timecode(time)))") {
            CodeBlock(code)
        } live: {
            if let transcript, let text {
                TranscriptViewport(text: text, time: time, height: Theme.Layout.transcriptDemoViewport, textStyle: .displayDemo)
                Slider(value: $time, in: 0...transcript.duration)
                    .controlSize(.large)
                    .tint(Theme.accent)
                    .onAppear {
                        time = transcript.duration * Clip.thumbnailFraction
                    }
            }
        }
    }

    private var code: String {
        switch step {
        case 0: Snippets.scrubTime
        case 1: Snippets.clock
        default: Snippets.words
        }
    }
}

extension Snippets {
    static let scrubTime = """
        Text(transcript)
          .textRenderer(TranscriptRenderer(
            time: time, height: \(Int(Theme.Layout.transcriptDemoViewport))))
        Slider(value: $time,
          in: 0...duration)
        """
}
