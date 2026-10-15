#if DEBUG
import SwiftUI

extension Deck {
    /// Every `Theme` token on real slides, for checking type, color, and layout on the projector.
    ///
    /// Turn on Debug → Theme Gallery to present this deck instead of the talk.
    static let themeGallery = Deck {
        Part(.hook) {
            GalleryTypePage(title: "Display and interface", styles: [
                ("display", .display),
                ("displaySection", .displaySection),
                ("displayDemo", .displayDemo),
                ("label", .label),
                ("meta", .meta),
                ("caption", .caption),
            ])
            GalleryTypePage(title: "Serif and code", styles: [
                ("statement", .statement),
                ("statementCompact", .statementCompact),
                ("subtitle", .subtitle),
                ("subtitleCompact", .subtitleCompact),
                ("code", .code),
            ])
            GalleryColorsPage()
            GalleryLayoutPage()
            GalleryBuildsPage()
                .steps(3)
        }
        Part(.lines) {
            TitleCard()
            SectionCard(subtitle: "SwiftUI owns the layout. You own the drawing.")
            Statement("Anything can be a value. *Even time.*")
            GallerySplitPage()
                .steps(2)
        }
    }
}

/// A gallery slide: a header at the standard position over full-margin content.
private struct GalleryPage<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        Slide(label: "Theme gallery", meta: title) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

private struct GalleryTypePage: View {
    let title: String
    let styles: [(name: String, style: SlideText)]

    var body: some View {
        GalleryPage(title: title) {
            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: Theme.Layout.splitGap) {
                ForEach(styles, id: \.name) { entry in
                    GridRow {
                        Text(".\(entry.name) · \(Int(entry.style.size))")
                            .slideText(.caption)
                            .gridColumnAlignment(.trailing)
                        Text("Delightful text")
                            .slideText(entry.style)
                    }
                }
            }
        }
    }
}

private struct GalleryColorsPage: View {
    private let roles: [(name: String, color: Color)] = [
        ("background", Theme.background),
        ("ink", Theme.ink),
        ("ink2", Theme.ink2),
        ("muted", Theme.muted),
        ("accent", Theme.accent),
        ("accentText", Theme.accentText),
        ("deep", Theme.deep),
        ("onDeep", Theme.onDeep),
        ("future", Theme.future),
        ("line", Theme.line),
        ("line2", Theme.line2),
        ("shiftBackground", Theme.shiftBackground),
        ("shiftInk", Theme.shiftInk),
        ("shiftAccent", Theme.shiftAccent),
        ("codeBackground", Theme.codeBackground),
    ]

    private let columns = Array(repeating: GridItem(spacing: Theme.Layout.splitGap), count: 5)

    var body: some View {
        GalleryPage(title: "Color roles") {
            LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.Layout.splitGap) {
                ForEach(roles, id: \.name) { role in
                    VStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: Theme.Layout.panelCornerRadius)
                            .fill(role.color)
                            .strokeBorder(Theme.line2, lineWidth: Theme.Layout.livePaneBorderWidth)
                            .aspectRatio(Theme.Layout.canvas, contentMode: .fit)
                        Text(role.name)
                            .slideText(.caption)
                    }
                }
            }
        }
    }
}

/// The layout guides over an empty slide, with the header in place.
private struct GalleryLayoutPage: View {
    var body: some View {
        GalleryPage(title: "Layout guides") {
            Color.clear
        }
        .overlay { LayoutGuides() }
    }
}

/// Three items that build in one per click, to check `.build(at:)` timing.
private struct GalleryBuildsPage: View {
    var body: some View {
        GalleryPage(title: "Builds") {
            VStack(alignment: .leading) {
                Text("Builds keep their space")
                    .slideText(.statementCompact)
                    .build(at: 0)
                Text("so nothing reflows")
                    .slideText(.statementCompact)
                    .build(at: 1)
                Text("when they fade in.")
                    .slideText(SlideText.statementCompact.color(Theme.accentText))
                    .build(at: 2)
            }
        }
    }
}

private struct GallerySplitPage: View {
    @Environment(\.slideStep) private var step

    var body: some View {
        Split(label: "Split", caption: ".textRenderer(Fade(opacity: \(Theme.dimmedCodeOpacity.formatted())))") {
            CodeBlock(Snippets.region("gallerySplit"), focus: step == 0 ? 1...2 : 4...12)
        } live: {
            Text("Hello, world")
                .slideText(SlideText.displayDemo.color(Theme.accentText))
                .textRenderer(Fade(opacity: Theme.dimmedCodeOpacity))
        }
    }
}

private extension GallerySplitPage {
    // slide: gallerySplit
    struct Fade: TextRenderer {
        var opacity: Double

        func draw(
            layout: Text.Layout,
            in context: inout GraphicsContext
        ) {
            context.opacity = opacity
            for line in layout {
                context.draw(line)
            }
        }
    }
    // slide: end
}

#Preview("Type") {
    SlidePreview {
        GalleryTypePage(title: "Display and interface", styles: [("display", .display), ("label", .label)])
    }
}

#Preview("Colors") {
    SlidePreview {
        GalleryColorsPage()
    }
}

#Preview("Layout") {
    SlidePreview {
        GalleryLayoutPage()
    }
}

#Preview("Builds, step 2") {
    SlidePreview(step: 1) {
        GalleryBuildsPage()
    }
}
#endif
