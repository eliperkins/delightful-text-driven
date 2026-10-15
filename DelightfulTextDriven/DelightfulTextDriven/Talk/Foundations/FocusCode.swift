import SwiftUI

struct FocusCode: View {
    var highlightsFilter = false

    var body: some View {
        Split(label: "One value per line", caption: ".textRenderer(Focus(phase: t))") {
            CodeBlock(Snippets.focus, focus: highlightsFilter ? 8...8 : nil)
        } live: {
            FocusEffect(style: SlideText.statementTile.color(Theme.accentText))
        }
    }
}

extension Snippets {
    static var focus: String { region("focus", file: Self.replicasFile) }
}

#Preview {
    SlidePreview(part: .lines) {
        FocusCode()
    }
}

#Preview("Filter") {
    SlidePreview(part: .lines) {
        FocusCode(highlightsFilter: true)
    }
}
