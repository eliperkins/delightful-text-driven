import AppKit

/// Routes navigation keys to the presentation before any view sees them.
///
/// A local key-down monitor runs ahead of the responder chain, so a slider or button that holds focus
/// inside a live demo can't swallow the clicker. Keys that aren't navigation pass through to the demos.
final class KeyMonitor {
    private var token: Any?
    private weak var presentation: Presentation?
    private weak var stage: Stage?

    /// Sends navigation keys to `presentation`, installing the monitor on first use.
    /// Call again to retarget it, e.g. when the Debug menu swaps in the theme gallery.
    func route(to presentation: Presentation, stage: Stage) {
        self.presentation = presentation
        self.stage = stage
        guard token == nil else { return }
        token = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let handled = MainActor.assumeIsolated {
                self?.handle(event) ?? false
            }
            return handled ? nil : event
        }
    }

    private func handle(_ event: NSEvent) -> Bool {
        let isPresenting = stage?.isPresenting ?? false
        // X reaches the demos unless presenting, when it swaps displays like Keynote.
        if isPresenting, Self.isDeckKey(event), event.charactersIgnoringModifiers?.lowercased() == "x" {
            stage?.swapDisplays()
            return true
        }
        guard let presentation, let command = Self.command(for: event) else { return false }
        presentation.perform(command)
        if isPresenting {
            NSCursor.setHiddenUntilMouseMoves(true)
        }
        return true
    }

    private static func isDeckKey(_ event: NSEvent) -> Bool {
        event.modifierFlags.intersection([.command, .control, .option]).isEmpty && !(NSApp.keyWindow?.firstResponder is NSText)
    }

    private static func command(for event: NSEvent) -> DeckCommand? {
        // Leave ⌘ shortcuts to the menus, and typing to any text field being edited.
        guard isDeckKey(event) else { return nil }

        switch event.specialKey {
        case .rightArrow?, .downArrow?, .pageDown?: return .forward
        case .leftArrow?, .upArrow?, .pageUp?: return .back
        case .carriageReturn?, .enter?: return .commitJump
        default: break
        }

        switch event.charactersIgnoringModifiers {
        case " ": return .forward
        case "\u{1B}": return .cancel
        // Clickers usually send B or period for their "black screen" button.
        case "b", "B", ".": return .toggleBlackout
        case "h", "H": return .toggleHUD
        case let characters?:
            if characters.count == 1, let digit = characters.first?.wholeNumberValue { return .digit(digit) }
            return nil
        case nil: return nil
        }
    }
}
