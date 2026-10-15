import SwiftUI

extension View {
    /// Hides this view until the slide reaches `step`, then cuts it in with no animation.
    ///
    /// The view keeps its space while hidden, so revealing it never reflows anything else on the slide.
    func build(at step: Int) -> some View {
        modifier(BuildModifier(step: step))
    }
}

private struct BuildModifier: ViewModifier {
    /// How visible a not-yet-built view is with Debug → Reveal Hidden Builds on.
    private static let revealedOpacity = 0.25

    let step: Int

    @Environment(\.slideStep) private var currentStep
    @Environment(\.revealsHiddenBuilds) private var revealsHiddenBuilds

    func body(content: Content) -> some View {
        let isBuilt = currentStep >= step
        content
            .opacity(isBuilt ? 1 : (revealsHiddenBuilds ? Self.revealedOpacity : 0))
            .allowsHitTesting(isBuilt)
            .accessibilityHidden(!isBuilt)
    }
}
