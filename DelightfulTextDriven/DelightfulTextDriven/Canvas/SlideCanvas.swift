import SwiftUI

/// Lays slides out on one fixed 1920×1080 canvas and scales it once to fit, letterboxed on black.
///
/// Every size on a slide is in canvas points, so layout is identical on a laptop, a 1080p projector, and a 4K display.
struct SlideCanvas<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        let size = Theme.Layout.canvas
        GeometryReader { proxy in
            content
                .frame(width: size.width, height: size.height)
                .clipped()
                .scaleEffect(size.fitted(in: proxy.size).width / size.width)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .background(.black)
    }
}

extension CGSize {
    /// The largest size with this aspect ratio that fits inside `bounds`.
    func fitted(in bounds: CGSize) -> CGSize {
        let scale = min(bounds.width / width, bounds.height / height)
        return CGSize(width: width * scale, height: height * scale)
    }
}

#Preview {
    SlidePreview {
        Theme.background
            .overlay {
                Text("\(Int(Theme.Layout.canvas.width)) × \(Int(Theme.Layout.canvas.height))")
                    .slideText(.display)
            }
    }
}
