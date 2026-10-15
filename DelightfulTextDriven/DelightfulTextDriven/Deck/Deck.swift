import SwiftUI

/// The talk's six parts, in order. Budgets come from the outline and drive pacing in the presenter window.
enum TalkPart: Int, CaseIterable, Sendable {
    case hook = 1, lines, drawing, animation, pitfalls, close

    var title: String {
        switch self {
        case .hook: "Lead in"
        case .lines: "Lines, runs, and glyphs"
        case .drawing: "Custom drawing"
        case .animation: "Animation and time"
        case .pitfalls: "Footguns and pitfalls"
        case .close: "Build delight"
        }
    }

    var budget: Duration {
        switch self {
        case .hook: .seconds(7 * 60)
        case .lines: .seconds(9 * 60)
        case .drawing: .seconds(6 * 60)
        case .animation: .seconds(14 * 60)
        case .pitfalls: .seconds(5 * 60)
        case .close: .seconds(2 * 60)
        }
    }

    var plannedStart: Duration {
        Self.allCases.prefix { $0 != self }.reduce(.zero) { $0 + $1.budget }
    }
}

/// Something the presenter does on a slide's live controls. The presenter view shows it on its step.
enum SlideAction: Hashable {
    case press(String)
    case drag(String)
    case key(String)

    var title: String {
        switch self {
        case .press(let control): "Press \(control)"
        case .drag(let control): "Drag \(control)"
        case .key(let key): "Press \(key)"
        }
    }

    var systemImage: String {
        switch self {
        case .press: "hand.tap"
        case .drag: "slider.horizontal.3"
        case .key: "keyboard"
        }
    }
}

/// One slide in the deck: its view plus the metadata the presenter needs without rendering it.
struct SlideEntry {
    let view: AnyView
    private(set) var steps = 1
    private(set) var notes = ""
    private(set) var actionsByStep: [Int: [SlideAction]] = [:]
    fileprivate(set) var part = TalkPart.hook

    init(_ view: some View) {
        self.view = AnyView(view)
    }

    /// The number of clicks this slide consumes before advancing, including its first appearance.
    func steps(_ count: Int) -> SlideEntry {
        var copy = self
        copy.steps = max(1, count)
        return copy
    }

    func notes(_ text: String) -> SlideEntry {
        var copy = self
        copy.notes = text
        return copy
    }

    /// The live controls to use at `step`, in order.
    func actions(_ actions: SlideAction..., at step: Int = 0) -> SlideEntry {
        adding(actions, at: step)
    }

    fileprivate func adding(_ actions: [SlideAction], at step: Int) -> SlideEntry {
        var copy = self
        copy.actionsByStep[step, default: []] += actions
        return copy
    }

    func actions(at step: Int) -> [SlideAction] {
        actionsByStep[step] ?? []
    }

    func rendered(step: Int) -> some View {
        view
            .environment(\.slideStep, step)
            .environment(\.talkPart, part)
    }
}

// Lets `.steps(_:)`, `.notes(_:)`, and `.actions(_:at:)` start a chain directly on a slide view inside `Part { }`.
// They return a `SlideEntry`, not a view, so they can't be mixed into ordinary view modifier chains.
extension View {
    func steps(_ count: Int) -> SlideEntry { SlideEntry(self).steps(count) }
    func notes(_ text: String) -> SlideEntry { SlideEntry(self).notes(text) }
    func actions(_ actions: SlideAction..., at step: Int = 0) -> SlideEntry { SlideEntry(self).adding(actions, at: step) }
}

@resultBuilder
enum SlideBuilder {
    static func buildExpression(_ view: some View) -> [SlideEntry] { [SlideEntry(view)] }
    static func buildExpression(_ entry: SlideEntry) -> [SlideEntry] { [entry] }
    static func buildBlock(_ components: [SlideEntry]...) -> [SlideEntry] { components.flatMap(\.self) }
    static func buildOptional(_ component: [SlideEntry]?) -> [SlideEntry] { component ?? [] }
    static func buildEither(first component: [SlideEntry]) -> [SlideEntry] { component }
    static func buildEither(second component: [SlideEntry]) -> [SlideEntry] { component }
    static func buildArray(_ components: [[SlideEntry]]) -> [SlideEntry] { components.flatMap(\.self) }
}

/// A group of slides belonging to one part of the talk.
struct Part {
    let part: TalkPart
    let slides: [SlideEntry]

    init(_ part: TalkPart, @SlideBuilder slides: () -> [SlideEntry]) {
        self.part = part
        self.slides = slides().map { entry in
            var entry = entry
            entry.part = part
            return entry
        }
    }
}

@resultBuilder
enum DeckBuilder {
    static func buildBlock(_ parts: Part...) -> [Part] { parts }
}

/// The ordered slides of the talk, flattened from its parts.
struct Deck {
    let slides: [SlideEntry]

    init(@DeckBuilder _ parts: () -> [Part]) {
        slides = parts().flatMap(\.slides)
    }
}
