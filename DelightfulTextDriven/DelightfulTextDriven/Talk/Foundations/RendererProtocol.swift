import SwiftUI

/// The protocol's surface, one piece per step. The code is SwiftUI's declaration, so it isn't cut from a demo.
struct RendererProtocol: View {
    @Environment(\.slideStep) private var step

    static let declaration = """
    protocol TextRenderer: Animatable {
        func draw(
            layout: Text.Layout,
            in ctx: inout GraphicsContext
        )

        func sizeThatFits(
            proposal: ProposedViewSize,
            text: TextProxy
        ) -> CGSize

        var displayPadding: EdgeInsets { get }
    }
    """

    private var focus: ClosedRange<Int>? {
        switch step {
        case 1: 2...5
        case 2: 7...12
        case 3: 1...1
        default: nil
        }
    }

    var body: some View {
        Slide(label: "Meet TextRenderer") {
            CodeBlock(Self.declaration, focus: focus)
                .padding(Theme.Layout.codePanelPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(Theme.codeBackground, in: .rect(cornerRadius: Theme.Layout.panelCornerRadius))
                .padding(.top, Theme.Layout.contentTop)
                .padding(.bottom, Theme.Layout.splitBottom)
        }
    }
}

#Preview {
    SlidePreview(step: 1, part: .lines) {
        RendererProtocol()
    }
}
