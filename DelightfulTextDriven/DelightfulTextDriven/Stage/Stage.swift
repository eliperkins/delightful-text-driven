import AppKit
import Observation

/// SwiftUI's window placement on macOS only knows the default display, so this works on the `NSWindow`s directly.
@Observable
final class Stage {
    enum Role {
        case audience, presenter
    }

    private(set) var isPresenting = false
    private var isSwapped = false

    @ObservationIgnored private weak var audienceWindow: NSWindow?
    @ObservationIgnored private weak var presenterWindow: NSWindow?
    @ObservationIgnored private var activity: NSObjectProtocol?
    // AppKit ignores a full-screen toggle while another transition runs, and then never posts the
    // notification `setFullScreen` waits for. So each placement waits for the one before it.
    @ObservationIgnored private var placement: Task<Void, Never>?

    func register(_ window: NSWindow, as role: Role) {
        switch role {
        case .audience: audienceWindow = window
        case .presenter: presenterWindow = window
        }
        if isPresenting {
            schedule { await self.place(window, as: role) }
        }
    }

    func togglePresenting() {
        isPresenting ? stop() : start()
    }

    func swapDisplays() {
        guard isPresenting, NSScreen.screens.count > 1 else { return }
        isSwapped.toggle()
        schedule { await self.placeAll() }
    }

    private func start() {
        isPresenting = true
        activity = ProcessInfo.processInfo.beginActivity(
            options: [.idleDisplaySleepDisabled, .userInitiated],
            reason: "Presenting the talk"
        )
        NSCursor.setHiddenUntilMouseMoves(true)
        schedule { await self.placeAll() }
    }

    private func stop() {
        isPresenting = false
        isSwapped = false
        if let activity {
            ProcessInfo.processInfo.endActivity(activity)
        }
        activity = nil
        schedule {
            for window in [self.audienceWindow, self.presenterWindow].compactMap(\.self) {
                await self.setFullScreen(window, false)
            }
        }
    }

    private func schedule(_ work: @escaping () async -> Void) {
        placement = Task { [previous = placement] in
            await previous?.value
            await work()
        }
    }

    private func placeAll() async {
        if let audienceWindow {
            await place(audienceWindow, as: .audience)
        }
        if let presenterWindow {
            await place(presenterWindow, as: .presenter)
        }
    }

    private func place(_ window: NSWindow, as role: Role) async {
        let laptop = NSScreen.screens.first { $0.cgDirectDisplayID.map(CGDisplayIsBuiltin) == 1 } ?? NSScreen.main
        let others = NSScreen.screens.filter { $0 != laptop }
        let screens = Self.screens(laptop: laptop, others: others, swapped: isSwapped)
        guard let screen = role == .audience ? screens.audience : screens.presenter else { return }

        if window.screen != screen {
            // Native full screen stays on the window's current display, so leave it before moving.
            await setFullScreen(window, false)
            window.setFrame(screen.visibleFrame, display: true)
        }
        await setFullScreen(window, true)
    }

    static func screens<Screen: Equatable>(
        laptop: Screen?,
        others: [Screen],
        swapped: Bool
    ) -> (audience: Screen?, presenter: Screen?) {
        guard let external = others.first else { return (laptop, nil) }
        return swapped ? (laptop, external) : (external, laptop)
    }

    private func setFullScreen(_ window: NSWindow, _ fullScreen: Bool) async {
        guard window.styleMask.contains(.fullScreen) != fullScreen else { return }
        let name = fullScreen ? NSWindow.didEnterFullScreenNotification : NSWindow.didExitFullScreenNotification
        let transition = NotificationCenter.default.notifications(named: name, object: window)
        window.toggleFullScreen(nil)
        for await _ in transition {
            break
        }
    }
}
