import CoreImage.CIFilterBuiltins
import SwiftUI

/// Dark modules on a light tile, since some scanners can't read an inverted code.
struct QRCode: View {
    let text: String

    var body: some View {
        if let image = Self.image(for: text) {
            Image(decorative: image, scale: 1)
                .interpolation(.none)
                .resizable()
                .frame(width: Theme.Layout.qrCodeSize, height: Theme.Layout.qrCodeSize)
                .padding(Theme.Layout.qrCodeQuietZone)
                .background(Theme.shiftBackground, in: .rect(cornerRadius: Theme.Layout.panelCornerRadius))
        }
    }

    private static func image(for text: String) -> CGImage? {
        let generator = CIFilter.qrCodeGenerator()
        generator.message = Data(text.utf8)
        generator.correctionLevel = "M"
        let colors = CIFilter.falseColor()
        colors.inputImage = generator.outputImage
        colors.color0 = CIColor(color: NSColor(Theme.shiftInk)) ?? .black
        colors.color1 = CIColor(color: NSColor(Theme.shiftBackground)) ?? .white
        guard let modules = colors.outputImage else { return nil }
        // Upscaled here with nearest sampling, so a PDF viewer that smooths images can't blur the modules.
        let scale = Theme.Layout.qrCodeSize / modules.extent.width
        let code = modules.samplingNearest().transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return CIContext().createCGImage(code, from: code.extent)
    }
}

#Preview {
    QRCode(text: Thanks.slidesURL)
        .padding()
}
