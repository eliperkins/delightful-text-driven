import SwiftUI

struct WordTimes: View {
    @Environment(\.slideStep) private var step
    @State private var time = WordTime.wordDuration * 3.5

    private static let sentence = WordTime.spoken(Foundations.sample)
    private static let duration = sentence.runs[WordTime.self].compactMap { $0.0?.range.upperBound }.max() ?? 0

    var body: some View {
        Split(label: "Custom attributes", caption: step == 0 ? "WordTime(range:)" : "Spoken(time: \(time.formatted(.number.precision(.fractionLength(1)))))") {
            CodeBlock(step == 0 ? Snippets.wordTime : Snippets.spoken)
        } live: {
            Text(Self.sentence)
                .attributedTextFormattingDefinition(SlideTextFormatting())
                .textRenderer(Spoken(time: step == 0 ? Self.duration : time))
                .slideText(SlideText.displayDemo.color(Theme.accentText))
            if step > 0 {
                Slider(value: $time, in: 0...Self.duration)
                    .controlSize(.large)
                    .tint(Theme.accent)
            }
        }
    }
}

// slide: wordTime
nonisolated struct WordTime:
    TextAttribute {
    let range: Range<TimeInterval>
}
// slide: end

nonisolated extension WordTime: AttributedStringKey {
    typealias Value = WordTime
    static let name = "DelightfulTextDriven.wordTime"
    static let wordDuration: TimeInterval = 0.4

    static func spoken(_ sentence: String) -> AttributedString {
        let words = sentence.split(separator: " ")
        // slide: spokenString
        var text = AttributedString()
        for (i, word) in words.enumerated() {
            let start = Double(i) * wordDuration
            var run = AttributedString(word + " ")
            run[WordTime.self] = WordTime(
                range: start..<start + wordDuration)
            text += run
        }
        // slide: end
        return text
    }

    func progress(at time: TimeInterval) -> Double {
        guard !range.isEmpty else { return time >= range.lowerBound ? 1 : 0 }
        let p = (time - range.lowerBound) / (range.upperBound - range.lowerBound)
        return min(max(p, 0), 1)
    }
}

struct Spoken: TextRenderer {
    var time: TimeInterval

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        // slide: spoken
        for line in layout {
            for run in line {
                let word = run[WordTime.self]
                let p = word?.progress(at: time) ?? 1
                var copy = ctx
                copy.opacity = 0.5 + 0.5 * p
                copy.draw(run)
            }
        }
        // slide: end
    }
}

extension Snippets {
    static var wordTime: String { region("wordTime") + "\n\n" + region("spokenString") }
    static var spoken: String { region("spoken") }
}
