import Synchronization
import SwiftUI

/// Counts each `draw` into a counter that SwiftUI doesn't observe, because `draw` must never publish state.
// slide: counted
struct Counted<Base: TextRenderer>:
    TextRenderer {
    var base: Base
    var counter: DrawCounter?

    func draw(
        layout: Text.Layout,
        in ctx: inout GraphicsContext
    ) {
        counter?.increment()
        base.draw(layout: layout, in: &ctx)
    }
}
// slide: end

extension Counted {
    init(_ base: Base, counter: DrawCounter?) {
        self.base = base
        self.counter = counter
    }

    var displayPadding: EdgeInsets { base.displayPadding }

    func sizeThatFits(proposal: ProposedViewSize, text: TextProxy) -> CGSize {
        base.sizeThatFits(proposal: proposal, text: text)
    }
}

nonisolated final class DrawCounter: Sendable {
    static let shared = DrawCounter()

    private let count = Atomic(0)

    func increment() {
        count.add(1, ordering: .relaxed)
    }

    @discardableResult
    func drain() -> Int {
        count.exchange(0, ordering: .relaxed)
    }
}

extension Snippets {
    static var counted: String { region("counted") }
}
