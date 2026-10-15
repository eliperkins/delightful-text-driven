import SwiftUI

struct Resources: View {
    static let links = [
        ("Create custom visual effects with SwiftUI", "developer.apple.com/videos/play/wwdc2024/10151"),
        ("TextRenderer, TextAttribute, and textRenderer(_:)", "developer.apple.com/documentation/swiftui/textrenderer"),
        ("Creating Stunning Dynamic Text Effects with TextRenderer", "fatbobman.com/en/posts/creating-stunning-dynamic-text-effects-with-textrender"),
        ("Prismic", "github.com/twostraws/Prismic"),
    ]

    var body: some View {
        Slide(label: "Additional resources") {
            VStack(alignment: .leading, spacing: Theme.Layout.resourceSpacing) {
                ForEach(Self.links, id: \.1) { title, url in
                    VStack(alignment: .leading, spacing: Theme.Layout.resourceLineSpacing) {
                        Text(title)
                            .slideText(.subtitleCompact)
                        Text(url)
                            .slideText(.caption)
                    }
                }
            }
            .padding(.top, Theme.Layout.contentTop)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
