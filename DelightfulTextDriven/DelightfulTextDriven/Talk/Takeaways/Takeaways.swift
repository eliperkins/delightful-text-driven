import SwiftUI

struct Takeaways: View {
    static let all = [
        "Break down `Text` → *lines, runs, and glyphs*",
        "Plain runs → *runs you mark with attributes*",
        "Static → *driven by animations or your values*",
        "Timers and callbacks → *a pure function of time*",
        "A renderer for everything → *built-ins first*",
        "Boring text → *just the right touch*",
    ]

    var body: some View {
        Slide {
            VStack(alignment: .leading, spacing: Theme.Layout.requirementSpacing) {
                ForEach(Array(Self.all.enumerated()), id: \.offset) { index, takeaway in
                    Text(SlideText.emphasized(takeaway))
                        .slideText(.requirement)
                        .build(at: index)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SlidePreview(step: Takeaways.all.count - 1, part: .close) {
        Takeaways()
    }
}
