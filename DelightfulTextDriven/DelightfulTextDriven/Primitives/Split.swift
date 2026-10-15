import SwiftUI

struct Split<Code: View, Live: View>: View {
    let label: String
    let caption: String
    @ViewBuilder var code: Code
    @ViewBuilder var live: Live

    var body: some View {
        Slide(label: label) {
            HStack(spacing: Theme.Layout.splitGap) {
                code
                    .padding(Theme.Layout.codePanelPadding)
                    .frame(width: Theme.Layout.splitLeadingWidth, alignment: .leading)
                    .frame(maxHeight: .infinity)
                    .background(Theme.codeBackground, in: .rect(cornerRadius: Theme.Layout.panelCornerRadius))

                VStack(spacing: Theme.Layout.livePaneSpacing) {
                    live
                    Text(caption)
                        .slideText(.caption)
                }
                .padding(Theme.Layout.livePanePadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .topLeading) {
                    liveTag
                        .padding(Theme.Layout.liveTagInset)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Layout.panelCornerRadius)
                        .strokeBorder(Theme.line, lineWidth: Theme.Layout.livePaneBorderWidth)
                }
            }
            .padding(.top, Theme.Layout.contentTop)
            .padding(.bottom, Theme.Layout.splitBottom)
        }
    }

    private var liveTag: some View {
        HStack(spacing: Theme.Layout.liveTagSpacing) {
            Circle()
                .fill(Theme.live)
                .frame(width: Theme.Layout.liveDotSize, height: Theme.Layout.liveDotSize)
            Text("Live")
                .slideText(.liveTag)
        }
        .padding(Theme.Layout.liveTagPadding)
        .overlay {
            Capsule()
                .strokeBorder(Theme.line, lineWidth: Theme.Layout.liveTagBorderWidth)
        }
    }
}

#Preview {
    SlidePreview(part: .lines) {
        Split(label: "Meet TextRenderer", caption: ".textRenderer(Wave(phase: t))") {
            Text("struct Wave: TextRenderer {\n    var phase: Double\n}")
                .slideText(.code)
        } live: {
            Text("Hello, world")
                .slideText(SlideText.displayDemo.color(Theme.accentText))
        }
    }
}
