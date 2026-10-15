import SwiftUI

struct Thanks: View {
    static let contacts = [
        (Image(.bluesky), "Bluesky", "@eliperkins.com"),
        (Image(.mastodon), "Mastodon", "@eliperkins@mastodon.online"),
        (Image(.gitHub), "GitHub", "github.com/eliperkins"),
        (Image(systemName: "globe"), "Web", "eliperkins.com"),
        (Image(systemName: "envelope.fill"), "Email", "eli.j.perkins@gmail.com"),
    ]

    static let slidesURL = "https://eliperkins.com/talks/swiftleeds-2026.pdf"

    @Environment(\.slideRenderMode) private var renderMode
    @State private var phase = 0.0

    var body: some View {
        Slide {
            HStack(alignment: .bottom) {
                contactCard
                Spacer()
                VStack(alignment: .trailing, spacing: Theme.Layout.liveTagSpacing) {
                    QRCode(text: Self.slidesURL)
                    Text(Self.slidesURL.replacing("https://", with: ""))
                        .slideText(.caption)
                        .fixedSize()
                }
            }
            .padding(.bottom, Theme.Layout.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.titleSpacing) {
            title
            Grid(
                alignment: .leading,
                horizontalSpacing: Theme.Layout.contactColumnSpacing,
                verticalSpacing: Theme.Layout.contactRowSpacing
            ) {
                ForEach(Self.contacts, id: \.1) { icon, service, handle in
                    GridRow {
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: Theme.Layout.contactIconSize, height: Theme.Layout.contactIconSize)
                            .foregroundStyle(Theme.muted)
                            .accessibilityLabel(service)
                        Text(handle)
                            .slideText(.subtitleCompact)
                    }
                }
            }
        }
    }

    @ViewBuilder private var title: some View {
        if renderMode == .live {
            Text("Thank you")
                .textRenderer(Water(phase: phase))
                .slideText(.display)
                .onAppear {
                    withAnimation(.linear(duration: Water.period).repeatForever(autoreverses: false)) {
                        phase = Water.period
                    }
                }
        } else {
            Text("Thank you")
                .slideText(.display)
        }
    }
}

struct Water: TextRenderer {
    static let period = 2 * Double.pi

    var phase: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let water = ShaderLibrary.water(.float(phase))
        ctx.addFilter(.distortionShader(water, maxSampleOffset: CGSize(width: 8, height: 8)))
        for line in layout {
            ctx.draw(line)
        }
    }
}
