import SwiftUI

struct Hello: View {
    @Environment(\.slideStep) private var step

    var body: some View {
        Slide {
            HStack(spacing: Theme.Layout.splitGap) {
                VStack(alignment: .leading, spacing: Theme.Layout.titleSpacing) {
                    Text("👋")
                        .slideText(.wave)
                    name
                        .build(at: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                headshot
            }
            .padding(.top, Theme.Layout.contentTop)
            .padding(.bottom, Theme.Layout.splitBottom)
        }
    }

    @ViewBuilder private var name: some View {
        switch step {
        case ...1:
            Text("Eli Perkins")
                .slideText(.display)
        case 2:
            Text("eliperkins")
                .slideText(.displayMono)
        default:
            Text("eliperkins.com")
                .slideText(.displayMono)
        }
    }

    private var headshot: some View {
        Image(.headshot)
            .resizable()
            .scaledToFill()
            .frame(width: Theme.Layout.headshotSize, height: Theme.Layout.headshotSize)
            .clipShape(.circle)
            .accessibilityLabel("Eli Perkins")
    }
}
