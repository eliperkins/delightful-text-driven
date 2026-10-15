import SwiftUI

struct Replay: View {
    var body: some View {
        Slide {
            Grid(horizontalSpacing: Theme.Layout.splitGap, verticalSpacing: Theme.Layout.splitGap) {
                GridRow {
                    tile(SpoilerEffect(style: .statementTile))
                    tile(HighlighterEffect(style: .statementTile))
                }
                GridRow {
                    tile(FocusEffect(style: .statementTile))
                    tile(LyricEffect(style: .statementTile))
                }
            }
            .padding(.top, Theme.Layout.contentTop)
            .padding(.bottom, Theme.Layout.splitBottom)
        }
    }

    private func tile(_ effect: some View) -> some View {
        effect
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SlidePreview(part: .close) {
        Replay()
    }
}
