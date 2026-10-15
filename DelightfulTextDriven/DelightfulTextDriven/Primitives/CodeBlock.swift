import SwiftUI

/// Lines outside `focus` (1-based) are dimmed.
struct CodeBlock: View {
    let code: String
    var focus: ClosedRange<Int>?

    init(_ code: String, focus: ClosedRange<Int>? = nil) {
        self.code = code
        self.focus = focus
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                Text(line)
                    .opacity(focus?.contains(index + 1) ?? true ? 1 : Theme.dimmedCodeOpacity)
            }
        }
        .slideText(.code)
        .fixedSize()
    }

    /// Highlights the whole snippet first, so tokens that span lines keep their color.
    private var lines: [AttributedString] {
        let text = SwiftHighlighter.highlight(code)
        return text.characters
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.isEmpty ? AttributedString(" ") : AttributedString(text[$0.startIndex..<$0.endIndex]) }
    }
}

#Preview {
    SlidePreview(part: .lines) {
        CodeBlock("struct Wave: TextRenderer {\n    var phase: Double\n}", focus: 2...2)
            .padding(Theme.Layout.codePanelPadding)
            .background(Theme.codeBackground)
    }
}
