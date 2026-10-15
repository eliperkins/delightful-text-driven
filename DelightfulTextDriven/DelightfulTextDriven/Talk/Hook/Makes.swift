import SwiftUI

/// The same statement three times; only the last word changes per step.
/// "Simple" carries an asterisk that the Footguns section card pays off.
struct Makes: View {
    @Environment(\.slideStep) private var step

    static let qualities = ["declarative", "simple\\*", "delightful"]

    var body: some View {
        Statement("`TextRenderer` makes these effects *\(Self.qualities[min(step, Self.qualities.count - 1)])*.")
            .overlay(alignment: .bottomLeading) {
                if step == 1 {
                    Text(verbatim: "*mostly")
                        .slideText(.meta)
                        .padding(.horizontal, Theme.Layout.margin)
                        .padding(.bottom, Theme.Layout.bottom)
                }
            }
    }
}

#Preview {
    SlidePreview(step: 2) {
        Makes()
    }
}
