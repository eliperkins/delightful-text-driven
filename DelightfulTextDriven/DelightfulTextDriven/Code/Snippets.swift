import Foundation

enum Snippets {
    /// Reads the caller's file from this checkout, which works because the app only runs on the Mac that built it.
    static func region(_ name: String, file: String = #filePath) -> String {
        let source = (try? String(contentsOfFile: file, encoding: .utf8)) ?? ""
        return region(name, in: source)
    }

    static func region(_ name: String, in source: String) -> String {
        let lines = source.split(separator: "\n", omittingEmptySubsequences: false)
        guard let start = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "// slide: \(name)" }) else {
            return "// Missing slide region \"\(name)\""
        }
        let body = lines[(start + 1)...].prefix { $0.trimmingCharacters(in: .whitespaces) != "// slide: end" }
        let indent = body
            .filter { !$0.allSatisfy(\.isWhitespace) }
            .map { $0.prefix(while: { $0 == " " }).count }
            .min() ?? 0
        // Slides indent with 2 spaces, like the mockups, so lines fit the code panel.
        return body.map { line in
            let trimmed = line.dropFirst(min(indent, line.count))
            let leading = trimmed.prefix { $0 == " " }.count
            return String(repeating: " ", count: leading / 2) + trimmed.dropFirst(leading)
        }
        .joined(separator: "\n")
    }
}
