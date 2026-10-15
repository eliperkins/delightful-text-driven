import Foundation
import Testing
@testable import DelightfulTextDriven

/// Renders chosen slides of the talk, every step, to `NN-S.png` files. Skipped unless `CAPTURE_SLIDES` is set:
///
///     TEST_RUNNER_CAPTURE_SLIDES=60-62,64 TEST_RUNNER_CAPTURE_DIR=/tmp/slides xcodebuild test \
///         -project DelightfulTextDriven.xcodeproj -scheme DelightfulTextDriven \
///         -only-testing:'DelightfulTextDrivenTests/captureSlides()'
///
/// `CAPTURE_DIR` defaults to `SlideCapture` in the temporary directory, and is replaced on every run.
@Test(.enabled(if: ProcessInfo.processInfo.environment["CAPTURE_SLIDES"] != nil))
@MainActor
func captureSlides() throws {
    let environment = ProcessInfo.processInfo.environment
    let slides = try #require(environment["CAPTURE_SLIDES"].map(slideNumbers))
    let folder = environment["CAPTURE_DIR"].map { URL(filePath: $0, directoryHint: .isDirectory) }
        ?? FileManager.default.temporaryDirectory.appending(path: "SlideCapture", directoryHint: .isDirectory)
    try DeckExport(deck: .talk).writeStills(to: folder, slides: slides)
    print("Captured slides \(slides.sorted()) to \(folder.path(percentEncoded: false))")
}

/// Parses `62,63` or `60-63` into 1-based slide numbers.
private func slideNumbers(_ list: String) -> Set<Int> {
    Set(list.split(separator: ",").flatMap { item -> Range<Int> in
        let bounds = item.split(separator: "-").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard let first = bounds.first, let last = bounds.last, first <= last else { return 0..<0 }
        return first..<last + 1
    })
}
