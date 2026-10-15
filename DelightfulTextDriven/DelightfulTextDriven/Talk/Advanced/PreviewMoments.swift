import SwiftUI

struct PreviewMoments: View {
    var text = Clip.text

    var body: some View {
        Slide(label: "Preview moments in time") {
            HStack(spacing: Theme.Layout.splitGap) {
                CodeBlock(Snippets.momentsPreview)
                    .padding(Theme.Layout.codePanelPadding)
                    .frame(width: Theme.Layout.splitLeadingWidth, alignment: .leading)
                    .frame(maxHeight: .infinity)
                    .background(Theme.codeBackground, in: .rect(cornerRadius: Theme.Layout.panelCornerRadius))
                if let text {
                    VStack(spacing: Theme.Layout.frameTileSpacing) {
                        // Each lands mid-word, past its fade, so every pill is fully in.
                        ForEach([2.5, 12, 29.3], id: \.self) { time in
                            SnapshotTile(caption: "time: \(time.formatted())") {
                                TranscriptViewport(text: text, time: time, height: Theme.Layout.frameTileHeight, textStyle: .meta)
                                    .padding(Theme.Layout.frameTilePadding)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.top, Theme.Layout.contentTop)
            .padding(.bottom, Theme.Layout.splitBottom)
        }
    }
}

extension Snippets {
    static let momentsPreview = """
        #Preview("Three moments") {
          ForEach([2.5, 12, 29.3], id: \\.self) {
            Text(transcript)
              .textRenderer(TranscriptRenderer(
                time: $0,
                height: \(Int(Theme.Layout.frameTileHeight))))
              .frame(height: \(Int(Theme.Layout.frameTileHeight)))
          }
        }
        """
}

#Preview {
    SlidePreview(part: .animation) {
        PreviewMoments()
    }
}
