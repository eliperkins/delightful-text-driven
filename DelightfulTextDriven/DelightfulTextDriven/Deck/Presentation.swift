import Foundation
import Observation

/// Everything the keyboard, clicker, and hover controls can ask the deck to do.
enum DeckCommand: Equatable {
    case forward
    case back
    case restart
    case digit(Int)
    case commitJump
    case cancel
    case toggleBlackout
    case toggleHUD
}

/// The live state of the talk: which slide and step is showing, shared by every window.
@Observable
final class Presentation {
    struct Position: Equatable {
        var slide: Int
        var step: Int
    }

    let deck: Deck
    private(set) var position: Position {
        didSet {
            defaults.set(position.slide + 1, forKey: Self.slideKey)
            recordPartStart()
        }
    }
    private(set) var isBlackedOut = false
    private(set) var showsHUD = false
    private(set) var startedAt: Date? {
        didSet { defaults.set(startedAt, forKey: Self.timerStartKey) }
    }
    private(set) var partStarts: [TalkPart: Date] = [:]
    /// Digits typed so far for a Keynote-style "number, then Return" jump.
    private(set) var pendingJump = ""

    @ObservationIgnored private let defaults: UserDefaults

    /// Stored 1-based, so `-slide 17` as a launch argument opens straight onto slide 17.
    static let slideKey = "slide"
    static let timerStartKey = "timerStart"

    init(deck: Deck, defaults: UserDefaults = .standard) {
        self.deck = deck
        self.defaults = defaults
        let saved = defaults.integer(forKey: Self.slideKey) - 1
        let slide = deck.slides.indices.contains(saved) ? saved : 0
        position = Position(slide: slide, step: 0)
        startedAt = defaults.object(forKey: Self.timerStartKey) as? Date
    }

    var currentSlide: SlideEntry { deck.slides[position.slide] }
    var slideCount: Int { deck.slides.count }

    var nextPosition: Position? {
        if position.step + 1 < currentSlide.steps {
            return Position(slide: position.slide, step: position.step + 1)
        }
        if position.slide + 1 < slideCount {
            return Position(slide: position.slide + 1, step: 0)
        }
        return nil
    }

    func elapsed(at date: Date) -> Duration? {
        startedAt.map { .seconds(date.timeIntervalSince($0)) }
    }

    func actualStart(of part: TalkPart) -> Duration? {
        guard let startedAt, let partStart = partStarts[part] else { return nil }
        return .seconds(partStart.timeIntervalSince(startedAt).rounded())
    }

    func perform(_ command: DeckCommand) {
        switch command {
        case .forward: forward()
        case .back: back()
        case .restart: restart()
        case .digit(let digit): pendingJump.append(String(digit))
        case .commitJump: commitJump()
        case .cancel:
            pendingJump = ""
            isBlackedOut = false
        case .toggleBlackout: isBlackedOut.toggle()
        case .toggleHUD: showsHUD.toggle()
        }
    }

    func forward() {
        guard let nextPosition else { return }
        if startedAt == nil {
            let now = Date.now
            startedAt = now
            partStarts[currentSlide.part] = now
        }
        position = nextPosition
    }

    /// The previous step on this slide, or the *last* step of the previous slide.
    func back() {
        if position.step > 0 {
            position.step -= 1
        } else if position.slide > 0 {
            let previous = position.slide - 1
            position = Position(slide: previous, step: deck.slides[previous].steps - 1)
        }
    }

    func restart() {
        startedAt = nil
        partStarts = [:]
        position = Position(slide: 0, step: 0)
        pendingJump = ""
        isBlackedOut = false
    }

    /// Jumps to a 1-based slide number, clamped to the deck.
    func jump(toSlideNumber number: Int) {
        let slide = min(max(number - 1, 0), slideCount - 1)
        position = Position(slide: slide, step: 0)
    }

    private func recordPartStart() {
        guard startedAt != nil, partStarts[currentSlide.part] == nil else { return }
        partStarts[currentSlide.part] = .now
    }

    /// Return with digits typed jumps to that slide; Return on its own advances like any forward key.
    private func commitJump() {
        guard let number = Int(pendingJump) else {
            forward()
            return
        }
        pendingJump = ""
        jump(toSlideNumber: number)
    }
}
