import SwiftUI

struct PureTimeCode: View {
    @Environment(\.slideStep) private var step
    var text = Clip.text

    var body: some View {
        Slide(label: "Snapshot a moment in time") {
            HStack(spacing: Theme.Layout.splitGap) {
                CodeBlock(Snippets.snapshotTest(style: step == 0 ? "deepPill" : "spotlight"), focus: step == 0 ? nil : 5...5)
                    .padding(Theme.Layout.codePanelPadding)
                    .frame(width: Theme.Layout.splitLeadingWidth, alignment: .leading)
                    .frame(maxHeight: .infinity)
                    .background(Theme.codeBackground, in: .rect(cornerRadius: Theme.Layout.panelCornerRadius))
                if let text {
                    VStack(spacing: Theme.Layout.frameTileSpacing) {
                        SnapshotTile(caption: "reference · .deepPill") {
                            snapshot(text, style: .deepPill)
                        }
                        // Hidden, not removed, so the reference doesn't move when these cut in.
                        Group {
                            SnapshotTile(caption: "failure · .spotlight") {
                                snapshot(text, style: .spotlight)
                            }
                            SnapshotTile(caption: "difference") {
                                ZStack {
                                    snapshot(text, style: .deepPill)
                                    snapshot(text, style: .spotlight)
                                        .compositingGroup()
                                        .blendMode(.difference)
                                }
                                .compositingGroup()
                            }
                        }
                        .opacity(step == 0 ? 0 : 1)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.top, Theme.Layout.contentTop)
            .padding(.bottom, Theme.Layout.splitBottom)
        }
    }

    /// Mid "because", past its fade, so the pill is fully in.
    private static let time = 12.0

    /// Opaque, so the difference blend leaves black where nothing changed.
    private func snapshot(_ text: AttributedString, style: TranscriptRenderer.HighlightStyle) -> some View {
        TranscriptViewport(text: text, time: Self.time, style: style, height: Theme.Layout.frameTileHeight, textStyle: .meta)
            .padding(Theme.Layout.frameTilePadding)
            .background(Theme.background)
    }
}

struct SnapshotTile<Content: View>: View {
    let caption: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: Theme.Layout.frameTileSpacing) {
            content
                .clipShape(.rect(cornerRadius: Theme.Layout.panelCornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Layout.panelCornerRadius)
                        .strokeBorder(Theme.line, lineWidth: Theme.Layout.livePaneBorderWidth)
                }
            Text(caption)
                .slideText(.caption)
        }
    }
}

extension Snippets {
    /// The deck doesn't depend on swift-snapshot-testing, so this test never runs.
    static func snapshotTest(style: String) -> String {
        """
        @Test func transcriptAt12Seconds() {
          let view = Text(transcript)
            .textRenderer(TranscriptRenderer(
              time: 12,
              style: .\(style),
              height: 300))
            .frame(width: 600, height: 300)
          assertSnapshot(of: view, as: .image)
        }
        """
    }
}

#Preview {
    SlidePreview(step: 1, part: .animation) {
        PureTimeCode()
    }
}
