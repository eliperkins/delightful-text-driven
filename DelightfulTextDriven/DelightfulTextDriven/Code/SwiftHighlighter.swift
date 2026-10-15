import SwiftIDEUtils
import SwiftParser
import SwiftSyntax
import SwiftUI

/// Colors slide code like Xcode: SDK names in purple, this project's names in green.
/// Xcode knows where a name is declared from its index; slides only have syntax, so project names are listed here.
enum SwiftHighlighter {
    enum Role {
        case keyword, number, string, comment
        case systemType, systemMember, projectType, projectMember

        var color: Color {
            switch self {
            case .keyword: Theme.codeKeyword
            case .number: Theme.codeNumber
            case .string: Theme.ink2
            case .comment: Theme.muted
            case .systemType: Theme.codeSystemType
            case .systemMember: Theme.codeSystemMember
            case .projectType: Theme.codeProjectType
            case .projectMember: Theme.codeProjectMember
            }
        }
    }

    static let projectTypes: Set<String> = [
        "Base", "Counted", "DrawCounter", "Emphasis", "Highlight", "HighlightStyle", "Highlighter", "LineMarker",
        "LineTracker", "Passthrough", "Spoiler", "StateLines", "Strikethrough", "Striped", "Theme",
        "TrackedLines", "TranscriptRenderer", "Wave", "WordTime",
    ]

    /// Properties and methods of this project's types, whether reached with `self.`, a dot, or bare.
    static let projectMembers: Set<String> = [
        "accentText", "base", "blur", "content", "counter", "currentLine", "duration", "elapsed", "fade", "frameTileHeight",
        "glyphTime", "hiddenBlur", "increment", "ink", "ink2", "isPaused", "lineY", "onDeep", "phase", "player", "progress",
        "range", "revealed", "rise", "scrubTime", "sentence", "spring", "stagger", "tick", "time", "tracker",
        "transcript", "transcriptDemoViewport", "upcoming",
    ]

    /// Cases written as `.name` with no base, like `.spotlight`. `.blur` stays the SDK's filter.
    static let projectCases: Set<String> = ["deepPill", "spotlight"]

    static func highlight(_ code: String) -> AttributedString {
        var text = AttributedString(code)
        for (range, role) in roles(in: code) {
            guard let range = Range(range, in: text) else { continue }
            text[range].foregroundColor = role.color
        }
        return text
    }

    static func roles(in code: String) -> [(range: Range<String.Index>, role: Role)] {
        let utf8 = code.utf8
        func range(_ lower: AbsolutePosition, _ upper: AbsolutePosition) -> Range<String.Index> {
            utf8.index(utf8.startIndex, offsetBy: lower.utf8Offset)..<utf8.index(utf8.startIndex, offsetBy: upper.utf8Offset)
        }
        let tree = Parser.parse(source: code)
        let locals = localNames(in: tree)
        let comments = tree.classifications.compactMap { classified -> (Range<String.Index>, Role)? in
            switch classified.kind {
            case .lineComment, .blockComment, .docLineComment, .docBlockComment:
                (range(classified.range.lowerBound, classified.range.upperBound), .comment)
            default: nil
            }
        }
        let tokens = tree.tokens(viewMode: .sourceAccurate).compactMap { token -> (Range<String.Index>, Role)? in
            guard let role = role(of: token, locals: locals) else { return nil }
            return (range(token.positionAfterSkippingLeadingTrivia, token.endPositionBeforeTrailingTrivia), role)
        }
        return (comments + tokens)
            .sorted { $0.0.lowerBound < $1.0.lowerBound }
            .map { (range: $0.0, role: $0.1) }
    }

    /// Names the snippet declares itself, like `guard let progress`, which shadow project members of the same name.
    private static func localNames(in tree: SourceFileSyntax) -> Set<String> {
        Set(tree.tokens(viewMode: .sourceAccurate).compactMap { token -> String? in
            guard case .identifier(let name) = token.tokenKind, let parent = token.parent else { return nil }
            if parent.is(ClosureShorthandParameterSyntax.self) {
                return name
            }
            // A computed property, like `var time: TimeInterval { … }`, is a member, not a local.
            if parent.is(IdentifierPatternSyntax.self) {
                let binding = parent.parent?.as(PatternBindingSyntax.self)
                return binding?.accessorBlock == nil ? name : nil
            }
            if let parameter = parent.as(FunctionParameterSyntax.self), (parameter.secondName ?? parameter.firstName).id == token.id {
                return name
            }
            return nil
        })
    }

    private static func role(of token: TokenSyntax, locals: Set<String>) -> Role? {
        if let labeled = token.parent?.as(LabeledExprSyntax.self), labeled.label?.id == token.id {
            return labelRole(in: labeled)
        }
        if isAttributeOrMacro(token) { return .keyword }
        switch token.tokenKind {
        case .keyword: return .keyword
        case .integerLiteral, .floatLiteral: return .number
        case .stringSegment, .stringQuote, .multilineStringQuote: return .string
        case .identifier(let name): return identifierRole(of: token, name: name, locals: locals)
        default: return nil
        }
    }

    private static func identifierRole(of token: TokenSyntax, name: String, locals: Set<String>) -> Role? {
        guard let parent = token.parent else { return nil }
        if parent.is(StructDeclSyntax.self) || parent.is(ClassDeclSyntax.self) || parent.is(EnumDeclSyntax.self)
            || parent.is(ProtocolDeclSyntax.self) || parent.is(GenericParameterSyntax.self) {
            return .projectType
        }
        if name.first?.isUppercase == true {
            return typeRole(name)
        }
        guard let reference = parent.as(DeclReferenceExprSyntax.self) else { return nil }
        if let access = reference.parent?.as(MemberAccessExprSyntax.self), access.declName.id == reference.id {
            return memberRole(name, hasBase: access.base != nil)
        }
        if let call = reference.parent?.as(FunctionCallExprSyntax.self), call.calledExpression.id == reference.id {
            return memberRole(name, hasBase: true)
        }
        return projectMembers.contains(name) && !locals.contains(name) ? .projectMember : nil
    }

    /// An argument label takes the color of the function it belongs to, like `at:` in `.progress(at:)`.
    private static func labelRole(in labeled: LabeledExprSyntax) -> Role {
        let callee = labeled.parent?.parent?.as(FunctionCallExprSyntax.self)?.calledExpression
        if let reference = callee?.as(DeclReferenceExprSyntax.self) {
            let name = reference.baseName.text
            return name.first?.isUppercase == true
                ? memberRole(forType: name)
                : memberRole(name, hasBase: true)
        }
        if let access = callee?.as(MemberAccessExprSyntax.self) {
            return memberRole(access.declName.baseName.text, hasBase: access.base != nil)
        }
        return .systemMember
    }

    private static func typeRole(_ name: String) -> Role {
        projectTypes.contains(name) ? .projectType : .systemType
    }

    private static func memberRole(forType name: String) -> Role {
        projectTypes.contains(name) ? .projectMember : .systemMember
    }

    private static func memberRole(_ name: String, hasBase: Bool) -> Role {
        if name.first?.isUppercase == true { return typeRole(name) }
        return (hasBase ? projectMembers : projectCases).contains(name) ? .projectMember : .systemMember
    }

    /// `@Test` and `#Preview` read as keywords, like Xcode's attributes.
    private static func isAttributeOrMacro(_ token: TokenSyntax) -> Bool {
        var node: Syntax? = token.parent
        for _ in 0..<2 {
            guard let current = node else { return false }
            if current.is(AttributeSyntax.self) || current.is(MacroExpansionExprSyntax.self) || current.is(MacroExpansionDeclSyntax.self) {
                return token.tokenKind != .leftParen && token.tokenKind != .rightParen
            }
            node = current.parent
        }
        return false
    }
}
