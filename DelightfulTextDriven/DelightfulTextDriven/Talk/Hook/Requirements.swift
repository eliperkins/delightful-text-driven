import SwiftUI

/// One requirement cuts in per step.
struct Requirements: View {
    static let items = [
        "Blur the spoiler subject",
        "while supporting Dynamic Type",
        "ensuring we don't break l10n and RTL layouts",
        "for each different screen size",
        "without spoiling it for VoiceOver",
        "😱 😱 😱",
    ]

    var body: some View {
        Slide {
            VStack(alignment: .leading, spacing: Theme.Layout.requirementSpacing) {
                ForEach(Array(Self.items.enumerated()), id: \.offset) { index, item in
                    Text(item)
                        .slideText(index == 0 ? .requirement : SlideText.requirement.color(Theme.ink2))
                        .build(at: index)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SlidePreview(step: Requirements.items.count - 1) {
        Requirements()
    }
}
