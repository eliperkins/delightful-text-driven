import SwiftUI

/// `apis` take `code` spans.
struct Era: View {
    let year: String
    let os: String
    let apis: [String]

    var body: some View {
        Slide {
            VStack(alignment: .leading, spacing: Theme.Layout.titleSpacing) {
                HStack(alignment: .firstTextBaseline, spacing: Theme.Layout.titleSpacing) {
                    Text(year)
                        .slideText(SlideText.display.color(Theme.accentText))
                    Text(os)
                        .slideText(.subtitle)
                }
                VStack(alignment: .leading) {
                    ForEach(apis, id: \.self) { api in
                        Text(SlideText.emphasized(api))
                            .slideText(.statementCompact)
                    }
                }
            }
            .padding(.top, Theme.Layout.contentTop)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
