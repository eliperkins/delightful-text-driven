import SwiftUI

enum SlideRenderMode {
    case live
    /// Demos show a static frame here: no `TimelineView`, `AVPlayer`, or repeating animations.
    case thumbnail
}

extension EnvironmentValues {
    /// The current build step of the slide being rendered, starting at 0.
    @Entry var slideStep = 0
    /// The part of the talk the rendered slide belongs to.
    @Entry var talkPart = TalkPart.hook
    @Entry var slideRenderMode = SlideRenderMode.live
}
