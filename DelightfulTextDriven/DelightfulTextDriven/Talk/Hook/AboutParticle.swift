import SwiftUI

struct AboutParticle: View {
    var showsAwards = false

    var body: some View {
        Slide {
            Image(.particleLogotype)
                .resizable()
                .scaledToFit()
                .frame(height: Theme.Layout.logoHeroHeight)
                .foregroundStyle(Theme.ink)
                .accessibilityLabel("Particle")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    if showsAwards {
                        HStack(spacing: Theme.Layout.awardSpacing) {
                            Award("App of\nthe Day")
                            Award("Editors’\nChoice")
                        }
                        .padding(.bottom, Theme.Layout.bottom)
                    }
                }
        }
    }
}

/// An App Store award: its name between the SF Symbols laurels.
private struct Award: View {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        HStack(spacing: Theme.Layout.laurelSpacing) {
            Image(systemName: "laurel.leading")
            Text(name)
                .multilineTextAlignment(.center)
                .fixedSize()
            Image(systemName: "laurel.trailing")
        }
        .imageScale(.large)
        .slideText(.award)
    }
}

#Preview {
    SlidePreview {
        AboutParticle(showsAwards: true)
    }
}
