import SwiftUI

/// The deck's text styles, applied with `.slideText(_:)`. Sizes are canvas points.
///
/// System fonts only: SF Pro (expanded for display), New York for subtitles, SF Mono for code.
/// They cover every script the "Every language, for free" section shows.
struct SlideText {
    var size: CGFloat
    var weight: Font.Weight
    var width: Font.Width = .standard
    var design: Font.Design = .default
    var italic = false
    /// Letter spacing as a fraction of the size, e.g. -0.025 for −2.5%.
    var tracking: CGFloat = 0
    /// Line height as a multiple of the size, or the font's natural line height when `nil`.
    var lineHeight: CGFloat?
    var color: Color

    /// Title card titles.
    static let display = SlideText(size: 128, weight: .heavy, width: .expanded, tracking: -0.025, color: Theme.ink)
    static let displayMono = SlideText(size: 112, weight: .bold, design: .monospaced, color: Theme.ink)
    static let wave = SlideText(size: 320, weight: .regular, color: Theme.ink)
    /// A single emoji filling the slide. Apple Color Emoji's largest bitmap is 160 px, so it's soft at this size.
    static let hero = SlideText(size: 480, weight: .regular, color: Theme.ink)
    /// Section card titles.
    static let displaySection = SlideText(size: 124, weight: .heavy, width: .expanded, tracking: -0.025, color: Theme.ink)
    /// Live demo text.
    static let displayDemo = SlideText(size: 72, weight: .heavy, width: .expanded, tracking: -0.025, color: Theme.ink)
    /// Two demos stacked in one live pane.
    static let displayDemoCompact = SlideText(size: 64, weight: .heavy, width: .expanded, tracking: -0.025, color: Theme.ink)
    /// Rendered at 1× and shown enlarged, so its pixels are visible.
    static let pixelZoomSample = SlideText(size: 16, weight: .heavy, width: .expanded, tracking: -0.025, color: Theme.ink)
    static let statement = SlideText(size: 132, weight: .bold, tracking: -0.02, color: Theme.ink)
    static let statementCompact = SlideText(size: 104, weight: .bold, tracking: -0.02, color: Theme.ink)
    /// A warning line above a statement.
    static let kicker = SlideText(size: 104, weight: .bold, italic: true, tracking: -0.02, color: Theme.ink)
    static let statementTile = SlideText(size: 64, weight: .bold, tracking: -0.02, color: Theme.ink)
    /// The largest size at which every requirement line stays on one line.
    static let requirement = SlideText(size: 80, weight: .bold, tracking: -0.02, color: Theme.ink)
    /// Medium, so the diagram's bold word is a separate run.
    static let runsDiagram = SlideText(size: 104, weight: .medium, tracking: -0.02, color: Theme.ink)
    static let languageSample = SlideText(size: 160, weight: .medium, color: Theme.ink)
    static let subtitle = SlideText(size: 62, weight: .medium, design: .serif, color: Theme.ink2)
    static let subtitleCompact = SlideText(size: 54, weight: .medium, design: .serif, color: Theme.ink2)
    /// App Store award badges, between laurels.
    static let award = SlideText(size: 56, weight: .semibold, lineHeight: 1.05, color: Theme.ink2)
    /// The header's accent label, on the leading side.
    static let label = SlideText(size: 40, weight: .semibold, width: .expanded, color: Theme.accentText)
    /// The header's meta text on the trailing side, and legends.
    static let meta = SlideText(size: 38, weight: .medium, color: Theme.muted)
    /// The "Live" tag on a split's live pane.
    static let liveTag = SlideText(size: 30, weight: .medium, color: Theme.muted)
    static let code = SlideText(size: 34, weight: .regular, design: .monospaced, lineHeight: 1.45, color: Theme.ink)
    /// Modifier captions and timecodes.
    static let caption = SlideText(size: 30, weight: .regular, design: .monospaced, color: Theme.muted)
    /// The section card's giant part number.
    static let numeral = SlideText(size: 1000, weight: .heavy, color: Theme.shiftAccent)

    var font: Font {
        let font = Font.system(size: size, weight: weight, design: design).width(width)
        return italic ? font.italic() : font
    }

    func color(_ color: Color) -> SlideText {
        var copy = self
        copy.color = color
        return copy
    }

    static func emphasized(_ markdown: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        var text = (try? AttributedString(markdown: markdown, options: options)) ?? AttributedString(markdown)
        for (intent, range) in text.runs[\.inlinePresentationIntent] {
            if intent == .code {
                text[range].foregroundColor = Theme.ink2
            } else if intent != nil {
                text[range].inlinePresentationIntent = nil
                text[range].foregroundColor = Theme.accentText
                text[range][Emphasis.self] = Emphasis()
            }
        }
        return text
    }
}

/// Marks `*emphasis*` so a renderer can find it, because runs don't expose color.
nonisolated struct Emphasis: TextAttribute, AttributedStringKey {
    typealias Value = Emphasis
    static let name = "DelightfulTextDriven.emphasis"
}

extension AttributeScopes {
    struct SlideAttributes: AttributeScope {
        let emphasis: Emphasis
        let wordTime: WordTime
        let swiftUI: SwiftUIAttributes
        let foundation: FoundationAttributes
    }
}

/// `Text(AttributedString)` drops custom attributes like `Emphasis` unless the view declares their scope with this.
struct SlideTextFormatting: AttributedTextFormattingDefinition {
    var body: some AttributedTextFormattingDefinition<AttributeScopes.SlideAttributes> {
        AttributedTextFormatting.EmptyDefinition()
    }
}

extension View {
    func slideText(_ style: SlideText) -> some View {
        font(style.font)
            .tracking(style.size * style.tracking)
            .lineHeight(style.lineHeight.map { .multiple(factor: $0) })
            .foregroundStyle(style.color)
    }
}
