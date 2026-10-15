import SwiftUI

struct TuningSlide: View {
    var transcript = Clip.transcript
    var text = Clip.text
    var audio = Clip.audio
    @State private var style = TranscriptRenderer.HighlightStyle.deepPill
    @State private var tuning = TranscriptRenderer.Tuning()

    var body: some View {
        Slide {
            if let transcript, let text, let audio {
                HStack(alignment: .top, spacing: Theme.Layout.splitGap) {
                    TranscriptPlayer(transcript: transcript, text: text, audio: audio, style: style, tuning: tuning, textTrailing: 0)
                    controls
                        .frame(width: Theme.Layout.tuningControlsWidth, alignment: .leading)
                }
                .padding(.top, Theme.Layout.transcriptTop)
                .padding(.bottom, Theme.Layout.splitBottom)
            } else {
                Clip.missing
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.tuningControlsSpacing) {
            control("style", ".\(style)") { style = style.toggled }
            control("blurs", tuning.blurs) { tuning.blurs.toggle() }
            control("culls", tuning.culls) { tuning.culls.toggle() }
            control("drawsGlyphs", tuning.drawsGlyphs) { tuning.drawsGlyphs.toggle() }
        }
    }

    private func control(_ name: String, _ value: Bool, action: @escaping () -> Void) -> some View {
        control(name, String(value), action: action)
    }

    private func control(_ name: String, _ value: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: Theme.Layout.liveTagSpacing) {
            Text(name)
                .slideText(.caption)
            Button(value, action: action)
                .buttonStyle(.demo)
        }
    }
}
