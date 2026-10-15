import SwiftUI

struct OverlayStrike: View {
    static let todo = StrikeComparison.todo

    @State private var struck = false

    var body: some View {
        Split(label: "SwiftUI.Text", caption: ".scaleEffect(x:anchor:)") {
            CodeBlock(Snippets.overlayStrike)
        } live: {
            // slide: overlayStrike
            Text(Self.todo)
                .overlay(alignment: .leading) {
                    Text(Self.todo)
                        .foregroundStyle(.clear)
                        .strikethrough(struck,
                            color: .white)
                        .scaleEffect(x: struck ? 1 : 0,
                            anchor: .leading)
                }
            // slide: end
                .slideText(SlideText.displayDemo.color(Theme.accentText))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(struck ? "Restore" : "Strike") {
                withAnimation(.bouncy) {
                    struck.toggle()
                }
            }
            .buttonStyle(.demo)
        }
    }
}

extension Snippets {
    static var overlayStrike: String { region("overlayStrike") }
}
