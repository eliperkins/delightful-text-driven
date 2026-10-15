import SwiftUI

/// System button styles size themselves in window points, which read tiny on the 1920-point canvas.
struct DemoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .slideText(SlideText.meta.color(Theme.onDeep))
            .padding(Theme.Layout.demoButtonPadding)
            .glassEffect(.regular.tint(Theme.deep).interactive(), in: .capsule)
    }
}

extension ButtonStyle where Self == DemoButtonStyle {
    static var demo: DemoButtonStyle { DemoButtonStyle() }
}
