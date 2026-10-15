import SwiftUI

struct Recording: View {
    let name: String
    let aspectRatio: CGFloat

    @Environment(\.slideRenderMode) private var renderMode

    var body: some View {
        Slide {
            Group {
                if let url = Bundle.main.url(forResource: name, withExtension: "mp4") {
                    video(url)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .clipShape(.rect(cornerRadius: Theme.Layout.panelCornerRadius))
                } else {
                    Text("Add `\(name).mp4` to `Talk/Hook/Recordings/`.")
                        .slideText(.meta)
                }
            }
            .padding(.vertical, Theme.Layout.recordingInset)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// `ImageRenderer` can't draw the player's `NSView`, so thumbnails and exports show a poster frame.
    @ViewBuilder private func video(_ url: URL) -> some View {
        if renderMode == .live {
            LoopingVideo(url: url)
        } else if let poster = Bundle.main.url(forResource: "\(name)-poster", withExtension: "jpg").flatMap(NSImage.init(contentsOf:)) {
            Image(nsImage: poster)
                .resizable()
        }
    }
}
