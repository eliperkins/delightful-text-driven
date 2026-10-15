import SwiftUI

struct SectionCard: View {
    var subtitle: String?

    @Environment(\.talkPart) private var part

    var body: some View {
        Slide(background: .clear) {
            VStack(alignment: .leading, spacing: Theme.Layout.sectionSpacing) {
                Text(part.title)
                    .slideText(SlideText.displaySection.color(Theme.shiftInk))
                if let subtitle {
                    Text(subtitle)
                        .slideText(SlideText.subtitleCompact.color(Theme.shiftInk))
                }
            }
            .frame(maxWidth: Theme.Layout.sectionMaxWidth, alignment: .leading)
            .padding(.bottom, Theme.Layout.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .background(alignment: .bottomTrailing) {
            Text("\(part.rawValue)")
                .slideText(.numeral)
                .fixedSize()
                // A line box as tall as the font size, so the bleed matches the mockup's CSS `line-height: 1`.
                .frame(height: SlideText.numeral.size)
                .offset(x: -Theme.Layout.numeralTrailing, y: Theme.Layout.numeralBleed)
        }
        .background(Theme.shiftBackground)
    }
}

#Preview {
    SlidePreview(part: .lines) {
        SectionCard(subtitle: "SwiftUI owns the layout. You own the drawing.")
    }
}
