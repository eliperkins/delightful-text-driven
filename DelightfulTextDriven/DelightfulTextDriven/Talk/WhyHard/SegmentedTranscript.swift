import SwiftUI

struct SegmentedTranscript: View {
    var transcript = Clip.transcript
    var audio = Clip.audio

    var body: some View {
        Slide(label: "SwiftUI.Text") {
            if let transcript, let audio {
                let spoken = transcript.spoken
                ClipPlayer(transcript: transcript, audio: audio) { time in
                    segmented(spoken.segments(at: time))
                }
                .padding(.top, Theme.Layout.contentTop)
                .padding(.bottom, Theme.Layout.splitBottom)
            } else {
                Clip.missing
            }
        }
    }

    private func segmented(_ segments: (done: String, now: String, rest: String)) -> some View {
        VStack(alignment: .leading, spacing: Theme.Layout.livePaneSpacing) {
            let done = Text(segments.done)
                .foregroundStyle(Theme.ink)
            let now = Text(segments.now)
                .foregroundStyle(Theme.accentText)
            let rest = Text(segments.rest)
                .foregroundStyle(Theme.future)
            // slide: segmented
            Text("\(done)\(now)\(rest)")
            // slide: end
                .slideText(.subtitleCompact)
            CodeBlock(Snippets.segmented)
                .padding(Theme.Layout.codePanelPadding)
                .background(Theme.codeBackground, in: .rect(cornerRadius: Theme.Layout.panelCornerRadius))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension Snippets {
    static var segmented: String { region("segmented") }
}

extension [Transcript.Word] {
    func segments(at time: TimeInterval) -> (done: String, now: String, rest: String) {
        guard let current = lastIndex(where: { $0.type == .word && $0.start <= time }) else {
            return ("", "", map(\.text).joined())
        }
        return (
            self[..<current].map(\.text).joined(),
            self[current].text,
            self[(current + 1)...].map(\.text).joined()
        )
    }
}
