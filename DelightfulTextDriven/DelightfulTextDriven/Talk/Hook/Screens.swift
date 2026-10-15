import SwiftUI

struct Screens: View {
    var names = ["screen-books", "screen-stocks", "screen-particle", "screen-music"]
    /// Crops the status bar off the top. Otherwise each screenshot shows whole, scaled to fit.
    var cropsStatusBar = true

    var body: some View {
        HStack(spacing: Theme.Layout.splitGap) {
            ForEach(names, id: \.self, content: screen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Theme.Layout.margin)
        .padding(.vertical, cropsStatusBar ? 0 : Theme.Layout.bottom)
        .background(Theme.background)
    }

    @ViewBuilder private func screen(_ name: String) -> some View {
        if let image = Bundle.main.url(forResource: name, withExtension: "jpg").flatMap(NSImage.init(contentsOf:)) {
            if cropsStatusBar {
                // Fills the width and pins to the bottom, so the status bar crops off the top.
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Theme.Layout.screenSize.width, height: Theme.Layout.screenSize.height, alignment: .bottom)
                    .clipShape(.rect(cornerRadius: Theme.Layout.panelCornerRadius))
                    .accessibilityHidden(true)
            } else {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: Theme.Layout.panelCornerRadius))
                    .accessibilityHidden(true)
            }
        } else {
            Text("Add `\(name).jpg` to `Talk/Hook/Screens/`.")
                .slideText(.meta)
                .frame(width: Theme.Layout.screenSize.width, height: Theme.Layout.screenSize.height)
        }
    }
}

#Preview {
    SlidePreview {
        Screens()
    }
}
