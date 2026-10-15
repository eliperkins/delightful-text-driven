import SwiftUI

struct TranscriptSlide: View {
    var transcript = Clip.transcript
    var text = Clip.text
    var audio = Clip.audio

    var body: some View {
        Slide {
            if let transcript, let text, let audio {
                TranscriptPlayer(transcript: transcript, text: text, audio: audio)
                    .padding(.top, Theme.Layout.transcriptTop)
                    .padding(.bottom, Theme.Layout.splitBottom)
            } else {
                Clip.missing
            }
        }
        .overlay(alignment: .top) {
            if audio != nil {
                ClipAttribution()
                    .padding(.horizontal, Theme.Layout.margin)
                    .padding(.top, Theme.Layout.headerTop)
            }
        }
    }
}

/// The slide header, with the podcast's artwork in front.
struct ClipAttribution: View {
    var body: some View {
        HStack(spacing: Theme.Layout.attributionSpacing) {
            if let artwork = Clip.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .frame(width: Theme.Layout.attributionArtwork, height: Theme.Layout.attributionArtwork)
                    .clipShape(.rect(cornerRadius: Theme.Layout.attributionCornerRadius))
            }
            SlideHeader(label: Clip.podcast, meta: Clip.episode)
        }
    }
}

struct TranscriptPlayer: View {
    let transcript: Transcript
    let text: AttributedString
    let audio: URL
    var style = TranscriptRenderer.HighlightStyle.deepPill
    var tuning = TranscriptRenderer.Tuning()
    var textTrailing = Theme.Layout.statementTrailing

    var body: some View {
        ClipPlayer(transcript: transcript, audio: audio) { time in
            TranscriptViewport(text: text, time: time, style: style, tuning: tuning, height: Theme.Layout.transcriptViewport, textStyle: .statementCompact)
                .padding(.trailing, textTrailing)
        }
    }
}

struct ClipPlayer<Content: View>: View {
    let transcript: Transcript
    let audio: URL
    @ViewBuilder var content: (TimeInterval) -> Content

    @Environment(\.slideRenderMode) private var renderMode
    @State private var clock: PlayerClock?

    /// The timecodes and slider only need a few updates a second.
    private static var chromeInterval: TimeInterval { 0.25 }

    private var isPaused: Bool { clock?.isPlaying != true }

    private var time: TimeInterval {
        clock?.time ?? transcript.duration * Clip.thumbnailFraction
    }

    var body: some View {
        // Only the transcript sits inside the per-frame timeline: everything SwiftUI finds in the closure is rebuilt and diffed on every frame.
        VStack(spacing: 0) {
            // slide: clock
            TimelineView(.animation(
                paused: isPaused
            )) { _ in
                content(time)
            }
            // slide: end
            Spacer()
            TimelineView(.animation(minimumInterval: Self.chromeInterval, paused: isPaused)) { _ in
                chrome(at: time)
            }
        }
        .onAppear {
            if renderMode == .live, clock == nil {
                clock = PlayerClock(audio: audio, duration: transcript.duration)
            }
        }
        .onDisappear {
            clock?.pause()
        }
    }

    private func chrome(at time: TimeInterval) -> some View {
        HStack(spacing: Theme.Layout.transcriptChromeSpacing) {
            Button(clock?.isPlaying == true ? "Pause" : "Play") {
                clock?.toggle()
            }
            .buttonStyle(.demo)
            Text(Clip.timecode(time))
                .slideText(.caption)
            Slider(
                value: Binding { time } set: { clock?.scrub(to: $0) },
                in: 0...transcript.duration
            ) { editing in
                if !editing {
                    clock?.endScrub()
                }
            }
            .controlSize(.large)
            .tint(Theme.accent)
            Text("−" + Clip.timecode(transcript.duration - time))
                .slideText(.caption)
        }
    }
}

extension Snippets {
    static var clock: String { clockTime + "\n\n" + region("clock") }
}
