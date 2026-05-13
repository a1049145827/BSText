import UIKit

@objc public protocol BSTextCodeEditorDelegate: AnyObject {
    @objc optional func codeEditor(_ editor: BSTextCodeEditor, didToggleFoldAt lineIndex: Int)
    @objc optional func codeEditor(_ editor: BSTextCodeEditor, didChangeFoldedLines lines: [Int])
}

@objcMembers
open class BSTextCodeEditor: BSTextView {
    
    public weak var codeDelegate: BSTextCodeEditorDelegate?
    
    public var language: BSTextSyntaxLanguage = .swift {
        didSet {
            syntaxParser.language = language
            updateSyntaxHighlighting()
        }
    }
    
    public var theme: BSTextSyntaxTheme = .default {
        didSet {
            syntaxParser.theme = theme
            updateSyntaxHighlighting()
        }
    }
    
    public var showLineNumbers: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var lineNumberWidth: CGFloat = 50 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var lineNumberColor: UIColor = .systemGray4
    
    public var lineNumberBackgroundColor: UIColor = .systemGray6
    
    public var indentationWidth: Int = 4
    
    private let syntaxParser = BSTextSyntaxParser()
    private var foldedLines: Set<Int> = []
    private var lineHeights: [CGFloat] = []
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        font = theme.font
        backgroundColor = .systemBackground
        syntaxParser.language = language
        syntaxParser.theme = theme
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }
    
    @objc private func textDidChange() {
        updateSyntaxHighlighting()
        updateLineHeights()
    }
    
    private func updateSyntaxHighlighting() {
        let attributedText = syntaxParser.parse(text)
        textStorage.beginEditing()
        textStorage.setAttributedString(attributedText)
        textStorage.endEditing()
    }
    
    private func updateLineHeights() {
        let text = self.text as NSString
        let lines = text.components(separatedBy: .newlines)
        let defaultFont = self.font ?? UIFont.systemFont(ofSize: 14)
        lineHeights = lines.map { _ in defaultFont.pointSize * 1.2 }
    }
    
    public func toggleFold(at lineIndex: Int) {
        if foldedLines.contains(lineIndex) {
            foldedLines.remove(lineIndex)
        } else {
            foldedLines.insert(lineIndex)
            foldBlockStartingAt(lineIndex)
        }
        codeDelegate?.codeEditor?(self, didToggleFoldAt: lineIndex)
        codeDelegate?.codeEditor?(self, didChangeFoldedLines: Array(foldedLines))
        setNeedsDisplay()
    }
    
    private func foldBlockStartingAt(_ startLine: Int) {
        let text = self.text as NSString
        let lines = text.components(separatedBy: .newlines)
        
        var depth = 0
        for i in startLine..<lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("{") || trimmed.hasPrefix("(") || trimmed.hasPrefix("[") {
                depth += 1
            }
            if trimmed.hasSuffix("}") || trimmed.hasSuffix(")") || trimmed.hasSuffix("]") {
                depth -= 1
                if depth == 0 {
                    for j in startLine+1...i {
                        foldedLines.insert(j)
                    }
                    break
                }
            }
        }
    }
    
    public func isLineFolded(_ lineIndex: Int) -> Bool {
        return foldedLines.contains(lineIndex)
    }
    
    public func foldAll() {
        let text = self.text as NSString
        let lines = text.components(separatedBy: .newlines)
        
        for i in 0..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("{") || line.hasPrefix("(") || line.hasPrefix("[") {
                toggleFold(at: i)
            }
        }
    }
    
    public func unfoldAll() {
        foldedLines.removeAll()
        if let delegate = codeDelegate {
            delegate.codeEditor?(self, didChangeFoldedLines: [])
        }
        setNeedsDisplay()
    }
    
    public func indentSelectedText() {
        let range = selectedRange
        if range.length > 0 {
            let text = self.text as NSString
            let startLine = text.lineRange(for: NSRange(location: range.location, length: 0)).location
            let endLine = text.lineRange(for: NSRange(location: range.location + range.length - 1, length: 0)).location
            
            let indent = String(repeating: " ", count: indentationWidth)
            let indentAttributed = NSAttributedString(string: indent)
            
            textStorage.beginEditing()
            var offset = 0
            for i in startLine..<endLine {
                let lineStart = (text as NSString).rangeOfCharacter(from: .newlines, options: .backwards, range: NSRange(location: 0, length: i)).location + 1
                textStorage.insert(indentAttributed, at: lineStart + offset)
                offset += indent.count
            }
            textStorage.endEditing()
            
            selectedRange = NSRange(
                location: range.location,
                length: range.length + offset
            )
        }
    }
    
    public func unindentSelectedText() {
        let range = selectedRange
        if range.length > 0 {
            let text = self.text as NSString
            let startLine = text.lineRange(for: NSRange(location: range.location, length: 0)).location
            let endLine = text.lineRange(for: NSRange(location: range.location + range.length - 1, length: 0)).location
            
            let indent = String(repeating: " ", count: indentationWidth)
            
            textStorage.beginEditing()
            var offset = 0
            for i in startLine..<endLine {
                let lineStart = max(0, (text as NSString).rangeOfCharacter(from: .newlines, options: .backwards, range: NSRange(location: 0, length: i)).location + 1)
                let lineRange = NSRange(location: lineStart, length: min(indentationWidth, text.length - lineStart))
                
                if (text as NSString).substring(with: lineRange).starts(with: indent) {
                    textStorage.deleteCharacters(in: lineRange)
                    offset -= indent.count
                }
            }
            textStorage.endEditing()
            
            selectedRange = NSRange(
                location: range.location,
                length: max(0, range.length + offset)
            )
        }
    }
    
    public func commentSelectedText() {
        let range = selectedRange
        if range.length > 0 {
            let text = self.text as NSString
            let startLine = text.lineRange(for: NSRange(location: range.location, length: 0)).location
            let endLine = text.lineRange(for: NSRange(location: range.location + range.length - 1, length: 0)).location
            
            let comment = "// "
            let commentAttributed = NSAttributedString(string: comment)
            
            textStorage.beginEditing()
            var offset = 0
            for i in startLine..<endLine {
                let lineStart = max(0, (text as NSString).rangeOfCharacter(from: .newlines, options: .backwards, range: NSRange(location: 0, length: i)).location + 1)
                textStorage.insert(commentAttributed, at: lineStart + offset)
                offset += comment.count
            }
            textStorage.endEditing()
            
            selectedRange = NSRange(
                location: range.location,
                length: range.length + offset
            )
        }
    }
    
    public func uncommentSelectedText() {
        let range = selectedRange
        if range.length > 0 {
            let text = self.text as NSString
            let startLine = text.lineRange(for: NSRange(location: range.location, length: 0)).location
            let endLine = text.lineRange(for: NSRange(location: range.location + range.length - 1, length: 0)).location
            
            let comment = "// "
            
            textStorage.beginEditing()
            var offset = 0
            for i in startLine..<endLine {
                let lineStart = max(0, (text as NSString).rangeOfCharacter(from: .newlines, options: .backwards, range: NSRange(location: 0, length: i)).location + 1)
                let commentRange = NSRange(location: lineStart, length: min(comment.count, text.length - lineStart))
                
                if (text as NSString).substring(with: commentRange) == comment {
                    textStorage.deleteCharacters(in: commentRange)
                    offset -= comment.count
                }
            }
            textStorage.endEditing()
            
            selectedRange = NSRange(
                location: range.location,
                length: max(0, range.length + offset)
            )
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if showLineNumbers {
            textContainerInset = UIEdgeInsets(top: textContainerInset.top, left: lineNumberWidth + 8, bottom: textContainerInset.bottom, right: textContainerInset.right)
        } else {
            textContainerInset = UIEdgeInsets(top: textContainerInset.top, left: 8, bottom: textContainerInset.bottom, right: textContainerInset.right)
        }
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if showLineNumbers {
            drawLineNumbers(in: rect)
        }
    }
    
    private func drawLineNumbers(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let lineNumberRect = CGRect(x: 0, y: rect.origin.y, width: lineNumberWidth, height: rect.size.height)
        
        lineNumberBackgroundColor.setFill()
        context.fill(lineNumberRect)
        
        let text = self.text as NSString
        let lines = text.components(separatedBy: .newlines)
        let font = self.font ?? UIFont.systemFont(ofSize: 14)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: lineNumberColor
        ]
        
        var y = contentOffset.y
        for (index, _) in lines.enumerated() {
            if isLineFolded(index) {
                continue
            }
            
            let lineHeight = font.pointSize * 1.2
            if y + lineHeight > 0 && y < bounds.height {
                let lineNumber = "\(index + 1)"
                let size = lineNumber.size(withAttributes: attributes)
                let x = lineNumberWidth - size.width - 8
                let point = CGPoint(x: x, y: y)
                
                lineNumber.draw(at: point, withAttributes: attributes)
            }
            y += lineHeight
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

public extension BSTextCodeEditor {
    static func createCodeEditor(language: BSTextSyntaxLanguage = .swift) -> BSTextCodeEditor {
        let editor = BSTextCodeEditor()
        editor.language = language
        editor.showLineNumbers = true
        editor.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        return editor
    }
}
