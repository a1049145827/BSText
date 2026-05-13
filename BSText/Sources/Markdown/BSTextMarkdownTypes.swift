import UIKit

@objc public enum BSTextMarkdownBlockType: Int {
    case paragraph = 0
    case heading1 = 1
    case heading2 = 2
    case heading3 = 3
    case heading4 = 4
    case heading5 = 5
    case heading6 = 6
    case blockquote = 7
    case codeBlock = 8
    case unorderedList = 9
    case orderedList = 10
    case taskList = 11
    case table = 12
    case horizontalRule = 13
}

@objc public enum BSTextMarkdownInlineType: Int {
    case bold = 0
    case italic = 1
    case strikethrough = 2
    case code = 3
    case link = 4
    case image = 5
    case mention = 6
    case hashtag = 7
}

public struct BSTextMarkdownBlock {
    public let type: BSTextMarkdownBlockType
    public let content: String
    public let attributedContent: NSAttributedString?
    public let metadata: [String: Any]
    
    public init(type: BSTextMarkdownBlockType, content: String, attributedContent: NSAttributedString? = nil, metadata: [String: Any] = [:]) {
        self.type = type
        self.content = content
        self.attributedContent = attributedContent
        self.metadata = metadata
    }
}

public struct BSTextMarkdownInline {
    public let type: BSTextMarkdownInlineType
    public let range: NSRange
    public let content: String
    public let metadata: [String: Any]
    
    public init(type: BSTextMarkdownInlineType, range: NSRange, content: String, metadata: [String: Any] = [:]) {
        self.type = type
        self.range = range
        self.content = content
        self.metadata = metadata
    }
}

public protocol BSTextMarkdownParserDelegate: AnyObject {
    func parser(_ parser: BSTextMarkdownParser, didParse blocks: [BSTextMarkdownBlock])
    func parser(_ parser: BSTextMarkdownParser, didFindInline inline: BSTextMarkdownInline, in range: NSRange)
}
