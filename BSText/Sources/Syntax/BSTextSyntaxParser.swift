import UIKit

@objcMembers
open class BSTextSyntaxParser: NSObject {
    
    public weak var delegate: BSTextSyntaxParserDelegate?
    
    public var language: BSTextSyntaxLanguage = .swift
    
    public var theme: BSTextSyntaxTheme = .default
    
    private let keywords: [BSTextSyntaxLanguage: Set<String>] = [
        .swift: [
            "class", "struct", "enum", "protocol", "extension", "func", "var", "let",
            "if", "else", "switch", "case", "default", "for", "while", "repeat",
            "do", "try", "catch", "throw", "return", "break", "continue", "fallthrough",
            "guard", "in", "where", "as", "is", "self", "super", "typealias",
            "associatedtype", "init", "deinit", "subscript", "operator", "precedencegroup",
            "import", "export", "internal", "public", "private", "fileprivate", "open",
            "final", "dynamic", "lazy", "weak", "unowned", "owned", "convenience",
            "required", "override", "static", "class", "mutating", "nonmutating",
            "indirect", "case", "indirect", "optional", "Protocol", "Any", "Self",
            "true", "false", "nil", "Type", "throws", "rethrows", "async", "await"
        ],
        .javascript: [
            "var", "let", "const", "function", "class", "extends", "super", "return",
            "if", "else", "switch", "case", "default", "for", "while", "do", "while",
            "break", "continue", "throw", "try", "catch", "finally", "new", "this",
            "typeof", "instanceof", "in", "of", "with", "delete", "void", "instanceof",
            "true", "false", "null", "undefined", "NaN", "Infinity", "async", "await",
            "import", "export", "from", "as", "static", "get", "set", "yield", "async"
        ],
        .python: [
            "and", "as", "assert", "break", "class", "continue", "def", "del",
            "elif", "else", "except", "False", "finally", "for", "from", "global",
            "if", "import", "in", "is", "lambda", "None", "nonlocal", "not", "or",
            "pass", "raise", "return", "True", "try", "while", "with", "yield",
            "async", "await"
        ],
        .objectiveC: [
            "@interface", "@implementation", "@end", "@protocol", "@property",
            "@synthesize", "@dynamic", "@class", "@selector", "@encode", "@throw",
            "@try", "@catch", "@finally", "@autoreleasepool", "self", "super",
            "nil", "YES", "NO", "id", "Class", "SEL", "IMP", "BOOL", "YES", "NO",
            "if", "else", "for", "while", "do", "switch", "case", "default",
            "break", "continue", "return", "goto", "typedef", "struct", "union",
            "enum", "const", "static", "extern", "inline", "auto", "register",
            "volatile", "restrict", "sizeof", "typeof", "__block", "__weak", "__strong"
        ],
        .java: [
            "public", "private", "protected", "default", "static", "final", "abstract",
            "synchronized", "volatile", "native", "strictfp", "transient", "interface",
            "class", "extends", "implements", "package", "import", "new", "this", "super",
            "return", "if", "else", "switch", "case", "default", "for", "while", "do",
            "break", "continue", "throw", "throws", "try", "catch", "finally",
            "true", "false", "null", "void", "boolean", "byte", "char", "short",
            "int", "long", "float", "double"
        ],
        .cpp: [
            "class", "struct", "union", "enum", "public", "private", "protected",
            "virtual", "override", "final", "static", "const", "volatile", "mutable",
            "inline", "extern", "typedef", "namespace", "using", "template",
            "typename", "decltype", "auto", "if", "else", "switch", "case", "default",
            "for", "while", "do", "break", "continue", "return", "goto", "throw",
            "try", "catch", "constexpr", "nullptr", "true", "false", "delete", "new"
        ],
        .go: [
            "package", "import", "func", "var", "type", "const", "struct", "interface",
            "map", "slice", "chan", "select", "case", "default", "for", "if", "else",
            "switch", "return", "break", "continue", "go", "defer", "panic", "recover",
            "true", "false", "nil"
        ],
        .ruby: [
            "def", "class", "module", "end", "if", "else", "elsif", "unless", "case",
            "when", "then", "for", "while", "until", "loop", "break", "next", "redo",
            "retry", "return", "yield", "lambda", "proc", "block", "and", "or", "not",
            "true", "false", "nil", "self", "super", "require", "include", "extend",
            "attr_accessor", "attr_reader", "attr_writer", "private", "protected", "public"
        ],
        .rust: [
            "fn", "let", "mut", "const", "static", "struct", "enum", "impl", "trait",
            "pub", "use", "mod", "where", "for", "loop", "while", "if", "else", "match",
            "return", "break", "continue", "self", "Self", "super", "crate", "self",
            "true", "false", "Some", "None", "Ok", "Err", "async", "await", "move",
            "ref", "in", "as", "dyn", "unsafe", "abstract", "final", "override",
            "virtual", "extern", "type", "typeof"
        ],
        .kotlin: [
            "package", "import", "class", "interface", "fun", "var", "val", "typealias",
            "object", "companion", "enum", "sealed", "data", "inner", "open", "final",
            "abstract", "private", "protected", "public", "internal", "override",
            "super", "this", "null", "true", "false", "if", "else", "when", "for",
            "while", "do", "return", "break", "continue", "throw", "try", "catch",
            "finally", "async", "await", "suspend", "init", "constructor"
        ],
        .typescript: [
            "var", "let", "const", "function", "class", "extends", "implements",
            "interface", "type", "enum", "namespace", "module", "import", "export",
            "from", "as", "static", "public", "private", "protected", "abstract",
            "readonly", "override", "virtual", "async", "await", "yield", "get",
            "set", "new", "this", "super", "return", "if", "else", "switch", "case",
            "default", "for", "while", "do", "break", "continue", "throw", "try",
            "catch", "finally", "true", "false", "null", "undefined", "never", "any",
            "unknown", "void", "object", "string", "number", "boolean", "symbol",
            "bigint", "Array", "Map", "Set", "Promise"
        ],
        .json: [
            "true", "false", "null"
        ],
        .markdown: [],
        .xml: [],
        .html: [],
        .css: [
            "background", "color", "font", "margin", "padding", "border", "width",
            "height", "display", "position", "float", "clear", "overflow", "z-index",
            "top", "right", "bottom", "left", "text-align", "text-decoration",
            "text-transform", "line-height", "letter-spacing", "word-spacing",
            "white-space", "list-style", "cursor", "pointer-events", "opacity",
            "filter", "transition", "animation", "transform", "flex", "grid",
            "align-items", "justify-content", "flex-direction", "flex-wrap",
            "grid-template", "media", "import", "export", "charset", "!important"
        ],
        .yaml: []
    ]
    
    public override init() {
        super.init()
    }
    
    public init(language: BSTextSyntaxLanguage) {
        self.language = language
        super.init()
    }
    
    open func parse(_ text: String) -> NSAttributedString {
        let tokens = parseTokens(text)
        delegate?.parser(self, didFindTokens: tokens)
        
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttributes([.font: theme.font], range: NSRange(location: 0, length: text.count))
        
        for token in tokens {
            applyTokenAttributes(attributed, token: token)
        }
        
        return attributed
    }
    
    private func parseTokens(_ text: String) -> [BSTextSyntaxToken] {
        var tokens: [BSTextSyntaxToken] = []
        
        let patterns = getPatterns()
        let nsText = text as NSString
        
        for (pattern, tokenType) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
                
                for match in matches {
                    let range = match.range
                    let content = nsText.substring(with: range)
                    tokens.append(BSTextSyntaxToken(type: tokenType, range: range, content: content))
                }
            } catch {
                continue
            }
        }
        
        return tokens.sorted { $0.range.location < $1.range.location }
    }
    
    private func getPatterns() -> [(String, BSTextSyntaxTokenType)] {
        var patterns: [(String, BSTextSyntaxTokenType)] = []
        
        patterns.append(("(?s)/\\*.*?\\*/", .comment))
        patterns.append(("//.*$", .comment))
        patterns.append(("#.*$", .comment))
        patterns.append(("\"\"\"(?s).*?\"\"\"", .string))
        patterns.append(("'''(?s).*?'''", .string))
        patterns.append(("\"(?:\\\\.|[^\"\\\\])*\"", .string))
        patterns.append(("'(?:\\\\.|[^'\\\\])*'", .string))
        patterns.append(("\\b(\\d+\\.?\\d*)\\b", .number))
        
        if let langKeywords = keywords[language] {
            let keywordPattern = "\\b(" + langKeywords.joined(separator: "|") + ")\\b"
            patterns.append((keywordPattern, .keyword))
        }
        
        patterns.append(("\\b([A-Z][a-zA-Z0-9_]*)\\b", .type))
        patterns.append(("\\b([a-z_][a-zA-Z0-9_]*)\\s*(?=\\()", .function))
        
        return patterns
    }
    
    private func applyTokenAttributes(_ attributed: NSMutableAttributedString, token: BSTextSyntaxToken) {
        switch token.type {
        case .keyword:
            attributed.addAttributes([
                .foregroundColor: theme.keywordColor,
                .font: theme.boldFont
            ], range: token.range)
            
        case .string:
            attributed.addAttributes([
                .foregroundColor: theme.stringColor,
                .font: theme.font
            ], range: token.range)
            
        case .comment:
            attributed.addAttributes([
                .foregroundColor: theme.commentColor,
                .font: theme.font
            ], range: token.range)
            
        case .number:
            attributed.addAttributes([
                .foregroundColor: theme.numberColor,
                .font: theme.font
            ], range: token.range)
            
        case .function:
            attributed.addAttributes([
                .foregroundColor: theme.functionColor,
                .font: theme.boldFont
            ], range: token.range)
            
        case .variable:
            attributed.addAttributes([
                .foregroundColor: theme.variableColor,
                .font: theme.font
            ], range: token.range)
            
        case .type:
            attributed.addAttributes([
                .foregroundColor: theme.typeColor,
                .font: theme.boldFont
            ], range: token.range)
            
        case .operator:
            attributed.addAttributes([
                .foregroundColor: theme.operatorColor,
                .font: theme.font
            ], range: token.range)
            
        case .punctuation:
            attributed.addAttributes([
                .foregroundColor: theme.punctuationColor,
                .font: theme.font
            ], range: token.range)
            
        case .attribute:
            attributed.addAttributes([
                .foregroundColor: theme.attributeColor,
                .font: theme.font
            ], range: token.range)
            
        case .preprocessor:
            attributed.addAttributes([
                .foregroundColor: theme.preprocessorColor,
                .font: theme.font
            ], range: token.range)
            
        case .invalid:
            attributed.addAttributes([
                .foregroundColor: theme.invalidColor,
                .font: theme.font
            ], range: token.range)
        }
    }
}

public extension BSTextSyntaxParser {
    static func parse(_ text: String, language: BSTextSyntaxLanguage = .swift) -> NSAttributedString {
        let parser = BSTextSyntaxParser(language: language)
        return parser.parse(text)
    }
}
