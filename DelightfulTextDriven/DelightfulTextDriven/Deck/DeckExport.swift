import AppKit
import SwiftUI

@MainActor
struct DeckExport {
    let deck: Deck

    /// Blurs and shaders rasterize even in a PDF, so this matches a Retina or 4K display.
    private static let scale: CGFloat = 2

    struct Frame {
        let slide: Int
        let step: Int
        let view: AnyView
    }

    var frames: [Frame] {
        deck.slides.enumerated().flatMap { index, slide in
            (0..<slide.steps).map { step in
                Frame(
                    slide: index,
                    step: step,
                    view: AnyView(
                        slide.rendered(step: step)
                            .frame(width: Theme.Layout.canvas.width, height: Theme.Layout.canvas.height)
                            .clipped()
                            .environment(\.slideRenderMode, .thumbnail)
                    )
                )
            }
        }
    }

    /// Replaces `folder`, so no file from an older export stays next to the new ones.
    /// - Parameter slides: 1-based slide numbers to write, as in the file names; `nil` writes every slide.
    func writeStills(to folder: URL, slides: Set<Int>? = nil) throws {
        if FileManager.default.fileExists(atPath: folder.path(percentEncoded: false)) {
            try FileManager.default.removeItem(at: folder)
        }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false)
        let digits = String(deck.slides.count).count
        for frame in frames where slides?.contains(frame.slide + 1) ?? true {
            let renderer = ImageRenderer(content: frame.view)
            renderer.scale = Self.scale
            guard let image = renderer.cgImage,
                  let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])
            else { throw ExportError.renderFailed(slide: frame.slide + 1) }
            let name = String(format: "%0\(digits)d-%d.png", frame.slide + 1, frame.step + 1)
            try png.write(to: folder.appending(path: name))
        }
    }

    func writePDF(to url: URL) throws {
        var box = CGRect(origin: .zero, size: Theme.Layout.canvas)
        guard let context = CGContext(url as CFURL, mediaBox: &box, nil) else {
            throw ExportError.cannotCreate(url)
        }
        for frame in frames {
            ImageRenderer(content: frame.view).render(rasterizationScale: Self.scale) { _, draw in
                context.beginPDFPage(nil)
                draw(context)
                context.endPDFPage()
            }
        }
        context.closePDF()
    }

    enum ExportError: LocalizedError {
        case renderFailed(slide: Int)
        case cannotCreate(URL)

        var errorDescription: String? {
            switch self {
            case .renderFailed(let slide): "Slide \(slide) did not render."
            case .cannotCreate(let url): "Could not create \(url.lastPathComponent)."
            }
        }
    }
}
