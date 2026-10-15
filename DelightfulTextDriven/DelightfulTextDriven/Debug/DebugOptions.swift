import SwiftUI

/// Debug-only toggles, set from the Debug menu and saved across launches.
/// Release builds never show the menu, so these stay off.
enum DebugOptions {
    static let themeGalleryKey = "ThemeGallery"
    static let layoutGuidesKey = "ShowsLayoutGuides"
    static let hiddenBuildsKey = "RevealsHiddenBuilds"
}

extension EnvironmentValues {
    /// Draws `Theme.Layout`'s margins, header, content area, and split over every slide.
    @Entry var showsLayoutGuides = false
    /// Shows content that hasn't built in yet as a faint ghost instead of hiding it.
    @Entry var revealsHiddenBuilds = false
}

/// `Theme.Layout` drawn as guides: the safe area inside the margins, header, and bottom,
/// and the content area split into its code and live columns.
struct LayoutGuides: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .strokeBorder(Theme.accent, lineWidth: Theme.Layout.livePaneBorderWidth)
                .padding(.horizontal, Theme.Layout.margin)
                .padding(.top, Theme.Layout.headerTop)
                .padding(.bottom, Theme.Layout.bottom)

            HStack(spacing: Theme.Layout.splitGap) {
                Rectangle()
                    .strokeBorder(Theme.accent, lineWidth: Theme.Layout.livePaneBorderWidth)
                    .frame(width: Theme.Layout.splitLeadingWidth)
                Rectangle()
                    .strokeBorder(Theme.accent, lineWidth: Theme.Layout.livePaneBorderWidth)
            }
            .padding(.horizontal, Theme.Layout.margin)
            .padding(.top, Theme.Layout.contentTop)
            .padding(.bottom, Theme.Layout.bottom)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    SlidePreview {
        Theme.background
            .overlay { LayoutGuides() }
    }
}
