//
//  TextParser.swift
//  BSText
//
//  Created by BlueSky on 2018/10/23.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

/**
 The TextParser protocol declares the required method for BSTextView and BSLabel
 to modify the text during editing.
 
 You can implement this protocol to add code highlighting or emoticon replacement for
 BSTextView and BSLabel. See `TextSimpleMarkdownParser` and `TextSimpleEmoticonParser` for example.
 */
@objc public protocol TextParser: NSObjectProtocol {
    /**
     When text is changed in BSTextView or BSLabel, this method will be called.
     
     @param text  The original attributed string. This method may parse the text and
     change the text attributes or content.
     
     @param selectedRange  Current selected range in `text`.
     This method should correct the range if the text content is changed. If there's
     no selected range (such as BSLabel), this value is NULL.
     
     @return If the 'text' is modified in this method, returns `YES`, otherwise returns `NO`.
     */
    @discardableResult
    func parseText(_ text: NSMutableAttributedString?, selectedRange: NSRangePointer?) -> Bool
}


/**
 A simple markdown parser.
 
 It'a very simple markdown parser, you can use this parser to highlight some
 small piece of markdown text.
 
 This markdown parser use regular expression to parse text, slow and weak.
 If you want to write a better parser, try these projests:
 https://github.com/NimbusKit/markdown
 https://github.com/dreamwieber/AttributedMarkdown
 https://github.com/indragiek/CocoaMarkdown
 
 Or you can use lex/yacc to generate your custom parser.
 */
public class TextSimpleMarkdownParser: NSObject, TextParser {
    
    private var font: UIFont?
    ///< h1~h6
    private var headerFonts: [UIFont] = []
    private var boldFont: UIFont?
    private var italicFont: UIFont?
    private var boldItalicFont: UIFont?
    private var monospaceFont: UIFont?
    private var border = TextBorder()
    ///< escape
    private var regexEscape = try! NSRegularExpression(pattern: "(\\\\\\\\|\\\\\\`|\\\\\\*|\\\\\\_|\\\\\\(|\\\\\\)|\\\\\\[|\\\\\\]|\\\\#|\\\\\\+|\\\\\\-|\\\\\\!)", options: [])
    ///< #header
    private var regexHeader = try! NSRegularExpression(pattern: "^((\\#{1,6}[^#].*)|(\\#{6}.+))$", options: .anchorsMatchLines)
    ///< header\n====
    private var regexH1 = try! NSRegularExpression(pattern: "^[^=\\n][^\\n]*\\n=+$", options: .anchorsMatchLines)
    ///< header\n----
    private var regexH2 = try! NSRegularExpression(pattern: "^[^-\\n][^\\n]*\\n-+$", options: .anchorsMatchLines)
    ///< ******
    private var regexBreakline = try! NSRegularExpression(pattern: "^[ \\t]*([*-])[ \\t]*((\\1)[ \\t]*){2,}[ \\t]*$", options: .anchorsMatchLines)
    ///< *text*  _text_
    private var regexEmphasis = try! NSRegularExpression(pattern: "((?<!\\*)\\*(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*(?!\\*)|(?<!_)_(?=[^ \\t_])(.+?)(?<=[^ \\t_])_(?!_))", options: [])
    ///< **text**
    private var regexStrong = try! NSRegularExpression(pattern: "(?<!\\*)\\*{2}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{2}(?!\\*)", options: [])
    ///< ***text*** ___text___
    private var regexStrongEmphasis = try! NSRegularExpression(pattern: "((?<!\\*)\\*{3}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{3}(?!\\*)|(?<!_)_{3}(?=[^ \\t_])(.+?)(?<=[^ \\t_])_{3}(?!_))", options: [])
    ///< __text__
    private var regexUnderline = try! NSRegularExpression(pattern: "(?<!_)__(?=[^ \\t_])(.+?)(?<=[^ \\t_])\\__(?!_)", options: [])
    ///< ~~text~~
    private var regexStrikethrough = try! NSRegularExpression(pattern: "(?<!~)~~(?=[^ \\t~])(.+?)(?<=[^ \\t~])\\~~(?!~)", options: [])
    ///< `text`
    private var regexInlineCode = try! NSRegularExpression(pattern: "(?<!`)(`{1,3})([^`\n]+?)\\1(?!`)", options: [])
    ///< [name](link)
    private var regexLink = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]+)\\](\\(([^\\(\\)]+)\\)|\\[([^\\[\\]]+)\\])", options: [])
    ///< [ref]:
    private var regexLinkRefer = try! NSRegularExpression(pattern: "^[ \\t]*\\[[^\\[\\]]\\]:", options: .anchorsMatchLines)
    ///< 1.text 2.text 3.text
    private var regexList = try! NSRegularExpression(pattern: "^[ \\t]*([*+-]|\\d+[.])[ \\t]+", options: .anchorsMatchLines)
    ///< > quote
    private var regexBlockQuote = try! NSRegularExpression(pattern: "^[ \\t]*>[ \\t>]*", options: .anchorsMatchLines)
    ///< \tcode \tcode
    private var regexCodeBlock = try! NSRegularExpression(pattern: "(^\\s*$\\n)((( {4}|\\t).*(\\n|\\z))|(^\\s*$\\n))+", options: .anchorsMatchLines)
    private var regexNotEmptyLine = try! NSRegularExpression(pattern: "^[ \\t]*[^ \\t]+[ \\t]*$", options: .anchorsMatchLines)
    
    private var _fontSize: CGFloat = 14
    
    /*/< default is 14 */
    public var fontSize: CGFloat {
        set {
            if newValue < 1 {
                _fontSize = 12
            } else {
                _fontSize = newValue
            }
            _updateFonts()
        }
        get {
            return _fontSize
        }
    }
    
    private var _headerFontSize: CGFloat = 20
    
    /*/< default is 20 */
    public var headerFontSize: CGFloat {
        set {
            if newValue < 1 {
                _headerFontSize = 20
            } else {
                _headerFontSize = newValue
            }
            _updateFonts()
        }
        get {
            return _headerFontSize
        }
    }
    
    public var textColor = UIColor.white
    public var controlTextColor: UIColor?
    public var headerTextColor: UIColor?
    public var inlineTextColor: UIColor?
    public var codeTextColor: UIColor?
    public var linkTextColor: UIColor?
    
    ///< reset the color properties to pre-defined value.
    @objc public func setColorWithBrightTheme() {
        textColor = UIColor.black
        controlTextColor = UIColor(white: 0.749, alpha: 1.000)
        headerTextColor = UIColor(red: 1.000, green: 0.502, blue: 0.000, alpha: 1.000)
        inlineTextColor = UIColor(white: 0.150, alpha: 1.000)
        codeTextColor = UIColor(white: 0.150, alpha: 1.000)
        linkTextColor = UIColor(red: 0.000, green: 0.478, blue: 0.962, alpha: 1.000)
        border = TextBorder()
        border.lineStyle = TextLineStyle.single
        border.fillColor = UIColor(white: 0.184, alpha: 0.090)
        border.strokeColor = UIColor(white: 0.546, alpha: 0.650)
        border.insets = UIEdgeInsets(top: -1, left: 0, bottom: -1, right: 0)
        border.cornerRadius = 2
        border.strokeWidth = TextUtilities.textCGFloat(fromPixel: 1)
    }
    
    ///< reset the color properties to pre-defined value.
    @objc public func setColorWithDarkTheme() {
        textColor = UIColor.white
        controlTextColor = UIColor(white: 0.604, alpha: 1.000)
        headerTextColor = UIColor(red: 0.558, green: 1.000, blue: 0.502, alpha: 1.000)
        inlineTextColor = UIColor(red: 1.000, green: 0.862, blue: 0.387, alpha: 1.000)
        codeTextColor = UIColor(white: 0.906, alpha: 1.000)
        linkTextColor = UIColor(red: 0.000, green: 0.646, blue: 1.000, alpha: 1.000)
        border = TextBorder()
        border.lineStyle = TextLineStyle.single
        border.fillColor = UIColor(white: 0.820, alpha: 0.130)
        border.strokeColor = UIColor(white: 1.000, alpha: 0.280)
        border.insets = UIEdgeInsets(top: -1, left: 0, bottom: -1, right: 0)
        border.cornerRadius = 2
        border.strokeWidth = TextUtilities.textCGFloat(fromPixel: 1)
    }
    
    @objc public override init() {
        super.init()
        
        _updateFonts()
        setColorWithBrightTheme()
    }
    
    private func _updateFonts() {
        font = UIFont.systemFont(ofSize: fontSize)
        headerFonts = [UIFont]()
        for i in 0..<6 {
            let size: CGFloat = headerFontSize - (headerFontSize - fontSize) / 5.0 * CGFloat(integerLiteral: i)
            headerFonts.append(UIFont.systemFont(ofSize: size))
        }
        boldFont = TextUtilities.textFont(withBold: font)
        italicFont = TextUtilities.textFont(withItalic: font)
        boldItalicFont = TextUtilities.textFont(withBoldItalic: font)
        monospaceFont = UIFont(name: "Menlo", size: fontSize)
        if monospaceFont == nil {
            monospaceFont = UIFont(name: "Courier", size: fontSize)
        }
    }
    
    private func lenghOfBeginWhite(in str: String?, with range: NSRange) -> Int {
        guard let s = str else {
            return 0
        }
        for i in 0..<range.length {
            let c = String(s[(s.index(s.startIndex, offsetBy: i + range.location))])
            if c != " " && c != "\t" && c != "\n" {
                return i
            }
        }
        return s.length
    }
    
    private func lenghOfEndWhite(in str: String?, with range: NSRange) -> Int {
        guard let s = str else {
            return 0
        }
        var i = range.length - 1
        while i >= 0 {
            let c = String(s[(s.index(s.startIndex, offsetBy: i + range.location))])
            if c != " " && c != "\t" && c != "\n" {
                return (range.length - i)
            }
            i -= 1
        }
        return s.length
    }
    
    private func lenghOfBeginChar(_ c: Character, in str: String?, with range: NSRange) -> Int {
        guard let s = str, s != "" else {
            return 0
        }
        for i in 0..<range.length {
            if s[(s.index(s.startIndex, offsetBy: i + range.location))] != c {
                return i
            }
        }
        return s.length
    }
    
    @objc public func parseText(_ text: NSMutableAttributedString?, selectedRange range: NSRangePointer?) -> Bool {
        
        guard let t = text, t.length > 0 else {
            return false
        }
        
        t.bs_removeAttributes(in: NSRange(location: 0, length: t.length))
        t.bs_font = font
        t.bs_color = textColor
        let str = t.string
        
        regexEscape.replaceMatches(in: str as! NSMutableString, options: [], range: NSRange(location: 0, length: str.length), withTemplate: "@@")
        
        regexHeader.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r: NSRange = result!.range
            let whiteLen = self.lenghOfBeginWhite(in: str, with: r)
            var sharpLen = self.lenghOfBeginChar("#"["#".startIndex], in: str, with: NSRange(location: r.location + whiteLen, length: r.length - whiteLen))
            if sharpLen > 6 {
                sharpLen = 6
            }
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: r.location, length: whiteLen + sharpLen))
            text?.bs_set(color: self.headerTextColor, range: NSRange(location: r.location + whiteLen + sharpLen, length: r.length - whiteLen - sharpLen))
            text?.bs_set(font: self.headerFonts[sharpLen - 1], range: r)
        })
        
        regexH1.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            var linebreak: NSRange? = nil
            if let tmpRange = str.range(of: "\n", options: [], range: Range(r, in: str)!, locale: nil) {
                linebreak = NSRange(tmpRange, in: str)
            }
            
            if (linebreak?.location ?? 0) != NSNotFound {
                text?.bs_set(color: self.headerTextColor, range: NSRange(location: r.location, length: ((linebreak?.location ?? 0) - r.location)))
                text?.bs_set(font: self.headerFonts.first, range: NSRange(location: r.location, length: ((linebreak?.location ?? 0) - r.location) + 1))
                text?.bs_set(color: self.controlTextColor, range: NSRange(location: ((linebreak?.location ?? 0) + (linebreak?.length ?? 0)), length: (r.location + r.length - (linebreak?.location ?? 0) - (linebreak?.length ?? 0))))
            }
        })
        
        regexH2.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            var linebreak: NSRange? = nil
            if let tmpRange = str.range(of: "\n", options: [], range: Range(r, in: str)!, locale: nil) {
                linebreak = NSRange(tmpRange, in: str)
            }
            
            if (linebreak?.location ?? 0) != NSNotFound {
                text?.bs_set(color: self.headerTextColor, range: NSRange(location: r.location, length: ((linebreak?.location ?? 0) - r.location)))
                text?.bs_set(font: self.headerFonts[1], range: NSRange(location: r.location, length: ((linebreak?.location ?? 0) - r.location) + 1))
                text?.bs_set(color: self.controlTextColor, range: NSRange(location: ((linebreak?.location ?? 0) + (linebreak?.length ?? 0)), length: (r.location + r.length - (linebreak?.location ?? 0) - (linebreak?.length ?? 0))))
            }
        })
        
        regexBreakline.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            text?.bs_set(color: self.controlTextColor, range: (result?.range)!)
        })
        
        regexEmphasis.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: r.location, length: 1))
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: (r.location + r.length) - 1, length: 1))
            text?.bs_set(font: self.italicFont, range: NSRange(location: r.location + 1, length: r.length - 2))
        })
        
        regexStrong.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: r.location, length: 2))
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: (r.location + r.length) - 2, length: 2))
            text?.bs_set(font: self.boldFont, range: NSRange(location: r.location + 2, length: r.length - 4))
        })
        
        regexStrongEmphasis.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: r.location, length: 3))
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: (r.location + r.length) - 3, length: 3))
            text?.bs_set(font: self.boldItalicFont, range: NSRange(location: r.location + 3, length: r.length - 6))
        })

        regexUnderline.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: r.location, length: 2))
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: (r.location + r.length) - 2, length: 2))
            text?.bs_set(textUnderline: TextDecoration.decoration(with: TextLineStyle.single, width: 1, color: nil), range: NSRange(location: r.location + 2, length: r.length - 4))
        })
        
        regexStrikethrough.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: r.location, length: 2))
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: (r.location + r.length) - 2, length: 2))
            text?.bs_set(textStrikethrough: TextDecoration.decoration(with: TextLineStyle.single, width: 1, color: nil), range: NSRange(location: r.location + 2, length: r.length - 4))
        })
        
        regexInlineCode.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            let len: Int = self.lenghOfBeginChar("`", in: str, with: r)
            
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: r.location, length: len))
            text?.bs_set(color: self.controlTextColor, range: NSRange(location: (r.location + r.length) - len, length: len))
            text?.bs_set(color: self.inlineTextColor, range: NSRange(location: r.location + len, length: r.length - 2 * len))
            text?.bs_set(font: self.monospaceFont, range: r)
            text?.bs_set(textBorder: (self.border.copy() as? TextBorder), range: r)
        })

        regexLink.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            text?.bs_set(color: self.linkTextColor, range: r)
        })
        
        regexLinkRefer.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            text?.bs_set(color: self.controlTextColor, range: r)
        })
        
        regexList.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            text?.bs_set(color: self.controlTextColor, range: r)
        })

        regexBlockQuote.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            text?.bs_set(color: self.controlTextColor, range: r)
        })
        
        regexCodeBlock.enumerateMatches(in: str, options: [], range: NSRange(location: 0, length: str.length), using: { result, flags, stop in
            let r = result!.range
            let firstLineRange = self.regexNotEmptyLine.rangeOfFirstMatch(in: str, options: [], range: r)
            
            let lenStart = (firstLineRange.location != NSNotFound) ? (firstLineRange.location - r.location) : 0
            let lenEnd: Int = self.lenghOfEndWhite(in: str, with: r)
            if lenStart + lenEnd < r.length {
                let codeR = NSRange(location: r.location + lenStart, length: r.length - lenStart - lenEnd)
                text?.bs_set(color: self.codeTextColor, range: codeR)
                text?.bs_set(font: self.monospaceFont, range: codeR)
                let border = TextBorder()
                border.lineStyle = TextLineStyle.single
                border.fillColor = UIColor(white: 0.184, alpha: 0.090)
                
                border.strokeColor = UIColor(white: 0.200, alpha: 0.300)
                border.insets = UIEdgeInsets(top: -1, left: 0, bottom: -1, right: 0)
                border.cornerRadius = 3
                border.strokeWidth = TextUtilities.textCGFloat(fromPixel: 2)
                text?.bs_set(textBlockBorder: (self.border.copy() as? TextBorder), range: codeR)
            }
        })
        
        return true
    }
}

/**
 A simple emoticon parser.
 
 Use this parser to map some specified piece of string to image emoticon.
 Example: "Hello :smile:"  ->  "Hello 😀"
 
 It can also be used to extend the "unicode emoticon".
 */
public class TextSimpleEmoticonParser: NSObject, TextParser {
    
    private var regex: NSRegularExpression?
    private var mapper: [String : UIImage]?
    private lazy var lock = DispatchSemaphore(value: 1)
    
    /**
     The custom emoticon mapper.
     The key is a specified plain string, such as @":smile:".
     The value is a UIImage which will replace the specified plain string in text.
     */
    @objc public var emoticonMapper: [String : UIImage]? {
        
        get {
            lock.wait()
            let m = self.mapper
            lock.signal()
            
            return m
        }
        set {
            lock.wait()
            self.mapper = newValue
            
            if let tmpMapper = newValue, tmpMapper.count > 0 {
                var pattern = "("
                let allKeys = tmpMapper.keys
                let charset = CharacterSet(charactersIn: "$^?+*.,#|{}[]()\\")
                var i = 0, max = allKeys.count
                while i < max {
                    var one = allKeys[allKeys.index(allKeys.startIndex, offsetBy: i)]
                    // escape regex characters
                    var ci = 0, cmax = one.count
                    while ci < cmax {
                        let c = String(one[one.index(one.startIndex, offsetBy: ci)])
                        if charset.contains(Unicode.Scalar(c)!) {
                            one.insert(contentsOf: "\\", at: one.index(one.startIndex, offsetBy: ci))
                            ci += 1
                            cmax += 1
                        }
                        ci += 1
                    }
                    pattern += one
                    if i != max - 1 {
                        pattern += "|"
                    }
                    i += 1
                }
                pattern += ")"
                regex = try! NSRegularExpression(pattern: pattern, options: [])
            } else {
                regex = nil
            }
            
            lock.signal()
        }
    }
    
    @objc public override init() {
        super.init()
    }
    
    // correct the selected range during text replacement
    private func _replaceText(in range: NSRange, withLength length: Int, selectedRange: NSRange) -> NSRange {
        var selectedRange = selectedRange
        // no change
        if range.length == length {
            return selectedRange
        }
        // right
        if range.location >= selectedRange.location + selectedRange.length {
            return selectedRange
        }
        // left
        if selectedRange.location >= range.location + range.length {
            selectedRange.location = selectedRange.location + length - range.length
            return selectedRange
        }
        // same
        if NSEqualRanges(range, selectedRange) {
            selectedRange.length = length
            return selectedRange
        }
        // one edge same
        if (range.location == selectedRange.location && range.length < selectedRange.length) || (range.location + range.length == selectedRange.location + selectedRange.length && range.length < selectedRange.length) {
            selectedRange.length = selectedRange.length + length - range.length
            return selectedRange
        }
        
        selectedRange.location = range.location + length
        selectedRange.length = 0
        
        return selectedRange
    }

    @objc public func parseText(_ text: NSMutableAttributedString?, selectedRange range: NSRangePointer?) -> Bool {

        guard let t = text, t.length > 0 else {
            return false
        }

        let tmpMapper: [AnyHashable : UIImage]?
        let tmpRegex: NSRegularExpression?

        lock.wait()
        tmpMapper = mapper
        tmpRegex = regex
        lock.signal()

        guard let tMapper = tmpMapper, tMapper.count > 0, tmpRegex != nil else {
            return false
        }

        let matches = tmpRegex?.matches(in: t.string, options: [], range: NSRange(location: 0, length: t.length))
        if matches?.count == 0 {
            return false
        }
        var selectedRange = range != nil ? range!.pointee : NSRange(location: 0, length: 0)
        var cutLength: Int = 0
        
        for one in matches ?? [] {
            var oneRange = one.range
            if oneRange.length == 0 {
                continue
            }
            oneRange.location -= cutLength
            let subStr = (t.string as NSString).substring(with: oneRange)
            let emoticon = tMapper[subStr]
            guard let _ = emoticon else {
                continue
            }
            var fontSize: CGFloat = 12 // CoreText default value
            
            if let font = t.bs_attribute(NSAttributedString.Key.font, at: oneRange.location) as! CTFont? {
                fontSize = CTFontGetSize(font)
            }
            let atr = NSAttributedString.bs_attachmentString(with: emoticon, fontSize: fontSize)
            let backedstring = TextBackedString()
            backedstring.string = subStr
            atr?.bs_set(textBackedString: backedstring, range: NSRange(location: 0, length: atr?.length ?? 0))
            text?.replaceCharacters(in: oneRange, with: atr?.string ?? "")
            text?.bs_removeDiscontinuousAttributes(in: NSRange(location: oneRange.location, length: atr?.length ?? 0))
            if let anAttributes = atr?.bs_attributes {
                text?.addAttributes(anAttributes, range: NSRange(location: oneRange.location, length: atr?.length ?? 0))
            }
            selectedRange = _replaceText(in: oneRange, withLength: atr?.length ?? 0, selectedRange: selectedRange)
            cutLength += oneRange.length - 1
        }
        
        range?.pointee = selectedRange

        return true
    }
}
