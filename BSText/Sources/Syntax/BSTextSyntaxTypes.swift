import UIKit

@objc public enum BSTextSyntaxTokenType: Int {
    case keyword = 0
    case string = 1
    case comment = 2
    case number = 3
    case function = 4
    case variable = 5
    case type = 6
    case `operator` = 7
    case punctuation = 8
    case attribute = 9
    case preprocessor = 10
    case invalid = 11
}

@objc public enum BSTextSyntaxLanguage: Int {
    case swift = 0
    case objectiveC = 1
    case python = 2
    case javascript = 3
    case typescript = 4
    case ruby = 5
    case go = 6
    case rust = 7
    case kotlin = 8
    case java = 9
    case c = 10
    case cpp = 11
    case markdown = 12
    case json = 13
    case yaml = 14
    case xml = 15
    case html = 16
    case css = 17
}

public struct BSTextSyntaxToken {
    public let type: BSTextSyntaxTokenType
    public let range: NSRange
    public let content: String
    
    public init(type: BSTextSyntaxTokenType, range: NSRange, content: String) {
        self.type = type
        self.range = range
        self.content = content
    }
}

public struct BSTextSyntaxTheme {
    public var keywordColor: UIColor = .purple
    public var stringColor: UIColor = .systemGreen
    public var commentColor: UIColor = .systemGray
    public var numberColor: UIColor = .systemOrange
    public var functionColor: UIColor = .systemBlue
    public var variableColor: UIColor = .label
    public var typeColor: UIColor = .systemTeal
    public var operatorColor: UIColor = .systemRed
    public var punctuationColor: UIColor = .systemGray
    public var attributeColor: UIColor = .systemPink
    public var preprocessorColor: UIColor = .systemIndigo
    public var invalidColor: UIColor = .systemRed
    
    public var font: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    public var boldFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .bold)
    
    public static var `default`: BSTextSyntaxTheme {
        return BSTextSyntaxTheme()
    }
    
    public static var dark: BSTextSyntaxTheme {
        var theme = BSTextSyntaxTheme()
        theme.keywordColor = .systemPurple
        theme.stringColor = .systemGreen
        theme.commentColor = .systemGray4
        theme.numberColor = .systemOrange
        theme.functionColor = .systemBlue
        theme.variableColor = .white
        theme.typeColor = .systemTeal
        theme.operatorColor = .systemRed
        theme.punctuationColor = .systemGray4
        theme.attributeColor = .systemPink
        theme.preprocessorColor = .systemIndigo
        theme.invalidColor = .systemRed
        return theme
    }
}

public protocol BSTextSyntaxParserDelegate: AnyObject {
    func parser(_ parser: BSTextSyntaxParser, didFindTokens tokens: [BSTextSyntaxToken])
}
