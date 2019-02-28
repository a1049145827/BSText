//
//  TextAttribute.swift
//  BSText
//
//  Created by BlueSky on 2018/11/1.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import CoreText

// MARK: - Enum Define

/// The attribute type
@objc public enum TextAttributeType : Int {
    case none = 0
    ///< UIKit attributes, such as UILabel/UITextField/drawInRect.
    case uiKit = 1      // (1 << 0)
    ///< CoreText attributes, used by CoreText.
    case coreText = 2   // (1 << 1)
    ///< Text attributes, used by BSText.
    case bsText = 4     // (1 << 2)
}

/**
 Line style in Text (similar to NSUnderlineStyle).
 */
@objc public enum TextLineStyle: Int {
    
    // basic style (bitmask:0xFF)
    ///< (        ) Do not draw a line (Default).
    case none = 0x00
    ///< (──────) Draw a single line.
    case single = 0x01
    ///< (━━━━━━━) Draw a thick line.
    case thick = 0x02
    ///< (══════) Draw a double line.
    case double = 0x09
    
    // style pattern (bitmask:0xF00)
    ///< (────────) Draw a solid line (Default).
//    case patternSolid = 0x000
    ///< (‑ ‑ ‑ ‑ ‑ ‑) Draw a line of dots.
    case patternDot = 0x100
    ///< (— — — —) Draw a line of dashes.
    case patternDash = 0x200
    ///< (— ‑ — ‑ — ‑) Draw a line of alternating dashes and dots.
    case patternDashDot = 0x300
    ///< (— ‑ ‑ — ‑ ‑) Draw a line of alternating dashes and two dots.
    case patternDashDotDot = 0x400
    ///< (••••••••••••) Draw a line of small circle dots.
    case patternCircleDot = 0x900
}

/**
 Text vertical alignment.
 */
@objc public enum TextVerticalAlignment : Int {
    ///< Top alignment.
    case top = 0
    ///< Center alignment.
    case center = 1
    ///< Bottom alignment.
    case bottom = 2
}

/**
 The direction define in Text.
 */
@objc public enum TextDirection : Int {
    
    case none = 0
    case top = 1        // 1 << 0
    case right = 2      // 1 << 1
    case bottom = 4     // 1 << 2
    case left = 8       // 1 << 3
}

/**
 The trunction type, tells the truncation engine which type of truncation is being requested.
 */
@objc public enum TextTruncationType : Int {
    /// No truncate.
    case none = 0
    /// Truncate at the beginning of the line, leaving the end portion visible.
    case start = 1
    /// Truncate at the end of the line, leaving the start portion visible.
    case end = 2
    /// Truncate in the middle of the line, leaving both the start and the end portions visible.
    case middle = 3
}

// MARK: - Attribute Value Define

/**
 The tap/long press action callback defined in Text.
 
 @param containerView The text container view (such as Label/TextView).
 @param text          The whole text.
 @param range         The text range in `text` (if no range, the range.location is NSNotFound).
 @param rect          The text frame in `containerView` (if no data, the rect is CGRectNull).
 */
//typealias TextAction = (UIView?, NSAttributedString?, NSRange, CGRect) -> Void


public class TextAttribute: NSObject {
    
    // MARK: - Attribute Name Defined in Text
    
    /// The value of this attribute is a `TextBackedString` object.
    /// Use this attribute to store the original plain text if it is replaced by something else (such as attachment).
    @objc public static let textBackedStringAttributeName = "TextBackedString"
    
    /// The value of this attribute is a `TextBinding` object.
    /// Use this attribute to bind a range of text together, as if it was a single charactor.
    @objc public static let textBindingAttributeName = "TextBinding"
    
    /// The value of this attribute is a `TextShadow` object.
    /// Use this attribute to add shadow to a range of text.
    /// Shadow will be drawn below text glyphs. Use TextShadow.subShadow to add multi-shadow.
    @objc public static let textShadowAttributeName = "TextShadow"
    
    /// The value of this attribute is a `TextShadow` object.
    /// Use this attribute to add inner shadow to a range of text.
    /// Inner shadow will be drawn above text glyphs. Use TextShadow.subShadow to add multi-shadow.
    @objc public static let textInnerShadowAttributeName = "TextInnerShadow"
    
    /// The value of this attribute is a `TextDecoration` object.
    /// Use this attribute to add underline to a range of text.
    /// The underline will be drawn below text glyphs.
    @objc public static let textUnderlineAttributeName = "TextUnderline"
    
    /// The value of this attribute is a `TextDecoration` object.
    /// Use this attribute to add strikethrough (de@objc public static lete line) to a range of text.
    /// The strikethrough will be drawn above text glyphs.
    @objc public static let textStrikethroughAttributeName = "TextStrikethrough"
    
    /// The value of this attribute is a `TextBorder` object.
    /// Use this attribute to add cover border or cover color to a range of text.
    /// The border will be drawn above the text glyphs.
    @objc public static let textBorderAttributeName = "TextBorder"
    
    /// The value of this attribute is a `TextBorder` object.
    /// Use this attribute to add background border or background color to a range of text.
    /// The border will be drawn below the text glyphs.
    @objc public static let textBackgroundBorderAttributeName = "TextBackgroundBorder"
    
    /// The value of this attribute is a `TextBorder` object.
    /// Use this attribute to add a code block border to one or more line of text.
    /// The border will be drawn below the text glyphs.
    @objc public static let textBlockBorderAttributeName = "TextBlockBorder"
    
    /// The value of this attribute is a `TextAttachment` object.
    /// Use this attribute to add attachment to text.
    /// It should be used in conjunction with a CTRunDelegate.
    @objc public static let textAttachmentAttributeName = "TextAttachment"
    
    /// The value of this attribute is a `TextHighlight` object.
    /// Use this attribute to add a touchable highlight state to a range of text.
    @objc public static let textHighlightAttributeName = "TextHighlight"
    
    /// The value of this attribute is a `NSValue` object stores CGAffineTransform.
    /// Use this attribute to add transform to each glyph in a range of text.
    @objc public static let textGlyphTransformAttributeName = "TextGlyphTransform"
    
    // MARK: - String Token Define
    
    ///< Object replacement character (U+FFFC), used for text attachment.
    @objc public static let textAttachmentToken = "\u{FFFC}"
    
    ///< Horizontal ellipsis (U+2026), used for text truncation  "…".
    @objc public static let textTruncationToken = "\u{2026}"
    
    static var kTextAttributeTypeDic: NSDictionary?
    
    @objc public static func textAttributeGetType(name: String) -> TextAttributeType {
        
        if let d = kTextAttributeTypeDic {
            return d.object(forKey: name) as? TextAttributeType ?? TextAttributeType.none
        }
        
        let dic = NSMutableDictionary()
        let All = TextAttributeType.uiKit.rawValue | TextAttributeType.coreText.rawValue | TextAttributeType.bsText.rawValue
        let CoreText_BSText = TextAttributeType.coreText.rawValue | TextAttributeType.bsText.rawValue
        let UIKit_BSText = TextAttributeType.uiKit.rawValue | TextAttributeType.bsText.rawValue
        let UIKit_CoreText = TextAttributeType.uiKit.rawValue | TextAttributeType.coreText.rawValue
        let UIKit = TextAttributeType.uiKit.rawValue
        let CoreText = TextAttributeType.coreText.rawValue
        let BSText = TextAttributeType.bsText.rawValue
        
        dic[NSAttributedString.Key.font] = All
        dic[NSAttributedString.Key.kern] = All
        dic[NSAttributedString.Key.foregroundColor] = UIKit
        dic[kCTForegroundColorAttributeName] = CoreText
        dic[kCTForegroundColorFromContextAttributeName] = CoreText
        dic[NSAttributedString.Key.backgroundColor] = UIKit
        dic[NSAttributedString.Key.strokeWidth] = All
        dic[NSAttributedString.Key.strokeColor] = UIKit
        dic[kCTStrokeColorAttributeName] = CoreText_BSText
        dic[NSAttributedString.Key.shadow] = UIKit_BSText
        dic[NSAttributedString.Key.strikethroughStyle] = UIKit
        dic[NSAttributedString.Key.underlineStyle] = UIKit_CoreText
        dic[kCTUnderlineColorAttributeName] = CoreText
        dic[NSAttributedString.Key.ligature] = All
        dic[kCTSuperscriptAttributeName] = UIKit //it's a CoreText attrubite, but only supported by UIKit...
        dic[NSAttributedString.Key.verticalGlyphForm] = All
        dic[kCTGlyphInfoAttributeName] = CoreText_BSText
        dic[kCTCharacterShapeAttributeName] = CoreText_BSText
        dic[kCTRunDelegateAttributeName] = CoreText_BSText
        dic[kCTBaselineClassAttributeName] = CoreText_BSText
        dic[kCTBaselineInfoAttributeName] = CoreText_BSText
        dic[kCTBaselineReferenceInfoAttributeName] = CoreText_BSText
        dic[kCTWritingDirectionAttributeName] = CoreText_BSText
        dic[NSAttributedString.Key.paragraphStyle] = All
        
        dic[NSAttributedString.Key.strikethroughColor] = UIKit
        dic[NSAttributedString.Key.underlineColor] = UIKit
        dic[NSAttributedString.Key.textEffect] = UIKit
        dic[NSAttributedString.Key.obliqueness] = UIKit
        dic[NSAttributedString.Key.expansion] = UIKit
        dic[kCTLanguageAttributeName] = CoreText_BSText
        dic[NSAttributedString.Key.baselineOffset] = UIKit
        dic[NSAttributedString.Key.writingDirection] = All
        dic[NSAttributedString.Key.attachment] = UIKit
        dic[NSAttributedString.Key.link] = UIKit
        dic[kCTRubyAnnotationAttributeName] = CoreText
        
        dic[TextAttribute.textBackedStringAttributeName] = BSText
        dic[TextAttribute.textBindingAttributeName] = BSText
        dic[TextAttribute.textShadowAttributeName] = BSText
        dic[TextAttribute.textInnerShadowAttributeName] = BSText
        dic[TextAttribute.textUnderlineAttributeName] = BSText
        dic[TextAttribute.textStrikethroughAttributeName] = BSText
        dic[TextAttribute.textBorderAttributeName] = BSText
        dic[TextAttribute.textBackgroundBorderAttributeName] = BSText
        dic[TextAttribute.textBlockBorderAttributeName] = BSText
        dic[TextAttribute.textAttachmentAttributeName] = BSText
        dic[TextAttribute.textHighlightAttributeName] = BSText
        dic[TextAttribute.textGlyphTransformAttributeName] = BSText
        
        kTextAttributeTypeDic = (dic.copy() as! NSDictionary)
        
        return kTextAttributeTypeDic!.object(forKey: name) as? TextAttributeType ?? TextAttributeType.none
    }
}


/**
 TextBackedString objects are used by the NSAttributedString class cluster
 as the values for text backed string attributes (stored in the attributed
 string under the key named TextBackedStringAttributeName).
 
 It may used for copy/paste plain text from attributed string.
 Example: If :) is replace by a custom emoji (such as😊), the backed string can be set to @":)".
 */
public class TextBackedString: NSObject, NSCoding, NSCopying, NSSecureCoding {
    
    @objc public var string: String?
    
    public override init() {
        super.init()
    }
    
    ///< backed string
    @objc public class func stringWithString(_ string: String) -> TextBackedString {
        let one = TextBackedString()
        one.string = string
        return one
    }
    
    // MARK: - NSCoding
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(string, forKey: "string")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        string = aDecoder.decodeObject(forKey: "string") as? String
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let one = TextBackedString()
        one.string = string
        return one
    }
    
    // MARK: - NSSecureCoding
    public static var supportsSecureCoding: Bool {
        return true
    }
}


/**
 TextBinding objects are used by the NSAttributedString class cluster
 as the values for shadow attributes (stored in the attributed string under
 the key named TextBindingAttributeName).
 
 Add this to a range of text will make the specified characters 'binding together'.
 TextView will treat the range of text as a single character during text
 selection and edit.
 */
public class TextBinding: NSObject, NSCoding, NSCopying, NSSecureCoding {
    
    @objc public var deleteConfirm = false
    
    public override init() {
        super.init()
    }
    
    ///< confirm the range when delete in TextView
    @objc(bindingWithDeleteConfirm:)
    public class func binding(with deleteConfirm: Bool) -> TextBinding {
        
        let one = TextBinding()
        one.deleteConfirm = deleteConfirm
        
        return one
    }
    
    // MARK: - NSCoding
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(deleteConfirm, forKey: "deleteConfirm")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        deleteConfirm = aDecoder.decodeBool(forKey: "deleteConfirm")
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let one = TextBinding()
        one.deleteConfirm = deleteConfirm
        return one
    }
    
    // MARK: - NSSecureCoding
    public static var supportsSecureCoding: Bool {
        return true
    }
}

/**
 TextShadow objects are used by the NSAttributedString class cluster
 as the values for shadow attributes (stored in the attributed string under
 the key named TextShadowAttributeName or TextInnerShadowAttributeName).
 
 It's similar to `NSShadow`, but offers more options.
 */
public class TextShadow: NSObject, NSCoding, NSCopying, NSSecureCoding {
    
    /*/< shadow color */
    @objc public var color: UIColor?
    
    /*/< shadow offset */
    @objc public var offset = CGSize.zero
    
    /*/< shadow blur radius */
    @objc public var radius: CGFloat = 0
    
    /*/< shadow blend mode */
    @objc public var blendMode = CGBlendMode.normal
    
    ///< a sub shadow which will be added above the parent shadow
    @objc public var subShadow: TextShadow?
    
    public override init() {
        super.init()
    }
    
    @objc public class func shadowWithColor(_ color: UIColor?, offset: CGSize, radius: CGFloat) -> TextShadow {
        
        let one = TextShadow()
        
        one.color = color
        one.offset = offset
        one.radius = radius
        
        return one
    }
    
    ///< convert NSShadow to TextShadow
    @objc(shadowWithNSShadow:)
    public class func shadow(with nsShadow: NSShadow?) -> TextShadow? {
        
        guard let _ = nsShadow else {
            return nil
        }
        
        let shadow = TextShadow()
        shadow.offset = nsShadow!.shadowOffset
        shadow.radius = nsShadow!.shadowBlurRadius
        let color = nsShadow!.shadowColor
        
        if color != nil {
            var c: UIColor?
            if CGColor.typeID == CFGetTypeID(color! as CFTypeRef) {
                c = UIColor(cgColor: color! as! CGColor)
            }
            if (color is UIColor) {
                shadow.color = c!
            }
        }
        
        return shadow
    }
    
    ///< convert TextShadow to NSShadow
    @objc public func nsShadow() -> NSShadow? {
        let shadow = NSShadow()
        shadow.shadowOffset = offset
        shadow.shadowBlurRadius = radius
        shadow.shadowColor = color
        return shadow
    }
    
    // MARK: - NSCoding
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(color, forKey: "color")
        aCoder.encode(Float(radius), forKey: "radius")
        aCoder.encode(offset, forKey: "offset")
        aCoder.encode(subShadow, forKey: "subShadow")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        
        color = aDecoder.decodeObject(forKey: "color") as? UIColor
        radius = CGFloat(aDecoder.decodeFloat(forKey: "radius"))
        offset = aDecoder.decodeCGSize(forKey: "offset")
        subShadow = aDecoder.decodeObject(forKey: "subShadow") as? TextShadow
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let one = TextShadow()
        
        one.color = color
        one.radius = radius
        one.offset = offset
        one.subShadow = subShadow?.copy() as? TextShadow
        
        return one
    }
    
    // MARK: - NSSecureCoding
    public static var supportsSecureCoding: Bool {
        return true
    }
}

/**
 TextDecorationLine objects are used by the NSAttributedString class cluster
 as the values for decoration line attributes (stored in the attributed string under
 the key named TextUnderlineAttributeName or TextStrikethroughAttributeName).
 
 When it's used as underline, the line is drawn below text glyphs;
 when it's used as strikethrough, the line is drawn above text glyphs.
 */
public class TextDecoration: NSObject, NSCoding, NSCopying, NSSecureCoding {
    
    /*/< line style */
    @objc public var style = TextLineStyle.none
    
    /*/< line width (nil means automatic width) */
    @objc public var width: NSNumber?
    
    /*/< line color (nil means automatic color) */
    @objc public var color: UIColor?
    
    ///< line shadow
    @objc public var shadow: TextShadow?
    
    
    @objc(decorationWithStyle:)
    public class func decoration(with style: TextLineStyle) -> TextDecoration {
        
        let one = TextDecoration()
        one.style = style
        
        return one
    }
    
    @objc(decorationWithStyle:width:color:)
    public class func decoration(with style: TextLineStyle, width: NSNumber?, color: UIColor?) -> TextDecoration {
        
        let one = TextDecoration()
        
        one.style = style
        one.width = width
        one.color = color
        
        return one
    }
    
    public override init() {
        self.style = TextLineStyle.single
        
        super.init()
    }
    
    // MARK: - NSCoding
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(style.rawValue, forKey: "style")
        aCoder.encode(width, forKey: "width")
        aCoder.encode(color, forKey: "color")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        
        style = TextLineStyle(rawValue: aDecoder.decodeInteger(forKey: "style"))!
        width = aDecoder.decodeObject(forKey: "width") as? NSNumber
        color = aDecoder.decodeObject(forKey: "color") as? UIColor
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let one = TextDecoration()
        one.style = style
        one.width = width
        one.color = color
        return one
    }
    
    // MARK: - NSSecureCoding
    public static var supportsSecureCoding: Bool {
        return true
    }
}


/**
 TextBorder objects are used by the NSAttributedString class cluster
 as the values for border attributes (stored in the attributed string under
 the key named TextBorderAttributeName or TextBackgroundBorderAttributeName).
 
 It can be used to draw a border around a range of text, or draw a background
 to a range of text.
 
 Example:
 ╭──────╮
 │ Text │
 ╰──────╯
 */
public class TextBorder: NSObject, NSCoding, NSCopying, NSSecureCoding {
    
    /*/< border line style */
    @objc public var lineStyle = TextLineStyle.single
    
    /*/< border line width */
    @objc public var strokeWidth: CGFloat = 0
    
    /*/< border line color */
    @objc public var strokeColor: UIColor?
    
    /*/< border line join : CGLineJoin */
    @objc public var lineJoin = CGLineJoin.miter
    
    /*/< border insets for text bounds */
    @objc public var insets = UIEdgeInsets.zero
    
    /*/< border corder radius */
    @objc public var cornerRadius: CGFloat = 0
    
    /*/< border shadow */
    @objc public var shadow: TextShadow?
    
    ///< inner fill color
    @objc public var fillColor: UIColor?
    
    
    @objc(borderWithLineStyle:lineWidth:strokeColor:)
    public class func border(with lineStyle: TextLineStyle, lineWidth: CGFloat, strokeColor: UIColor?) -> TextBorder {
        let one = TextBorder()
        one.lineStyle = lineStyle
        one.strokeWidth = lineWidth
        one.strokeColor = strokeColor
        return one
    }
    
    @objc(borderWithFillColor:cornerRadius:)
    public class func border(with fillColor: UIColor?, cornerRadius: CGFloat) -> TextBorder {
        let one = TextBorder()
        one.fillColor = fillColor
        one.cornerRadius = cornerRadius
        one.insets = UIEdgeInsets(top: -2, left: 0, bottom: 0, right: -2)
        return one
    }
    
    override public init() {
        super.init()
    }
    
    // MARK: - NSSecureCoding
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: - NSCoding
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(lineStyle.rawValue, forKey: "lineStyle")
        aCoder.encode(Float(strokeWidth), forKey: "strokeWidth")
        aCoder.encode(strokeColor, forKey: "strokeColor")
        aCoder.encode(lineJoin.rawValue, forKey: "lineJoin")
        aCoder.encode(insets, forKey: "insets")
        aCoder.encode(Float(cornerRadius), forKey: "cornerRadius")
        aCoder.encode(shadow, forKey: "shadow")
        aCoder.encode(fillColor, forKey: "fillColor")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        lineStyle = TextLineStyle(rawValue: aDecoder.decodeInteger(forKey: "lineStyle"))!
        strokeWidth = CGFloat(aDecoder.decodeFloat(forKey: "strokeWidth"))
        strokeColor = aDecoder.decodeObject(forKey: "strokeColor") as! UIColor?
        lineJoin = CGLineJoin(rawValue: aDecoder.decodeInt32(forKey: "lineJoin"))!  // join
        insets = aDecoder.decodeUIEdgeInsets(forKey: "insets")
        cornerRadius = CGFloat(aDecoder.decodeFloat(forKey: "cornerRadius"))
        shadow = aDecoder.decodeObject(forKey: "shadow") as! TextShadow?
        fillColor = aDecoder.decodeObject(forKey: "fillColor") as! UIColor?
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let one = TextBorder()
        one.lineStyle = lineStyle
        one.strokeWidth = strokeWidth
        one.strokeColor = strokeColor
        one.lineJoin = lineJoin
        one.insets = insets
        one.cornerRadius = cornerRadius
        one.shadow = shadow?.copy() as? TextShadow
        one.fillColor = fillColor
        return one
    }
}

/**
 TextAttachment objects are used by the NSAttributedString class cluster
 as the values for attachment attributes (stored in the attributed string under
 the key named TextAttachmentAttributeName).
 
 When display an attributed string which contains `TextAttachment` object,
 the content will be placed in text metric. If the content is `UIImage`,
 then it will be drawn to CGContext; if the content is `UIView` or `CALayer`,
 then it will be added to the text container's view or layer.
 */
public class TextAttachment: NSObject, NSCoding, NSCopying, NSSecureCoding {
    
    /*/< Supported type: UIImage, UIView, CALayer */
    @objc public var content: Any?
    
    /*/< Content display mode. */
    @objc public var contentMode = UIView.ContentMode.scaleToFill
    
    /*/< The insets when drawing content. */
    @objc public var contentInsets = UIEdgeInsets()
    
    ///< The user information dictionary.
    @objc public var userInfo: NSDictionary?
    
    public override init() {
        super.init()
    }
    
    @objc public class func attachmentWithContent(content: Any?) -> TextAttachment {
        let one = TextAttachment()
        one.content = content
        return one
    }
    
    // MARK: - NSCoding
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(content, forKey: "content")
        aCoder.encode(contentInsets, forKey: "contentInsets")
        aCoder.encode(userInfo, forKey: "userInfo")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        content = aDecoder.decodeObject(forKey: "content")
        contentInsets = aDecoder.decodeUIEdgeInsets(forKey: "contentInsets")
        userInfo = aDecoder.decodeObject(forKey: "userInfo") as? NSDictionary
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let one = TextAttachment()
        if let c = (content as? NSObject), c.responds(to: #selector(NSObject.copy)) {
            one.content = c.copy()
        } else {
            one.content = content
        }
        one.contentInsets = contentInsets
        one.userInfo = userInfo?.copy() as? NSDictionary
        return one
    }
    
    // MARK: - NSSecureCoding
    @objc public static var supportsSecureCoding: Bool {
        return true
    }
}

/**
 TextHighlight objects are used by the NSAttributedString class cluster
 as the values for touchable highlight attributes (stored in the attributed string
 under the key named TextHighlightAttributeName).
 
 When display an attributed string in `Label` or `TextView`, the range of
 highlight text can be toucheds down by users. If a range of text is turned into
 highlighted state, the `attributes` in `TextHighlight` will be used to modify
 (set or remove) the original attributes in the range for display.
 */
public class TextHighlight: NSObject, NSCoding, NSCopying, NSSecureCoding {
    
    /**
     Attributes that you can apply to text in an attributed string when highlight.
     Key:   Same as CoreText/Text Attribute Name.
     Value: Modify attribute value when highlight (nil for remove attribute).
     */
    @objc public private(set) var attributes = [NSAttributedString.Key : Any]()
    
    /**
     The user information dictionary, default is nil.
     */
    @objc public var userInfo: NSDictionary?
    
    /**
     Tap action when user tap the highlight, default is nil.
     If the value is nil, TextView or Label will ask it's delegate to handle the tap action.
     */
    @objc public var tapAction: (TextAction)?
    
    /**
     Long press action when user long press the highlight, default is nil.
     If the value is nil, TextView or Label will ask it's delegate to handle the long press action.
     */
    @objc public var longPressAction: (TextAction)?
    
    /**
     Creates a highlight object with specified attributes.
     
     @param attributes The attributes which will replace original attributes when highlight,
     If the value is NSNull, it will removed when highlight.
     */
    @objc(highlightWithAttributes:)
    public class func highlight(with attributes: [NSAttributedString.Key : Any]?) -> TextHighlight {
        let one = TextHighlight()
        if let attr = attributes {
            one.attributes = attr
        }
        return one
    }
    
    /**
     Convenience methods to create a default highlight with the specifeid background color.
     
     @param backgroundColor The background border color.
     */
    @objc(highlightWithBackgroundColor:)
    public class func highlight(with backgroundColor: UIColor?) -> TextHighlight {
        let highlightBorder = TextBorder()
        highlightBorder.insets = UIEdgeInsets(top: -2, left: -1, bottom: -2, right: -1)
        highlightBorder.cornerRadius = 3
        highlightBorder.fillColor = backgroundColor
        let one = TextHighlight()
        one.backgroundBorder = highlightBorder
        return one
    }
    
    override public init() {
        super.init()
    }
    
    public convenience init(attributes: [NSAttributedString.Key : Any]?) {
        self.init()
        if let attr = attributes {
            self.attributes = attr
        }
    }
    
    // MARK: - NSCoding
    public func encode(with aCoder: NSCoder) {
        let data = TextArchiver.archivedData(withRootObject: attributes)
        aCoder.encode(data, forKey: "attributes")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        
        let data = aDecoder.decodeObject(forKey: "attributes") as? Data
        if let attr = (TextUnarchiver.unarchiveObject(with: data!) as? [NSAttributedString.Key : Any]) {
            attributes = attr
        }
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let one = TextHighlight()
        one.attributes = self.attributes
        return one
    }
    
    // MARK: - NSSecureCoding
    @objc public static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: - Convenience methods below to set the `attributes`.
    
    @objc public func setTextAttribute(_ attribute: String, value: Any?) {
        attributes[NSAttributedString.Key(rawValue: attribute)] = value
    }
    
    @objc public var font: UIFont? {
        set(font) {
            if let f = font {
                let ctFont = CTFontCreateWithName(f.fontName as CFString, f.pointSize, nil)
                attributes[NSAttributedString.Key(rawValue: kCTFontAttributeName as String)] = ctFont
            } else {
                attributes[NSAttributedString.Key(rawValue: kCTFontAttributeName as String)] = nil
            }
        }
        get {
            return attributes[NSAttributedString.Key(rawValue: kCTFontAttributeName as String)] as? UIFont
        }
    }
    
    @objc public var color: UIColor? {
        set(color) {
            attributes[NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String)] = color?.cgColor
            attributes[NSAttributedString.Key.foregroundColor] = color
        }
        get {
            return attributes[NSAttributedString.Key.foregroundColor] as? UIColor
        }
    }
    
    @objc public var strokeWidth: NSNumber? {
        set(width) {
            attributes[NSAttributedString.Key(rawValue: kCTStrokeWidthAttributeName as String)] = width
        }
        get {
            return attributes[NSAttributedString.Key(rawValue: kCTStrokeWidthAttributeName as String)] as? NSNumber
        }
    }
    
    @objc public var strokeColor: UIColor? {
        set(color) {
            attributes[NSAttributedString.Key(rawValue: kCTStrokeColorAttributeName as String)] = color?.cgColor
            attributes[NSAttributedString.Key.strokeColor] = color
        }
        get {
            return attributes[NSAttributedString.Key.strokeColor] as? UIColor
        }
    }
    
    @objc public var shadow: TextShadow? {
        set(shadow) {
            setTextAttribute(TextAttribute.textShadowAttributeName, value: shadow)
        }
        get {
            fatalError("Here have not getter")
        }
    }
    
    @objc public var innerShadow: TextShadow? {
        set(shadow) {
            setTextAttribute(TextAttribute.textInnerShadowAttributeName, value: shadow)
        }
        get {
            fatalError("Here have not getter")
        }
    }
    
    @objc public var underline: TextDecoration? {
        set(underline) {
            setTextAttribute(TextAttribute.textUnderlineAttributeName, value: underline)
        }
        get {
            fatalError("Here have not getter")
        }
    }
    
    @objc public var strikethrough: TextDecoration? {
        set(strikethrough) {
            setTextAttribute(TextAttribute.textStrikethroughAttributeName, value: strikethrough)
        }
        get {
            fatalError("Here have not getter")
        }
    }
    
    @objc public var backgroundBorder: TextBorder? {
        set(border) {
            setTextAttribute(TextAttribute.textBackgroundBorderAttributeName, value: border)
        }
        get {
            fatalError("Here have not getter")
        }
    }
    
    @objc public var border: TextBorder? {
        set(border) {
            setTextAttribute(TextAttribute.textBorderAttributeName, value: border)
        }
        get {
            fatalError("Here have not getter")
        }
    }
    
    @objc public var attachment: TextAttachment? {
        set(attachment) {
            setTextAttribute(TextAttribute.textAttachmentAttributeName, value: attachment)
        }
        get {
            fatalError("Here have not getter")
        }
    }
}
