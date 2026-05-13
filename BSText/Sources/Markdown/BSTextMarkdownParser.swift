import UIKit

@objcMembers
open class BSTextMarkdownParser: NSObject {
    
    public weak var delegate: BSTextMarkdownParserDelegate?
    
    public var defaultFont: UIFont = .systemFont(ofSize: 17)
    
    public var headingFonts: [BSTextMarkdownBlockType: UIFont] = [
        .heading1: .boldSystemFont(ofSize: 32),
        .heading2: .boldSystemFont(ofSize: 24),
        .heading3: .boldSystemFont(ofSize: 20),
        .heading4: .boldSystemFont(ofSize: 18),
        .heading5: .boldSystemFont(ofSize: 16),
        .heading6: .boldSystemFont(ofSize: 14)
    ]
    
    public var codeFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    
    public var textColor: UIColor = .label
    
    public var linkColor: UIColor = .systemBlue
    
    public var codeColor: UIColor = .systemOrange
    
    public var headingColor: UIColor = .label
    
    public var blockquoteColor: UIColor = .secondaryLabel
    
    public var blockquoteBorderColor: UIColor = .systemGray4
    
    public var strikethroughColor: UIColor = .systemGray4
    
    public override init() {
        super.init()
    }
    
    open func parse(_ markdown: String) -> NSAttributedString {
        let blocks = parseBlocks(markdown)
        delegate?.parser(self, didParse: blocks)
        
        let result = NSMutableAttributedString()
        
        for block in blocks {
            let blockAttributed = parseBlock(block)
            result.append(blockAttributed)
            
            if block.type != .horizontalRule {
                result.append(NSAttributedString(string: "\n"))
            }
        }
        
        return result
    }
    
    private func parseBlocks(_ markdown: String) -> [BSTextMarkdownBlock] {
        let lines = markdown.components(separatedBy: .newlines)
        var blocks: [BSTextMarkdownBlock] = []
        var currentBlockContent: [String] = []
        var currentBlockType: BSTextMarkdownBlockType = .paragraph
        
        func finalizeBlock() {
            if !currentBlockContent.isEmpty {
                let content = currentBlockContent.joined(separator: "\n")
                blocks.append(BSTextMarkdownBlock(type: currentBlockType, content: content))
                currentBlockContent = []
            }
        }
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                finalizeBlock()
                continue
            }
            
            if let blockType = detectBlockType(line) {
                finalizeBlock()
                currentBlockType = blockType
                
                let content: String
                switch blockType {
                case .heading1, .heading2, .heading3, .heading4, .heading5, .heading6:
                    let level = blockType.rawValue
                    let prefix = String(repeating: "#", count: level) + " "
                    content = line.replacingOccurrences(of: prefix, with: "", options: .anchored)
                case .blockquote:
                    content = line.replacingOccurrences(of: ">", with: "", options: .anchored).trimmingCharacters(in: .whitespaces)
                case .codeBlock:
                    if line == "```" {
                        finalizeBlock()
                        continue
                    }
                    content = line
                case .horizontalRule:
                    blocks.append(BSTextMarkdownBlock(type: .horizontalRule, content: ""))
                    continue
                default:
                    content = line
                }
                
                currentBlockContent.append(content)
            } else {
                currentBlockContent.append(line)
            }
        }
        
        finalizeBlock()
        
        return blocks
    }
    
    private func detectBlockType(_ line: String) -> BSTextMarkdownBlockType? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        if trimmed.hasPrefix("# ") { return .heading1 }
        if trimmed.hasPrefix("## ") { return .heading2 }
        if trimmed.hasPrefix("### ") { return .heading3 }
        if trimmed.hasPrefix("#### ") { return .heading4 }
        if trimmed.hasPrefix("##### ") { return .heading5 }
        if trimmed.hasPrefix("###### ") { return .heading6 }
        
        if trimmed.hasPrefix(">") { return .blockquote }
        
        if trimmed == "```" { return .codeBlock }
        
        if trimmed.hasPrefix("- [ ]") || trimmed.hasPrefix("- [x]") { return .taskList }
        
        if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") { return .unorderedList }
        
        if let range = trimmed.range(of: #"^\d+\."#), range.lowerBound == trimmed.startIndex {
            return .orderedList
        }
        
        if trimmed == "---" || trimmed == "***" || trimmed == "___" {
            return .horizontalRule
        }
        
        return nil
    }
    
    private func parseBlock(_ block: BSTextMarkdownBlock) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: block.content)
        
        switch block.type {
        case .heading1, .heading2, .heading3, .heading4, .heading5, .heading6:
            if let font = headingFonts[block.type] {
                attributed.addAttributes([
                    .font: font,
                    .foregroundColor: headingColor
                ], range: NSRange(location: 0, length: attributed.length))
            }
            
        case .blockquote:
            attributed.addAttributes([
                .foregroundColor: blockquoteColor,
                .font: defaultFont
            ], range: NSRange(location: 0, length: attributed.length))
            
        case .codeBlock:
            attributed.addAttributes([
                .font: codeFont,
                .foregroundColor: codeColor,
                .backgroundColor: UIColor.systemGray5
            ], range: NSRange(location: 0, length: attributed.length))
            
        case .taskList:
            let checkboxRange = (block.content as NSString).range(of: "- [ ] ")
            if checkboxRange.location != NSNotFound {
                attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: checkboxRange)
            }
            attributed.addAttributes([.font: defaultFont], range: NSRange(location: 0, length: attributed.length))
            
        case .unorderedList, .orderedList:
            attributed.addAttributes([.font: defaultFont], range: NSRange(location: 0, length: attributed.length))
            
        case .horizontalRule:
            return NSAttributedString()
            
        default:
            attributed.addAttributes([.font: defaultFont, .foregroundColor: textColor], range: NSRange(location: 0, length: attributed.length))
        }
        
        parseInlines(in: attributed)
        
        return attributed
    }
    
    private func parseInlines(in attributedString: NSMutableAttributedString) {
        let text = attributedString.string as NSString
        
        let patterns: [(pattern: String, type: BSTextMarkdownInlineType)] = [
            ("\\*\\*(.+?)\\*\\*", .bold),
            ("__(.+?)__", .bold),
            ("\\*(.+?)\\*", .italic),
            ("_(.+?)_", .italic),
            ("~~(.+?)~~", .strikethrough),
            ("`(.+?)`", .code),
            ("@(\\w+)", .mention),
            ("#(\\w+)", .hashtag),
            ("\\[(.+?)\\]\\((.+?)\\)", .link),
            ("!\\[(.+?)\\]\\((.+?)\\)", .image)
        ]
        
        for (pattern, type) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: text as String, options: [], range: NSRange(location: 0, length: text.length))
                
                for match in matches.reversed() {
                    let fullRange = match.range
                    let content: String
                    var metadata: [String: Any] = [:]
                    
                    switch type {
                    case .bold, .italic, .strikethrough, .code:
                        content = text.substring(with: match.range(at: 1))
                        
                    case .mention, .hashtag:
                        content = text.substring(with: match.range(at: 1))
                        
                    case .link:
                        let textRange = match.range(at: 1)
                        let urlRange = match.range(at: 2)
                        content = text.substring(with: textRange)
                        metadata["url"] = text.substring(with: urlRange)
                        
                    case .image:
                        let altRange = match.range(at: 1)
                        let urlRange = match.range(at: 2)
                        content = text.substring(with: altRange)
                        metadata["url"] = text.substring(with: urlRange)
                    }
                    
                    let inline = BSTextMarkdownInline(type: type, range: fullRange, content: content, metadata: metadata)
                    delegate?.parser(self, didFindInline: inline, in: fullRange)
                    
                    applyInlineAttributes(attributedString, type: type, range: fullRange, content: content, metadata: metadata)
                }
            } catch {
                continue
            }
        }
    }
    
    private func applyInlineAttributes(_ attributed: NSMutableAttributedString, type: BSTextMarkdownInlineType, range: NSRange, content: String, metadata: [String: Any]) {
        switch type {
        case .bold:
            if let font = attributed.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont {
                attributed.addAttribute(.font, value: font.bolded, range: range)
            } else {
                attributed.addAttribute(.font, value: defaultFont.bolded, range: range)
            }
            
        case .italic:
            if let font = attributed.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont {
                attributed.addAttribute(.font, value: font.italicized, range: range)
            } else {
                attributed.addAttribute(.font, value: defaultFont.italicized, range: range)
            }
            
        case .strikethrough:
            attributed.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            attributed.addAttribute(.strikethroughColor, value: strikethroughColor, range: range)
            
        case .code:
            attributed.replaceCharacters(in: range, with: content)
            attributed.addAttributes([
                .font: codeFont,
                .foregroundColor: codeColor,
                .backgroundColor: UIColor.systemGray5
            ], range: NSRange(location: range.location, length: content.count))
            
        case .mention:
            let mentionAttachment = BSTextAttachment.mentionAttachment(username: content)
            let attachmentString = NSAttributedString(attachment: mentionAttachment)
            attributed.replaceCharacters(in: range, with: attachmentString)
            
        case .hashtag:
            attributed.addAttributes([
                .foregroundColor: linkColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: linkColor
            ], range: range)
            
        case .link:
            if let urlString = metadata["url"] as? String, let url = URL(string: urlString) {
                attributed.replaceCharacters(in: range, with: content)
                attributed.addAttributes([
                    .foregroundColor: linkColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: linkColor,
                    .link: url
                ], range: NSRange(location: range.location, length: content.count))
            }
            
        case .image:
            if let urlString = metadata["url"] as? String, let url = URL(string: urlString) {
                let imageAttachment = BSTextAttachment.imageAttachment(url: url)
                imageAttachment.delegate = self
                let attachmentString = NSAttributedString(attachment: imageAttachment)
                attributed.replaceCharacters(in: range, with: attachmentString)
            }
        }
    }
}

extension BSTextMarkdownParser: BSTextAttachmentDelegate {
    public func attachmentDidFinishLoading(_ attachment: BSTextAttachment) {
    }
    
    public func attachmentDidFailLoading(_ attachment: BSTextAttachment) {
    }
}

public extension BSTextMarkdownParser {
    static func parse(_ markdown: String) -> NSAttributedString {
        let parser = BSTextMarkdownParser()
        return parser.parse(markdown)
    }
}
