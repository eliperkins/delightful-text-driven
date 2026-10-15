import SwiftUI

/// The deck's design tokens, from `app-design.md` → "Visual system".
///
/// Slides read sizes, positions, and colors from here and never hard-code them.
enum Theme {
    /// Positions and sizes in canvas points on the fixed 1920×1080 canvas.
    enum Layout {
        static let canvas = CGSize(width: 1920, height: 1080)
        /// Left and right margin on every slide.
        static let margin: CGFloat = 120
        /// Distance from the top edge to the slide header.
        static let headerTop: CGFloat = 72
        /// Top of the content area on split and runs slides.
        static let contentTop: CGFloat = 190
        /// Distance from the bottom edge to title and section stacks.
        static let bottom: CGFloat = 110
        /// The code side's share of a split; the live pane gets the rest.
        static let splitFraction: CGFloat = 0.58
        static let splitGap: CGFloat = 48
        /// The width between the left and right margins.
        static var contentWidth: CGFloat { canvas.width - margin * 2 }
        /// The code side's width in a split.
        static var splitLeadingWidth: CGFloat { (contentWidth - splitGap) * splitFraction }
        static let splitBottom: CGFloat = 90
        static let panelCornerRadius: CGFloat = 14
        static let codePanelPadding = EdgeInsets(top: 40, leading: 48, bottom: 40, trailing: 48)
        static let livePaneBorderWidth: CGFloat = 3
        static let livePaneSpacing: CGFloat = 44
        static let livePanePadding = EdgeInsets(top: 90, leading: 44, bottom: 90, trailing: 44)
        static let liveTagInset = EdgeInsets(top: 26, leading: 30, bottom: 0, trailing: 0)
        static let liveTagSpacing: CGFloat = 12
        static let liveTagPadding = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 20)
        static let liveTagBorderWidth: CGFloat = 2
        static let liveDotSize: CGFloat = 16
        static let titleTrailing: CGFloat = 200
        static let titleSpacing: CGFloat = 30
        static let statementTrailing: CGFloat = 220
        static let sectionSpacing: CGFloat = 26
        static let sectionMaxWidth: CGFloat = 1150
        /// The section numeral's distance from the trailing edge.
        static let numeralTrailing: CGFloat = 10
        /// How far the section numeral bleeds below the bottom edge.
        static let numeralBleed: CGFloat = 170
        static let runsLineSpacing: CGFloat = 90
        static let runLabelGap: CGFloat = 12
        static let runInset: CGFloat = 4
        static let diagramStrokeWidth: CGFloat = 3
        static let glyphStrokeWidth: CGFloat = 2
        static let diagramDash: [CGFloat] = [12, 8]
        static let legendSpacing: CGFloat = 50
        static let legendSwatchSpacing: CGFloat = 14
        static let legendSwatchWidth: CGFloat = 44
        static let demoButtonPadding = EdgeInsets(top: 18, leading: 40, bottom: 18, trailing: 40)
        static let transcriptTop: CGFloat = 170
        static let transcriptViewport: CGFloat = 640
        static let transcriptDemoViewport: CGFloat = 420
        static let transcriptEdgeFade: CGFloat = 120
        static let frameTileHeight: CGFloat = 150
        static let frameTilePadding: CGFloat = 20
        static let frameTileSpacing: CGFloat = 16
        static let lineMarkerSize: CGFloat = 36
        static let lineMarkerGutter: CGFloat = 56
        static let pixelZoomHeight: CGFloat = 170
        static let pixelZoomBleed: CGFloat = 4
        static let transcriptChromeSpacing: CGFloat = 36
        static let transcriptPillPadding: CGFloat = 10
        static let transcriptBleed: CGFloat = 20
        static let transcriptPillCornerRadius: CGFloat = 12
        /// The podcast artwork in the transcript slide's header.
        static let attributionArtwork: CGFloat = 48
        static let attributionSpacing: CGFloat = 20
        static let attributionCornerRadius: CGFloat = 8
        static let missingClipSpacing: CGFloat = 32
        static let tuningControlsWidth: CGFloat = 340
        static let tuningControlsSpacing: CGFloat = 36
        static let comparisonSpacing: CGFloat = 24
        static let contactColumnSpacing: CGFloat = 32
        static let contactRowSpacing: CGFloat = 12
        static let contactIconSize: CGFloat = 44
        static let qrCodeSize: CGFloat = 400
        /// The light margin a scanner needs around the code.
        static let qrCodeQuietZone: CGFloat = 32
        static let resourceSpacing: CGFloat = 56
        static let resourceLineSpacing: CGFloat = 8
        static let scorecardColumnSpacing: CGFloat = 40
        static let scorecardRowSpacing: CGFloat = 44
        static let headshotSize: CGFloat = 560
        static let avatarSize: CGFloat = 96
        static let avatarSpacing: CGFloat = 24
        /// The title card groups its title with the subtitle, then sets the byline apart.
        static let subtitleSpacing: CGFloat = 8
        static let bylineSpacing: CGFloat = 72
        static let logoHeroHeight: CGFloat = 320
        static let awardSpacing: CGFloat = 120
        static let laurelSpacing: CGFloat = 16
        /// An iPhone screenshot's width, and its height less the status bar.
        static let screenSize = CGSize(width: 360, height: 724)
        /// Recordings have no header, so they fill the canvas height inside this inset.
        static let recordingInset: CGFloat = 40
        static let requirementSpacing: CGFloat = 32
    }

    /// For demo content only: slides and builds always hard-cut.
    enum Motion {
        static let reveal = Animation.easeOut(duration: 0.35)
    }

    // Color roles for the Lake, tuned palette.
    static let background = Color(hex: 0x1B1F27)
    static let ink = Color(hex: 0xF4EEE2)
    static let ink2 = Color(hex: 0xD6BF9C)
    static let muted = Color(hex: 0xA7B4C2)
    /// Fills, never text.
    static let accent = Color(hex: 0x3399CC)
    static let accentText = Color(hex: 0x86C8EC)
    static let deep = Color(hex: 0x2272A6)
    static let onDeep = Color(hex: 0xF4EEE2)
    /// Upcoming words in transcripts.
    static let future = Color(hex: 0x8A97A3)
    static let live = Color(hex: 0x6CC28A)
    static let line = Color(hex: 0x56637A)
    static let line2 = Color(hex: 0x7A8A9C)
    /// Xcode's runtime issue badge. Icons only: too dark for text on `background`.
    static let runtimeIssue = Color(hex: 0x6361F2)
    /// The section card's shifted ground and its ink.
    static let shiftBackground = Color(hex: 0xF4EEE2)
    static let shiftInk = Color(hex: 0x2D3A53)
    static let shiftAccent = Color(hex: 0x456180)
    static let codeBackground = Color(hex: 0x13161C)
    static let dimmedCodeOpacity = 0.35
    /// Code colors follow Xcode's split: purple for the SDK (tints of `runtimeIssue`), green for this project (from `live`).
    static let codeKeyword = Color(hex: 0xF28DB7)
    static let codeNumber = Color(hex: 0xF0C05A)
    static let codeSystemType = Color(hex: 0xB9B8F9)
    static let codeSystemMember = Color(hex: 0x9997F6)
    static let codeProjectType = Color(hex: 0xA5DAB7)
    static let codeProjectMember = live
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
