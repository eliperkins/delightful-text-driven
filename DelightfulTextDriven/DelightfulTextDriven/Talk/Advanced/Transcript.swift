import SwiftUI

/// Particle's transcript format: every word, space, and audio event with its time in the clip.
nonisolated struct Transcript: Decodable {
    struct Word: Decodable {
        enum Kind: String, Decodable {
            case word
            case spacing
            case audioEvent = "audio_event"
        }

        let text: String
        let type: Kind
        let start: TimeInterval
        let end: TimeInterval
    }

    let words: [Word]

    static let bridgedGap: TimeInterval = 0.25

    var duration: TimeInterval { words.last?.end ?? 0 }

    var spoken: [Word] {
        var spoken: [Word] = []
        for word in words where word.type != .audioEvent {
            if word.type == .spacing, spoken.last?.type == .spacing {
                continue
            }
            spoken.append(word)
        }
        return spoken
    }

    /// A word stays current through a short gap before the next word, so the highlight doesn't flicker between words but still drops out in a pause.
    var text: AttributedString {
        var nextStart = duration
        var ends: [TimeInterval] = []
        for word in spoken.reversed() {
            ends.append(nextStart - word.end <= Self.bridgedGap ? max(nextStart, word.end) : word.end)
            if word.type == .word {
                nextStart = word.start
            }
        }
        var text = AttributedString()
        for (word, end) in zip(spoken, ends.reversed()) {
            var run = AttributedString(word.text)
            if word.type == .word {
                run[WordTime.self] = WordTime(range: word.start..<end)
            }
            text += run
        }
        return text
    }
}

enum Clip {
    static let audio = Bundle.main.url(forResource: "clip", withExtension: "m4a")
    static let transcript = Bundle.main.url(forResource: "clip", withExtension: "json")
        .flatMap { try? Data(contentsOf: $0) }
        .flatMap { try? JSONDecoder().decode(Transcript.self, from: $0) }
    static let text = transcript?.text
    static let artwork = Bundle.main.url(forResource: "clip-artwork", withExtension: "jpg").flatMap(NSImage.init(contentsOf:))
    static let thumbnailFraction = 0.3

    /// Particle clip `6yZ9e4wQAdIN1xAdDhRiIu`, "Periscope's Acquisition Surprise".
    static let podcast = "Generative Now"
    static let episode = "Sara Beykpour: The Next Wave of AI’s Impact On Journalism"

    /// Matches `Duration.formatted(.time(pattern: .minuteSecond))`, which cost about 5% of a playing frame's CPU.
    static func timecode(_ time: TimeInterval) -> String {
        let seconds = Int((time.isFinite ? max(time, 0) : 0).rounded(.toNearestOrEven))
        let remainder = seconds % 60
        return "\(seconds / 60):\(remainder < 10 ? "0" : "")\(remainder)"
    }

    /// The full instructions where they fit, and a pointer to the script in a live pane.
    static var missing: some View {
        ViewThatFits(in: .vertical) {
            missing {
                Text("Get a Particle API key and a podcast clip ID at docs.particle.pro, then run this from the repository's root. It writes `clip.m4a` and `clip.json` to `Talk/Advanced/Clip/`.")
                    .slideText(.meta)
                Text(verbatim: "PARTICLE_API_KEY=… swift scripts/make-clip.swift <clip ID> [seconds]")
                    .slideText(.code)
            }
            missing {
                Text("Make one with `scripts/make-clip.swift`.")
                    .slideText(.meta)
            }
        }
    }

    private static func missing(@ViewBuilder instructions: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Theme.Layout.missingClipSpacing) {
            Text("This demo needs a podcast clip")
                .slideText(.statementTile)
            instructions()
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
