//
//  TextRubyAnnotation.swift
//  BSText
//
//  Created by BlueSky on 2018/10/24.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import CoreText

/**
 Wrapper for CTRubyAnnotationRef.
 
 Example:
 
 TextRubyAnnotation *ruby = [TextRubyAnnotation new];
 ruby.textBefore = @"zhù yīn";
 CTRubyAnnotationRef ctRuby = ruby.ctRubyAnnotation;
 
 */
public class TextRubyAnnotation: NSObject, NSCopying, NSCoding, NSSecureCoding {
    
    /// Specifies how the ruby text and the base text should be aligned relative to each other.
    @objc public var alignment = CTRubyAlignment.auto
    
    /// Specifies how the ruby text can overhang adjacent characters.
    @objc public var overhang = CTRubyOverhang.auto
    
    /// Specifies the size of the annotation text as a percent of the size of the base text.
    @objc public var sizeFactor: CGFloat = 0.5
    
    /// The ruby text is positioned before the base text;
    /// i.e. above horizontal text and to the right of vertical text.
    @objc public var textBefore: String?
    
    /// The ruby text is positioned after the base text;
    /// i.e. below horizontal text and to the left of vertical text.
    @objc public var textAfter: String?
    
    /// The ruby text is positioned to the right of the base text whether it is horizontal or vertical.
    /// This is the way that Bopomofo annotations are attached to Chinese text in Taiwan.
    @objc public var textInterCharacter: String?
    
    /// The ruby text follows the base text with no special styling.
    @objc public var textInline: String?
    
    public override init() {
        super.init()
    }
    
    /**
     Create a ruby object from CTRuby object.
     
     @param ctRuby  A CTRuby object.
     
     @return A ruby object, or nil when an error occurs.
     */
    @objc(rubyWithCTRubyRef:)
    public class func ruby(with ctRuby: CTRubyAnnotation) -> TextRubyAnnotation {
        
        let one = TextRubyAnnotation()
        
        one.alignment = CTRubyAnnotationGetAlignment(ctRuby)
        one.overhang = CTRubyAnnotationGetOverhang(ctRuby)
        one.sizeFactor = CTRubyAnnotationGetSizeFactor(ctRuby)
        one.textBefore = (CTRubyAnnotationGetTextForPosition(ctRuby, CTRubyPosition.before)) as String?
        one.textAfter = (CTRubyAnnotationGetTextForPosition(ctRuby, CTRubyPosition.after)) as String?
        one.textInterCharacter = (CTRubyAnnotationGetTextForPosition(ctRuby, CTRubyPosition.interCharacter)) as String?
        one.textInline = (CTRubyAnnotationGetTextForPosition(ctRuby, CTRubyPosition.inline)) as String?
        
        return one
    }
    
    
    /**
     Create a CTRuby object from the instance.
     
     @return A new CTRuby object, or NULL when an error occurs.
     The returned value should be release after used.
     */
    @objc public func ctRubyAnnotation() -> CTRubyAnnotation? {
        
        let hiragana = (textBefore ?? "") as CFString
        let furigana: UnsafeMutablePointer<CFTypeRef> = UnsafeMutablePointer<CFTypeRef>.allocate(capacity: Int(CTRubyPosition.count.rawValue))
        defer {
            furigana.deallocate()
        }

        furigana.initialize(repeating: ("" as CFString), count: 4)
        furigana[Int(CTRubyPosition.before.rawValue)] = hiragana
        furigana[Int(CTRubyPosition.after.rawValue)] = (textAfter ?? "") as CFString
        furigana[Int(CTRubyPosition.interCharacter.rawValue)] = (textInterCharacter ?? "") as CFString
        furigana[Int(CTRubyPosition.inline.rawValue)] = (textInline ?? "") as CFString

        var ruby: CTRubyAnnotation!
        furigana.withMemoryRebound(to: Optional<Unmanaged<CFString>>.self, capacity: 4) { ptr in
            ruby = CTRubyAnnotationCreate(alignment, overhang, sizeFactor, ptr)
        }
        
        return ruby
    }
    
    // MARK: - NSCopying
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let one = TextRubyAnnotation()
        one.alignment = alignment
        one.overhang = overhang
        one.sizeFactor = sizeFactor
        one.textBefore = textBefore
        one.textAfter = textAfter
        one.textInterCharacter = textInterCharacter
        one.textInline = textInline
        return one
    }
    
    // MARK: - NSCoding
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(alignment.rawValue, forKey: "alignment")
        aCoder.encode(overhang.rawValue, forKey: "overhang")
        aCoder.encode(Float(sizeFactor), forKey: "sizeFactor")
        aCoder.encode(textBefore, forKey: "textBefore")
        aCoder.encode(textAfter, forKey: "textAfter")
        aCoder.encode(textInterCharacter, forKey: "textInterCharacter")
        aCoder.encode(textInline, forKey: "textInline")
    }
    
    @objc required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
        alignment = CTRubyAlignment(rawValue: UInt8(aDecoder.decodeInt32(forKey: "alignment")))!
        overhang = CTRubyOverhang(rawValue: UInt8(aDecoder.decodeInt32(forKey: "overhang")))!
        sizeFactor = CGFloat(aDecoder.decodeFloat(forKey: "sizeFactor"))
        textBefore = aDecoder.decodeObject(forKey: "textBefore") as? String
        textAfter = aDecoder.decodeObject(forKey: "textAfter") as? String
        textInterCharacter = aDecoder.decodeObject(forKey: "textInterCharacter") as? String
        textInline = aDecoder.decodeObject(forKey: "textInline") as? String
    }
    
    // MARK: - NSSecureCoding
    @objc public static var supportsSecureCoding: Bool {
        return true
    }
}
