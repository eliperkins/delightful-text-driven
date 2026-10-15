import SwiftUI

struct SlideHeader: View {
    let label: String
    var meta: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .slideText(.label)
            Spacer()
            if let meta {
                Text(meta)
                    .slideText(.meta)
            }
        }
    }
}

/// Only code splits, scorecards, and slides with a legend take a `label`.
struct Slide<Content: View>: View {
    var label: String?
    var meta: String?
    var background = Theme.background
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(.horizontal, Theme.Layout.margin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .top) {
                if let label {
                    SlideHeader(label: label, meta: meta)
                        .padding(.horizontal, Theme.Layout.margin)
                        .padding(.top, Theme.Layout.headerTop)
                }
            }
            .background(background)
    }
}

#Preview {
    SlidePreview(part: .lines) {
        Slide(label: "Meet TextRenderer") {
            Color.clear
        }
    }
}
