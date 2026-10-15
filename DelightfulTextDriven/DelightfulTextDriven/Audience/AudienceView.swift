import SwiftUI

/// The projector's view: the current slide on the scaled canvas, with chrome-free overlays outside it.
struct AudienceView: View {
    /// How long the hover controls stay up after the pointer stops moving.
    static let controlsIdleTimeout: Duration = .seconds(2)

    @Environment(Presentation.self) private var presentation
    @Environment(\.showsLayoutGuides) private var showsLayoutGuides

    @State private var showsControls = false
    @State private var isHoveringControls = false
    /// Bumped on every pointer move in the controls strip; restarts the idle timer that hides them.
    @State private var hoverGeneration = 0

    var body: some View {
        let slide = presentation.currentSlide

        SlideCanvas {
            slide.rendered(step: presentation.position.step)
                // A fresh identity per slide, so every live demo starts from its initial state.
                .id(presentation.position.slide)
                .overlay {
                    if showsLayoutGuides {
                        LayoutGuides()
                    }
                }
        }
        .overlay {
            if presentation.isBlackedOut {
                Color.black
            }
        }
        .overlay(alignment: .topTrailing) {
            if !presentation.pendingJump.isEmpty {
                Text("Go to \(presentation.pendingJump)")
                    .font(.title2.monospacedDigit())
                    .padding()
                    .glassEffect(.regular, in: .capsule)
                    .padding()
            }
        }
        .overlay(alignment: .topLeading) {
            if presentation.showsHUD {
                PerformanceHUD()
            }
        }
        .overlay(alignment: .bottom) {
            controlsStrip
        }
        .ignoresSafeArea()
    }

    /// A full-width strip along the bottom edge, as tall as the controls, that reveals them on hover.
    /// Pointing at demos elsewhere on the slide never brings them up.
    private var controlsStrip: some View {
        HoverControls()
            .onHover { isHoveringControls = $0 }
            .opacity(showsControls ? 1 : 0)
            .allowsHitTesting(showsControls)
            .animation(.easeOut, value: showsControls)
            .padding()
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
            .onContinuousHover { phase in
                guard case .active = phase else { return }
                showsControls = true
                hoverGeneration += 1
            }
            .task(id: hoverGeneration) {
                try? await Task.sleep(for: Self.controlsIdleTimeout)
                guard !Task.isCancelled, !isHoveringControls else { return }
                showsControls = false
            }
    }
}

#Preview {
    SlidePreview {
        AudienceView()
            .environment(Presentation(deck: .talk, defaults: UserDefaults(suiteName: "preview")!))
    }
}
