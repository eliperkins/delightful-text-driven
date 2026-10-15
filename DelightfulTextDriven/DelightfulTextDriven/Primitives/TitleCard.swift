import SwiftUI

/// `title` takes `*emphasis*`.
struct TitleCard: View {
    var title = "Delightful *Text-Driven* Experiences"
    var subtitle = "with SwiftUI's TextRenderer"
    var speaker = "Eli Perkins"
    var event = "SwiftLeeds 2026"
    var revealStep: Int?

    @Environment(\.slideStep) private var step
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.bylineSpacing) {
            VStack(alignment: .leading, spacing: Theme.Layout.subtitleSpacing) {
                titleText
                    .opacity(revealStep == nil ? 1 : 0)
                    .overlay(alignment: .topLeading) {
                        if let revealStep, step >= revealStep {
                            titleText
                                .transition(.textReveal(reduceMotion: reduceMotion))
                        }
                    }
                    .animation(Theme.Motion.reveal, value: step)
                Text(subtitle)
                    .slideText(.subtitle)
            }
            byline
        }
        .padding(.trailing, Theme.Layout.titleTrailing)
        .padding(.bottom, Theme.Layout.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.horizontal, Theme.Layout.margin)
        .background(Theme.background)
    }

    private var byline: some View {
        HStack(spacing: Theme.Layout.avatarSpacing) {
            Image(.headshot)
                .resizable()
                .scaledToFill()
                .frame(width: Theme.Layout.avatarSize, height: Theme.Layout.avatarSize)
                .clipShape(.circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(speaker)
                    .slideText(SlideText.meta.color(Theme.ink))
                Text(event)
                    .slideText(.meta)
            }
        }
    }

    private var titleText: some View {
        Text(SlideText.emphasized(title))
            .attributedTextFormattingDefinition(SlideTextFormatting())
            .slideText(.display)
    }
}

#Preview {
    SlidePreview {
        TitleCard()
    }
}
