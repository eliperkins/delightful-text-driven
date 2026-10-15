import Foundation
import SwiftUI
import Testing
@testable import DelightfulTextDriven

/// Three slides with 1, 3, and 2 steps, across two parts.
private func makeDeck() -> Deck {
    Deck {
        Part(.hook) {
            Color.red
            Color.green.steps(3).notes("Three builds")
        }
        Part(.lines) {
            Color.blue.steps(2)
        }
    }
}

/// A throwaway defaults suite so tests never touch the app's saved slide.
private func makeDefaults() -> UserDefaults {
    let name = "PresentationTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return defaults
}

struct DeckBuilderTests {
    @Test func flattensPartsInOrderAndTagsEachSlideWithItsPart() {
        let deck = makeDeck()
        #expect(deck.slides.map(\.part) == [.hook, .hook, .lines])
    }

    @Test func carriesStepsAndNotesFromTheCallSite() {
        let deck = makeDeck()
        #expect(deck.slides.map(\.steps) == [1, 3, 2])
        #expect(deck.slides[1].notes == "Three builds")
        #expect(deck.slides[0].notes.isEmpty)
    }

    @Test func carriesActionsToTheirStepInOrder() {
        let deck = Deck { Part(.hook) { Color.red.steps(2).actions(.press("Play"), .drag("the slider"), at: 1) } }
        #expect(deck.slides[0].actions(at: 0).isEmpty)
        #expect(deck.slides[0].actions(at: 1) == [.press("Play"), .drag("the slider")])
    }

    @Test func everyTalkActionIsOnARealStep() {
        for (index, slide) in Deck.talk.slides.enumerated() {
            #expect(slide.actionsByStep.keys.allSatisfy { $0 < slide.steps }, "Slide \(index + 1)")
        }
    }

    @Test func clampsStepsToAtLeastOne() {
        let deck = Deck { Part(.hook) { Color.red.steps(0) } }
        #expect(deck.slides[0].steps == 1)
    }

    @Test func supportsConditionalSlides() {
        let includeExtra = false
        let deck = Deck {
            Part(.hook) {
                Color.red
                if includeExtra {
                    Color.green
                }
            }
        }
        #expect(deck.slides.count == 1)
    }
}

struct PresentationNavigationTests {
    typealias Position = Presentation.Position

    @Test func startsAtTheFirstSlideWithNothingSaved() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        #expect(presentation.position == Position(slide: 0, step: 0))
    }

    @Test func forwardConsumesStepsBeforeAdvancing() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        var visited: [Position] = []
        for _ in 0..<5 {
            presentation.forward()
            visited.append(presentation.position)
        }
        #expect(visited == [
            Position(slide: 1, step: 0),
            Position(slide: 1, step: 1),
            Position(slide: 1, step: 2),
            Position(slide: 2, step: 0),
            Position(slide: 2, step: 1),
        ])
    }

    @Test func forwardStopsOnTheLastStepOfTheDeck() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        for _ in 0..<20 { presentation.forward() }
        #expect(presentation.position == Position(slide: 2, step: 1))
    }

    @Test func backLandsOnThePreviousSlidesLastStep() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.jump(toSlideNumber: 3)
        presentation.back()
        #expect(presentation.position == Position(slide: 1, step: 2))
    }

    @Test func backStopsAtTheStart() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.back()
        #expect(presentation.position == Position(slide: 0, step: 0))
    }

    @Test func restartClearsPositionBlackoutAndPendingJump() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.jump(toSlideNumber: 3)
        presentation.perform(.toggleBlackout)
        presentation.perform(.digit(2))
        presentation.perform(.restart)
        #expect(presentation.position == Position(slide: 0, step: 0))
        #expect(!presentation.isBlackedOut)
        #expect(presentation.pendingJump.isEmpty)
    }
}

struct PresentationJumpTests {
    @Test func digitsThenReturnJumpToThatSlide() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.perform(.digit(2))
        #expect(presentation.pendingJump == "2")
        presentation.perform(.commitJump)
        #expect(presentation.position == .init(slide: 1, step: 0))
        #expect(presentation.pendingJump.isEmpty)
    }

    @Test(arguments: [(0, 0), (1, 0), (3, 2), (99, 2)])
    func jumpsClampToTheDeck(number: Int, expectedSlide: Int) {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.jump(toSlideNumber: number)
        #expect(presentation.position == .init(slide: expectedSlide, step: 0))
    }

    @Test func returnWithoutDigitsAdvances() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.perform(.commitJump)
        #expect(presentation.position == .init(slide: 1, step: 0))
    }

    @Test func hudTogglesWithItsCommand() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.perform(.toggleHUD)
        #expect(presentation.showsHUD)
        presentation.perform(.toggleHUD)
        #expect(!presentation.showsHUD)
    }

    @Test func cancelClearsPendingJumpAndBlackout() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.perform(.digit(3))
        presentation.perform(.toggleBlackout)
        presentation.perform(.cancel)
        #expect(presentation.pendingJump.isEmpty)
        #expect(!presentation.isBlackedOut)
    }
}

struct PresentationPersistenceTests {
    @Test func resumesOnTheSavedSlide() {
        let defaults = makeDefaults()
        let first = Presentation(deck: makeDeck(), defaults: defaults)
        first.jump(toSlideNumber: 3)
        #expect(defaults.integer(forKey: Presentation.slideKey) == 3)

        let relaunched = Presentation(deck: makeDeck(), defaults: defaults)
        #expect(relaunched.position == .init(slide: 2, step: 0))
    }

    @Test func ignoresASavedSlideOutsideTheDeck() {
        let defaults = makeDefaults()
        defaults.set(42, forKey: Presentation.slideKey)
        let presentation = Presentation(deck: makeDeck(), defaults: defaults)
        #expect(presentation.position == .init(slide: 0, step: 0))
    }
}

struct PresentationNextPositionTests {
    typealias Position = Presentation.Position

    @Test func isTheNextStepWhileTheSlideHasOne() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.jump(toSlideNumber: 2)
        #expect(presentation.nextPosition == Position(slide: 1, step: 1))
    }

    @Test func isTheNextSlideAfterTheLastStep() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        #expect(presentation.nextPosition == Position(slide: 1, step: 0))
    }

    @Test func isNilOnTheDecksLastStep() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        for _ in 0..<20 { presentation.forward() }
        #expect(presentation.nextPosition == nil)
    }
}

struct PresentationTimerTests {
    @Test func startsOnTheFirstAdvance() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        #expect(presentation.startedAt == nil)
        #expect(presentation.elapsed(at: .now) == nil)
        presentation.forward()
        #expect(presentation.startedAt != nil)
    }

    @Test func doesNotStartOnJumpOrBack() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.jump(toSlideNumber: 3)
        presentation.back()
        #expect(presentation.startedAt == nil)
        #expect(presentation.partStarts.isEmpty)
    }

    @Test func recordsEachPartTheFirstTimeTheTimerReachesIt() throws {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.forward()
        #expect(presentation.actualStart(of: .hook) == .zero)
        #expect(presentation.actualStart(of: .lines) == nil)

        for _ in 0..<3 { presentation.forward() }
        let linesStart = try #require(presentation.partStarts[.lines])

        presentation.back()
        presentation.forward()
        #expect(presentation.partStarts[.lines] == linesStart)
    }

    @Test func restartResetsTheTimerAndPartStarts() {
        let presentation = Presentation(deck: makeDeck(), defaults: makeDefaults())
        presentation.forward()
        presentation.restart()
        #expect(presentation.startedAt == nil)
        #expect(presentation.partStarts.isEmpty)
    }

    @Test func resumesTheSavedTimerAfterARelaunch() {
        let defaults = makeDefaults()
        let first = Presentation(deck: makeDeck(), defaults: defaults)
        first.forward()

        let relaunched = Presentation(deck: makeDeck(), defaults: defaults)
        #expect(relaunched.startedAt == first.startedAt)
    }
}

struct TalkPartTests {
    @Test func plannedStartsAddUpTheEarlierBudgets() {
        #expect(TalkPart.hook.plannedStart == .zero)
        #expect(TalkPart.lines.plannedStart == .seconds(7 * 60))
        let minutesBeforeClose = 7 + 9 + 6 + 14 + 5
        #expect(TalkPart.close.plannedStart == .seconds(minutesBeforeClose * 60))
    }
}

struct StageScreenTests {
    @Test func putsTheAudienceOnTheExternalScreenAndThePresenterOnTheLaptop() {
        let screens = Stage.screens(laptop: "laptop", others: ["projector", "monitor"], swapped: false)
        #expect(screens.audience == "projector")
        #expect(screens.presenter == "laptop")
    }

    @Test func swapTradesTheScreens() {
        let screens = Stage.screens(laptop: "laptop", others: ["projector"], swapped: true)
        #expect(screens.audience == "laptop")
        #expect(screens.presenter == "projector")
    }

    @Test func givesOnlyTheAudienceAScreenWhenRehearsingOnOne() {
        let screens = Stage.screens(laptop: "laptop", others: [String](), swapped: false)
        #expect(screens.audience == "laptop")
        #expect(screens.presenter == nil)
    }
}

struct SlideTextTests {
    @Test func emphasisBecomesAccentColorWithoutItalics() throws {
        let text = SlideText.emphasized("Anything can be a value. *Even time.*")
        let runs = text.runs.map { (String(text[$0.range].characters), $0.foregroundColor, $0.inlinePresentationIntent) }
        try #require(runs.map(\.0) == ["Anything can be a value. ", "Even time."])
        #expect(runs[0].1 == nil)
        #expect(runs[1].1 == Theme.accentText)
        #expect(runs.allSatisfy { $0.2 == nil })
    }

    @Test func codeSpansKeepTheirStyleInCodeColor() {
        let text = SlideText.emphasized("`draw` runs")
        let code = text.runs.first { $0.inlinePresentationIntent == .code }
        #expect(code?.foregroundColor == Theme.ink2)
    }

    @Test func emphasisRunsCarryTheEmphasisAttribute() {
        let text = SlideText.emphasized("Delightful *Text-Driven* Experiences")
        let marked = text.runs[Emphasis.self].compactMap { $0.0 == nil ? nil : String(text[$0.1].characters) }
        #expect(marked == ["Text-Driven"])
    }
}

struct SnippetTests {
    private let source = """
        struct Demo: View {
            // slide: body
            var body: some View {
                Text("Hi")
            }
            // slide: end
        }
        """

    @Test func regionSlicesBetweenMarkersAndHalvesIndent() {
        #expect(Snippets.region("body", in: source) == "var body: some View {\n  Text(\"Hi\")\n}")
    }

    @Test func missingRegionShowsItsName() {
        #expect(Snippets.region("nope", in: source) == "// Missing slide region \"nope\"")
    }

    @MainActor @Test func slideCodeFitsTheCodePanel() {
        for code in [Snippets.passthrough, Snippets.striped, Snippets.highlightUsage, Snippets.highlighter, Snippets.strikethrough, Snippets.directionalStrikethrough, Snippets.animatableStrike, Snippets.wave, Snippets.waveAnimation, Snippets.reveal, Snippets.rise, Snippets.applyRenderer, Snippets.scrubTime, Snippets.wordTime, Snippets.spoken, Snippets.clock, Snippets.words, Snippets.styleSwap, Snippets.strikeComparison, Snippets.builtIns, Snippets.cascade, Snippets.counted, Snippets.overlayStrike, Snippets.focus, Snippets.spoilerBlur, Snippets.spoilerPadding, Snippets.lyric, Snippets.momentsPreview, Snippets.snapshotTest(style: "spotlight"), Snippets.snappedDrift, Snippets.smoothDrift, Snippets.stateLines, Snippets.stateMarker, Snippets.trackedLines, Snippets.referenceMarker] {
            let lines = code.split(separator: "\n", omittingEmptySubsequences: false)
            #expect(lines.count <= 14)
            #expect(lines.allSatisfy { $0.count <= 42 })
            #expect(!code.contains("// Missing slide region"))
        }
    }

    @MainActor @Test func strikethroughFocusCoversItsLoop() {
        #expect(Snippets.strikethrough.split(separator: "\n").count == 14)
    }
}

struct HighlighterTests {
    @Test func colorsTokensLikeXcode() {
        let code = "struct Wave: TextRenderer {\n    let y = sin(Double(i) / 2) // wobble\n}"
        let roles = SwiftHighlighter.roles(in: code).map { "\(code[$0.range]):\($0.role)" }
        #expect(roles == ["struct:keyword", "Wave:projectType", "TextRenderer:systemType", "let:keyword", "sin:systemMember", "Double:systemType", "2:number", "// wobble:comment"])
    }

    @Test func colorsMembersAndLabelsByWhereTheyAreDeclared() {
        let code = "run[WordTime.self]?.progress(at: time)\nlit.clip(to: Path(r))\nr.divided(from: .maxXEdge)"
        let roles = SwiftHighlighter.roles(in: code).map { "\(code[$0.range]):\($0.role)" }
        #expect(roles == [
            "WordTime:projectType", "self:keyword", "progress:projectMember", "at:projectMember", "time:projectMember",
            "clip:systemMember", "to:systemMember", "Path:systemType",
            "divided:systemMember", "from:systemMember", "maxXEdge:systemMember",
        ])
    }

    @Test func leavesLocalsPlainWhenTheyShadowProjectMembers() {
        let code = "guard let progress = word else { return }\nlet d = progress * time"
        let roles = SwiftHighlighter.roles(in: code).map { "\(code[$0.range]):\($0.role)" }
        #expect(roles == ["guard:keyword", "let:keyword", "else:keyword", "return:keyword", "let:keyword", "time:projectMember"])
    }
}

struct WordTimeTests {
    @Test func eachWordFollowsThePreviousWord() {
        let text = WordTime.spoken("One two three")
        let ranges = text.runs[WordTime.self].compactMap { $0.0?.range }
        #expect(ranges.count == 3)
        #expect(ranges.first?.lowerBound == 0)
        #expect(zip(ranges, ranges.dropFirst()).allSatisfy { $0.upperBound == $1.lowerBound })
    }

    @Test func progressStaysBetweenZeroAndOne() {
        let word = WordTime(range: 1..<2)
        #expect(word.progress(at: 0) == 0)
        #expect(word.progress(at: 1.5) == 0.5)
        #expect(word.progress(at: 3) == 1)
    }
}

struct TranscriptTests {
    static let json = Data("""
    {"words": [
        {"text": "Hello", "type": "word", "start": 0.0, "end": 0.5, "speakerId": "a"},
        {"text": " ", "type": "spacing", "start": 0.5, "end": 0.6, "speakerId": "a"},
        {"text": "(laughs)", "type": "audio_event", "start": 0.6, "end": 1.0, "speakerId": "a"},
        {"text": "world", "type": "word", "start": 1.0, "end": 1.4, "speakerId": "a"}
    ]}
    """.utf8)

    @Test func timesOnlyTheSpokenWords() throws {
        let transcript = try JSONDecoder().decode(Transcript.self, from: Self.json)
        let text = transcript.text
        let timed = text.runs[WordTime.self].compactMap { $0.0 == nil ? nil : String(text[$0.1].characters) }
        #expect(String(text.characters) == "Hello world")
        #expect(timed == ["Hello", "world"])
        #expect(transcript.duration == 1.4)
    }

    @Test func aWordWithNoDurationIsStillTimed() {
        let transcript = Transcript(words: [
            .init(text: "It's", type: .word, start: 1, end: 1),
            .init(text: " ", type: .spacing, start: 1, end: 1),
            .init(text: "infinite", type: .word, start: 1, end: 1),
        ])
        let text = transcript.text
        let ranges = text.runs[WordTime.self].compactMap { $0.0?.range }
        #expect(ranges == [1..<1, 1..<1])
    }

    @Test func timecodeMatchesDurationFormatting() {
        for tenths in 0...6500 {
            let time = Double(tenths) / 10
            #expect(Clip.timecode(time) == Duration.seconds(time).formatted(.time(pattern: .minuteSecond)), "\(time)")
        }
        #expect(Clip.timecode(-1) == "0:00")
        #expect(Clip.timecode(.nan) == "0:00")
    }

    @Test func aWordStaysCurrentOnlyThroughAShortGap() {
        let transcript = Transcript(words: [
            .init(text: "One", type: .word, start: 0, end: 0.5),
            .init(text: " ", type: .spacing, start: 0.5, end: 0.6),
            .init(text: "two", type: .word, start: 0.6, end: 1.0),
            .init(text: " ", type: .spacing, start: 1.0, end: 2.0),
            .init(text: "three", type: .word, start: 2.0, end: 2.5),
        ])
        let text = transcript.text
        let ranges = text.runs[WordTime.self].compactMap { $0.0?.range }
        #expect(ranges == [0..<0.6, 0.6..<1.0, 2.0..<2.5])
    }

    @MainActor @Test func aFrameIsAFunctionOfTime() throws {
        let text = try JSONDecoder().decode(Transcript.self, from: Self.json).text
        func frame(at time: TimeInterval) throws -> [UInt8] {
            let view = TranscriptViewport(
                text: text, time: time,
                height: 200, textStyle: .meta
            )
            return try pixels(view.frame(width: 400))
        }
        let tolerance = Self.antialiasingTolerance
        let early = try frame(at: 0.2)
        #expect(try largestDifference(early, frame(at: 0.2)) <= tolerance)
        #expect(try largestDifference(early, frame(at: 1.2)) > tolerance)
    }

    @MainActor @Test func cullingLeavesTheFrameUnchanged() throws {
        let words = (0..<60).flatMap { i -> [Transcript.Word] in
            let start = Double(i)
            return [
                .init(text: "word\(i)", type: .word, start: start, end: start + 0.5),
                .init(text: " ", type: .spacing, start: start + 0.5, end: start + 1),
            ]
        }
        let text = Transcript(words: words).text
        func frame(culls: Bool) throws -> [UInt8] {
            try pixels(TranscriptViewport(text: text, time: 30, tuning: .init(culls: culls), height: 200, textStyle: .meta).frame(width: 400))
        }
        #expect(try largestDifference(frame(culls: true), frame(culls: false)) <= Self.antialiasingTolerance)
    }

    /// SwiftUI caches content after a few identical draws, and the cached copy anti-aliases up to about 51 levels differently.
    private static let antialiasingTolerance = 64

    @MainActor private func pixels(_ view: some View) throws -> [UInt8] {
        let image = try #require(ImageRenderer(content: view).cgImage)
        return [UInt8](try #require(image.dataProvider?.data) as Data)
    }

    private func largestDifference(_ a: [UInt8], _ b: [UInt8]) -> Int {
        zip(a, b).map { abs(Int($0) - Int($1)) }.max() ?? 0
    }

    @Test func cullingSkipsLinesOutsideTheViewport() {
        let renderer = TranscriptRenderer(time: 0, height: 200)
        let line = CGRect(x: 0, y: 0, width: 400, height: 40)
        #expect(renderer.isVisible(line, offset: 100))
        #expect(!renderer.isVisible(line, offset: -100))
        #expect(!renderer.isVisible(line, offset: 300))
    }
}
