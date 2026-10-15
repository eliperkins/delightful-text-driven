import SwiftUI

/// `text` takes `*emphasis*`.
struct Statement: View {
    let text: String
    let kicker: String?
    let label: String?
    let style: SlideText
    let alignment: Alignment

    init(_ text: String, kicker: String? = nil, label: String? = nil, style: SlideText = .statement, alignment: Alignment = .leading) {
        self.text = text
        self.kicker = kicker
        self.label = label
        self.style = style
        self.alignment = alignment
    }

    var body: some View {
        Slide(label: label) {
            VStack(alignment: alignment.horizontal, spacing: 0) {
                if let kicker {
                    Text(kicker)
                        .slideText(.kicker)
                }
                Text(SlideText.emphasized(text))
                    .slideText(style)
            }
            .multilineTextAlignment(alignment == .center ? .center : .leading)
            .padding(.trailing, alignment == .leading ? Theme.Layout.statementTrailing : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        }
    }
}

#Preview {
    SlidePreview(part: .animation) {
        Statement("Anything can be a value. *Even time.*")
    }
}
