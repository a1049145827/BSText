//
//  TextUtilities.swift
//  BSText
//
//  Created by BlueSky on 2018/10/23.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import Accelerate

public class TextUtilities: NSObject {
    
    // MARK: - getter
    @objc public static let isAppExtension: Bool = {
        
        let cls: AnyClass? = NSClassFromString("UIApplication")
        if cls == nil || !(cls?.responds(to: #selector(getter: UIApplication.shared)) ?? false) {
            return true
        }
        if Bundle.main.bundlePath.hasSuffix(".appex") {
            return true
        }
        
        return false
    }()
    
    @objc public static var sharedApplication: UIApplication? {
        
        return TextUtilities.isAppExtension ? nil : UIApplication.shared
    }
    
    public static func numberSwap<T>(_ a: inout T, b: inout T) {
        (a, b) = (b, a)
    }
    
    @objc public static func textClamp(x: CGFloat, low: CGFloat, high: CGFloat) -> CGFloat {
        return (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
    }
    
    /**
     Whether the character is 'line break char':
     U+000D (\\r or CR)
     U+2028 (Unicode line separator)
     U+000A (\\n or LF)
     U+2029 (Unicode paragraph separator)
     
     @param c  A character
     @return YES or NO.
     */
    @objc @inline(__always) public static func textIsLinebreakChar(_ c: unichar) -> Bool {
        switch c {
        case unichar(0x000D), unichar(0x2028), unichar(0x000A), unichar(0x2029):
            return true
        default:
            return false
        }
    }
    
    /**
     Whether the string is a 'line break':
     U+000D (\\r or CR)
     U+2028 (Unicode line separator)
     U+000A (\\n or LF)
     U+2029 (Unicode paragraph separator)
     \\r\\n, in that order (also known as CRLF)
     
     @param str A string
     @return YES or NO.
     */
    @objc @inline(__always) public static func textIsLinebreakString(_ str: String?) -> Bool {
        
        guard let s = str as NSString?, s.length > 0, s.length <= 2 else {
            return false
        }
        
        if s.length == 1 {
            let c = unichar(s.character(at: 0))
            return TextUtilities.textIsLinebreakChar((c))
        } else {
            return (s.substring(to: 1) == "\r") && (s.substring(from: 1) == "\n")
        }
    }
    
    /**
     If the string has a 'line break' suffix, return the 'line break' length.
     
     @param str  A string.
     @return The length of the tail line break: 0, 1 or 2.
     */
    @objc @inline(__always) public static func textLinebreakTailLength(_ str: String?) -> Int {
        
        guard let s = str as NSString?, s.length > 0 else {
            return 0
        }
        if s.length == 1 {
            return TextUtilities.textIsLinebreakChar(s.character(at: 0)) ? 1 : 0
        } else {
            let c2 = s.character(at: s.length - 1)
            if TextUtilities.textIsLinebreakChar((c2)) {
                let c1 = s.character(at: s.length - 2)
                if String(c1) == "\r" && String(c2) == "\n" {
                    return 2
                } else {
                    return 1
                }
            } else {
                return 0
            }
        }
    }
    
    /**
     Convert `UIDataDetectorTypes` to `NSTextCheckingType`.
     
     @param types  The `UIDataDetectorTypes` type.
     @return The `NSTextCheckingType` type.
     */
    @objc(textCheckingTypeFromUIDataDetectorType:)
    @inline(__always) public static func textCheckingType(from types: UIDataDetectorTypes) -> NSTextCheckingResult.CheckingType {
        
        var t = NSTextCheckingResult.CheckingType(rawValue: 0)
        if types.rawValue & UIDataDetectorTypes.phoneNumber.rawValue != 0 {
            t.insert(.phoneNumber)
        }
        if types.rawValue & UIDataDetectorTypes.link.rawValue != 0 {
            t.insert(.link)
        }
        if types.rawValue & UIDataDetectorTypes.address.rawValue != 0 {
            t.insert(.address)
        }
        if types.rawValue & UIDataDetectorTypes.calendarEvent.rawValue != 0 {
            t.insert(.date)
        }
        return t
    }
    
    /**
     Whether the font is `AppleColorEmoji` font.
     
     @param font  A font.
     @return YES: the font is Emoji, NO: the font is not Emoji.
     */
    @objc @inline(__always) public static func textUIFontIsEmoji(_ font: UIFont?) -> Bool {
        
        return font?.fontName == "AppleColorEmoji"
    }
    
    /**
     Whether the font is `AppleColorEmoji` font.
     
     @param font  A font.
     @return YES: the font is Emoji, NO: the font is not Emoji.
     */
    @objc @inline(__always) public static func textCTFontIsEmoji(_ font: CTFont?) -> Bool {
        
        guard let _ = font else {
            return false
        }
        
        let name = CTFontCopyPostScriptName(font!)
        if CFEqual("AppleColorEmoji" as CFTypeRef, name) {
            return true
        }
        
        return false
    }
    
    /**
     Whether the font is `AppleColorEmoji` font.
     
     @param font  A font.
     @return YES: the font is Emoji, NO: the font is not Emoji.
     */
    @objc @inline(__always) public static func textCGFontIsEmoji(_ font: CGFont?) -> Bool {
        
        let name = font?.postScriptName
        if let n = name, CFEqual("AppleColorEmoji" as CFTypeRef, n) {
            return true
        }
        
        return false
    }
    
    /**
     Whether the font contains color bitmap glyphs.
     
     @discussion Only `AppleColorEmoji` contains color bitmap glyphs in iOS system fonts.
     @param font  A font.
     @return YES: the font contains color bitmap glyphs, NO: the font has no color bitmap glyph.
     */
    @objc @inline(__always) public static func textCTFontContainsColorBitmapGlyphs(_ font: CTFont?) -> Bool {
        
        guard let f = font else {
            return false
        }
        return (CTFontGetSymbolicTraits(f).rawValue & CTFontSymbolicTraits.traitColorGlyphs.rawValue) != 0
    }
    
    /**
     Get the character set which should rotate in vertical form.
     @return The shared character set.
     */
    @objc public static let textVerticalFormRotateCharacterSet: NSMutableCharacterSet = {
        
        let tmpSet = NSMutableCharacterSet()
        tmpSet.addCharacters(in: NSRange(location: 0x1100, length: 256)) // Hangul Jamo
        tmpSet.addCharacters(in: NSRange(location: 0x2460, length: 160)) // Enclosed Alphanumerics
        tmpSet.addCharacters(in: NSRange(location: 0x2600, length: 256)) // Miscellaneous Symbols
        tmpSet.addCharacters(in: NSRange(location: 0x2700, length: 192)) // Dingbats
        tmpSet.addCharacters(in: NSRange(location: 0x2e80, length: 128)) // CJK Radicals Supplement
        tmpSet.addCharacters(in: NSRange(location: 0x2f00, length: 224)) // Kangxi Radicals
        tmpSet.addCharacters(in: NSRange(location: 0x2ff0, length: 16)) // Ideographic Description Characters
        tmpSet.addCharacters(in: NSRange(location: 0x3000, length: 64)) // CJK Symbols and Punctuation
        tmpSet.removeCharacters(in: NSRange(location: 0x3008, length: 10))
        tmpSet.removeCharacters(in: NSRange(location: 0x3014, length: 12))
        tmpSet.addCharacters(in: NSRange(location: 0x3040, length: 96)) // Hiragana
        tmpSet.addCharacters(in: NSRange(location: 0x30a0, length: 96)) // Katakana
        tmpSet.addCharacters(in: NSRange(location: 0x3100, length: 48)) // Bopomofo
        tmpSet.addCharacters(in: NSRange(location: 0x3130, length: 96)) // Hangul Compatibility Jamo
        tmpSet.addCharacters(in: NSRange(location: 0x3190, length: 16)) // Kanbun
        tmpSet.addCharacters(in: NSRange(location: 0x31a0, length: 32)) // Bopomofo Extended
        tmpSet.addCharacters(in: NSRange(location: 0x31c0, length: 48)) // CJK Strokes
        tmpSet.addCharacters(in: NSRange(location: 0x31f0, length: 16)) // Katakana Phonetic Extensions
        tmpSet.addCharacters(in: NSRange(location: 0x3200, length: 256)) // Enclosed CJK Letters and Months
        tmpSet.addCharacters(in: NSRange(location: 0x3300, length: 256)) // CJK Compatibility
        tmpSet.addCharacters(in: NSRange(location: 0x3400, length: 2582)) // CJK Unified Ideographs Extension A
        tmpSet.addCharacters(in: NSRange(location: 0x4e00, length: 20941)) // CJK Unified Ideographs
        tmpSet.addCharacters(in: NSRange(location: 0xac00, length: 11172)) // Hangul Syllables
        tmpSet.addCharacters(in: NSRange(location: 0xd7b0, length: 80)) // Hangul Jamo Extended-B
        tmpSet.addCharacters(in: "") // U+F8FF (Private Use Area)
        tmpSet.addCharacters(in: NSRange(location: 0xf900, length: 512)) // CJK Compatibility Ideographs
        tmpSet.addCharacters(in: NSRange(location: 0xfe10, length: 16)) // Vertical Forms
        tmpSet.addCharacters(in: NSRange(location: 0xff00, length: 240)) // Halfwidth and Fullwidth Forms
        tmpSet.addCharacters(in: NSRange(location: 0x1f200, length: 256)) // Enclosed Ideographic Supplement
        tmpSet.addCharacters(in: NSRange(location: 0x1f300, length: 768)) // Enclosed Ideographic Supplement
        tmpSet.addCharacters(in: NSRange(location: 0x1f600, length: 80)) // Emoticons (Emoji)
        tmpSet.addCharacters(in: NSRange(location: 0x1f680, length: 128)) // Transport and Map Symbols
        // See http://unicode-table.com/ for more information.
        
        return tmpSet
    }()
    
    /**
     Whether the glyph is bitmap.
     
     @param font  The glyph's font.
     @param glyph The glyph which is created from the specified font.
     @return YES: the glyph is bitmap, NO: the glyph is vector.
     */
    @objc @inline(__always) public static func textCGGlyphIsBitmap(_ font: CTFont?, glyph: CGGlyph) -> Bool {
        
        if !TextUtilities.textCTFontContainsColorBitmapGlyphs(font) {
            return false
        }
        if CTFontCreatePathForGlyph(font!, glyph, nil) != nil {
            return false
        }
        
        return true
    }
    
    /**
     Get the `AppleColorEmoji` font's ascent with a specified font size.
     It may used to create custom emoji.
     
     @param fontSize  The specified font size.
     @return The font ascent.
     */
    @objc(textEmojiGetAscentWithFontSize:)
    @inline(__always) public static func textEmojiGetAscent(with fontSize: CGFloat) -> CGFloat {
        if fontSize < 16 {
            return 1.25 * fontSize
        } else if 16 <= fontSize && fontSize <= 24 {
            return 0.5 * fontSize + 12
        } else {
            return fontSize
        }
    }
    
    /**
     Get the `AppleColorEmoji` font's descent with a specified font size.
     It may used to create custom emoji.
     
     @param fontSize  The specified font size.
     @return The font descent.
     */
    @objc(textEmojiGetDescentWithFontSize:)
    @inline(__always) public static func textEmojiGetDescent(with fontSize: CGFloat) -> CGFloat {
        if fontSize < 16 {
            return 0.390625 * fontSize
        } else if 16 <= fontSize && fontSize <= 24 {
            return 0.15625 * fontSize + 3.75
        } else {
            return 0.3125 * fontSize
        }
    }
    
    /**
     Get the `AppleColorEmoji` font's glyph bounding rect with a specified font size.
     It may used to create custom emoji.
     
     @param fontSize  The specified font size.
     @return The font glyph bounding rect.
     */
    @objc(textEmojiGetGlyphBoundingRectWithFontSize:)
    @inline(__always) public static func textEmojiGetGlyphBoundingRect(with fontSize: CGFloat) -> CGRect {
        
        var rect = CGRect(x: 0.75, y: 0, width: 0, height: 0)
        
        rect.size.height = textEmojiGetAscent(with: fontSize)
        rect.size.width = rect.size.height
        
        if fontSize < 16 {
            rect.origin.y = -0.2525 * fontSize
        } else if 16 <= fontSize && fontSize <= 24 {
            rect.origin.y = 0.1225 * fontSize - 6
        } else {
            rect.origin.y = -0.1275 * fontSize
        }
        return rect
    }
    
    /**
     Get the character set which should rotate and move in vertical form.
     @return The shared character set.
     */
    @objc public static let textVerticalFormRotateAndMoveCharacterSet: NSCharacterSet = {
        
        return NSCharacterSet(charactersIn: "，。、．")
    }()
    
    /// Convert degrees to radians. textDegreesToRadians:
    @objc(textRadiansFromDegrees:)
    @inline(__always) public static func textRadians(from degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180
    }
    
    /// Convert radians to degrees. textRadiansToDegrees:
    @objc(textDegreesFromRadians:)
    @inline(__always) public static func textDegrees(from radians: CGFloat) -> CGFloat {
        return radians * 180 / .pi
    }
    
    /// Get the transform rotation.
    /// @return the rotation in radians [-PI, PI] ([-180°, 180°])
    @objc(textCGAffineTransformGetRotation:)
    @inline(__always) public static func textCGAffineTransformGetRotation(_ transform: CGAffineTransform) -> CGFloat {
        return atan2(transform.b, transform.a)
    }
    
    /// Get the transform's scale.x
    @objc(textCGAffineTransformGetScaleX:)
    @inline(__always) public static func textCGAffineTransformGetScaleX(_ transform: CGAffineTransform) -> CGFloat {
        return sqrt(transform.a * transform.a + transform.c * transform.c)
    }
    
    /// Get the transform's scale.y
    @objc(textCGAffineTransformGetScaleY:)
    @inline(__always) public static func textCGAffineTransformGetScaleY(_ transform: CGAffineTransform) -> CGFloat {
        return sqrt(transform.b * transform.b + transform.d * transform.d)
    }
    /// Get the transform's translate.x
    @objc(textCGAffineTransformGetTranslateX:)
    @inline(__always) public static func textCGAffineTransformGetTranslateX(_ transform: CGAffineTransform) -> CGFloat {
        return transform.tx
    }
    /// Get the transform's translate.y
    @objc(textCGAffineTransformGetTranslateY:)
    @inline(__always) public static func textCGAffineTransformGetTranslateY(_ transform: CGAffineTransform) -> CGFloat {
        return transform.ty
    }
    
    /// 矩阵求逆
    private static func matrix_invert(_ matrix: inout [Double]) -> Int {
        
        // 这样写矩阵中总元素个数大于 8 的时候会发生越界导致 Crash
//        var pivot : __CLPK_integer = 0
//        var workspace = 0
        // 这样写个数不受限制
        let pivot = UnsafeMutablePointer<__CLPK_integer>.allocate(capacity: matrix.count)
        let workspace = UnsafeMutablePointer<Double>.allocate(capacity: matrix.count)
        defer {
            pivot.deallocate()
            workspace.deallocate()
        }
        
        var error: __CLPK_integer = 0
        
        var n = __CLPK_integer(sqrt(Double(matrix.count)))
        var m = n
        var lda = n
        
        dgetrf_(&m, &n, &matrix, &lda, pivot, &error)
        
        if error != 0 {
            return Int(error)
        }
        
        dgetri_(&m, &matrix, &lda, pivot, workspace, &n, &error)
        
        return Int(error)
    }
    
    /**
     If you have 3 pair of points transformed by a same CGAffineTransform:
     p1 (transform->) q1
     p2 (transform->) q2
     p3 (transform->) q3
     This method returns the original transform matrix from these 3 pair of points.
     
     @see http://stackoverflow.com/questions/13291796/calculate-values-for-a-cgaffinetransform-from-three-points-in-each-of-two-uiview
     */
    @objc(textCGAffineTransformGetFromPoints::)
    public static func textCGAffineTransformGet(from before: [CGPoint], _ after: [CGPoint]) -> CGAffineTransform {
        
        var p1: CGPoint, p2: CGPoint, p3: CGPoint, q1: CGPoint, q2: CGPoint, q3: CGPoint
        
        p1 = before[0]
        p2 = before[1]
        p3 = before[2]
        q1 = after[0]
        q2 = after[1]
        q3 = after[2]
        
        var A = [Double](repeating: 0, count: 36)
        A[0] = Double(p1.x); A[1] = Double(p1.y); A[2] = 0; A[3] = 0; A[4] = 1; A[5] = 0
        A[6] = 0; A[7] = 0; A[8] = Double(p1.x); A[9] = Double(p1.y); A[10] = 0; A[11] = 1
        A[12] = Double(p2.x); A[13] = Double(p2.y); A[14] = 0; A[15] = 0; A[16] = 1; A[17] = 0
        A[18] = 0; A[19] = 0; A[20] = Double(p2.x); A[21] = Double(p2.y); A[22] = 0; A[23] = 1
        A[24] = Double(p3.x); A[25] = Double(p3.y); A[26] = 0; A[27] = 0; A[28] = 1; A[29] = 0
        A[30] = 0; A[31] = 0; A[32] = Double(p3.x); A[33] = Double(p3.y); A[34] = 0; A[35] = 1
        
        let error = matrix_invert(&A)
        if error != 0 {
            return .identity
        }
        var B = [Double](repeating: 0, count: 6)
        B[0] = Double(q1.x)
        B[1] = Double(q1.y)
        B[2] = Double(q2.x)
        B[3] = Double(q2.y)
        B[4] = Double(q3.x)
        B[5] = Double(q3.y)
        var M = [Double](repeating: 0, count: 6)
        M[0] = A[0] * B[0] + A[1] * B[1] + A[2] * B[2] + A[3] * B[3] + A[4] * B[4] + A[5] * B[5]
        M[1] = A[6] * B[0] + A[7] * B[1] + A[8] * B[2] + A[9] * B[3] + A[10] * B[4] + A[11] * B[5]
        M[2] = A[12] * B[0] + A[13] * B[1] + A[14] * B[2] + A[15] * B[3] + A[16] * B[4] + A[17] * B[5]
        M[3] = A[18] * B[0] + A[19] * B[1] + A[20] * B[2] + A[21] * B[3] + A[22] * B[4] + A[23] * B[5]
        M[4] = A[24] * B[0] + A[25] * B[1] + A[26] * B[2] + A[27] * B[3] + A[28] * B[4] + A[29] * B[5]
        M[5] = A[30] * B[0] + A[31] * B[1] + A[32] * B[2] + A[33] * B[3] + A[34] * B[4] + A[35] * B[5]
        
        let transform = CGAffineTransform(a: CGFloat(M[0]), b: CGFloat(M[2]), c: CGFloat(M[1]), d: CGFloat(M[3]), tx: CGFloat(M[4]), ty: CGFloat(M[5]))
        
        return transform
    }
    
    /// Get the transform which can converts a point from the coordinate system of a given view to another.
    @objc(textCGAffineTransformGetFromView:to:)
    public static func textCGAffineTransformGet(from: UIView?, to: UIView?) -> CGAffineTransform {
        guard let _ = from, let _ = to else {
            return .identity
        }
        var before = [CGPoint](repeating: CGPoint.zero, count: 3)
        var after = [CGPoint](repeating: CGPoint.zero, count: 3)
        before[0] = CGPoint(x: 0, y: 0)
        before[1] = CGPoint(x: 0, y: 1)
        before[2] = CGPoint(x: 1, y: 0)
        after[0] = from!.bs_convertPoint(before[0], toViewOrWindow: to)
        after[1] = from!.bs_convertPoint(before[1], toViewOrWindow: to)
        after[2] = from!.bs_convertPoint(before[2], toViewOrWindow: to)
        
        return textCGAffineTransformGet(from: before, after)
    }
    
    /// Create a skew transform.
    @objc @inline(__always) public static func textCGAffineTransformMakeSkew(_ x: CGFloat, y: CGFloat) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity
        transform.c = -x
        transform.b = y
        return transform
    }
    
    /// Negates/inverts a UIEdgeInsets.
    @objc @inline(__always) public static func textUIEdgeInsetsInvert(_ insets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: -insets.top, left: -insets.left, bottom: -insets.bottom, right: -insets.right)
    }
    
    static var textCAGravityToUIViewContentModeDic = [CALayerContentsGravity.center: UIView.ContentMode.center.rawValue,
                                                      CALayerContentsGravity.top: UIView.ContentMode.top.rawValue,
                                                      CALayerContentsGravity.bottom: UIView.ContentMode.bottom.rawValue,
                                                      CALayerContentsGravity.left: UIView.ContentMode.left.rawValue,
                                                      CALayerContentsGravity.right: UIView.ContentMode.right.rawValue,
                                                      CALayerContentsGravity.topLeft: UIView.ContentMode.topLeft.rawValue,
                                                      CALayerContentsGravity.topRight: UIView.ContentMode.topRight.rawValue,
                                                      CALayerContentsGravity.bottomLeft: UIView.ContentMode.bottomLeft.rawValue,
                                                      CALayerContentsGravity.bottomRight: UIView.ContentMode.bottomRight.rawValue,
                                                      CALayerContentsGravity.resize: UIView.ContentMode.scaleToFill.rawValue,
                                                      CALayerContentsGravity.resizeAspect: UIView.ContentMode.scaleAspectFit.rawValue,
                                                      CALayerContentsGravity.resizeAspectFill: UIView.ContentMode.scaleAspectFill.rawValue]
    
    @objc public static func textCAGravityToUIViewContentMode(_ gravity: CALayerContentsGravity?) -> UIView.ContentMode {
        
        guard let g = gravity else {
            return .scaleToFill
        }
        
        return (UIView.ContentMode(rawValue: textCAGravityToUIViewContentModeDic[g]!))!
    }
    
    /// Convert UIViewContentMode to CALayer's gravity string.
    @objc public static func textUIViewContentModeToCAGravity(contentMode: UIView.ContentMode) -> String {
        switch contentMode {
        case .scaleToFill:
            return CALayerContentsGravity.resize.rawValue
        case .scaleAspectFit:
            return CALayerContentsGravity.resizeAspect.rawValue
        case .scaleAspectFill:
            return CALayerContentsGravity.resizeAspectFill.rawValue
        case .redraw:
            return CALayerContentsGravity.resize.rawValue
        case .center:
            return CALayerContentsGravity.center.rawValue
        case .top:
            return CALayerContentsGravity.top.rawValue
        case .bottom:
            return CALayerContentsGravity.bottom.rawValue
        case .left:
            return CALayerContentsGravity.left.rawValue
        case .right:
            return CALayerContentsGravity.right.rawValue
        case .topLeft:
            return CALayerContentsGravity.topLeft.rawValue
        case .topRight:
            return CALayerContentsGravity.topRight.rawValue
        case .bottomLeft:
            return CALayerContentsGravity.bottomLeft.rawValue
        case .bottomRight:
            return CALayerContentsGravity.bottomRight.rawValue
        default:
            return CALayerContentsGravity.resize.rawValue
        }
    }
    
    /**
     Returns a rectangle to fit the `rect` with specified content mode.
     
     @param rect The constrant rect
     @param size The content size
     @param contentMode The content mode
     @return A rectangle for the given content mode.
     @discussion UIViewContentModeRedraw is same as UIViewContentModeScaleToFill.
     */
    @objc(textCGRectFitWithContentMode:rect:size:)
    public static func textCGRectFit(with contentMode: UIView.ContentMode, rect: CGRect, size: CGSize) -> CGRect {
        
        var tmprect = rect.standardized
        var size = size
        
        size.width = size.width < 0 ? -size.width : size.width
        size.height = size.height < 0 ? -size.height : size.height
        let center = CGPoint(x: tmprect.midX, y: tmprect.midY)
        switch contentMode {
        case .scaleAspectFit, .scaleAspectFill:
            if tmprect.size.width < 0.01 || tmprect.size.height < 0.01 || size.width < 0.01 || size.height < 0.01 {
                tmprect.origin = center
                tmprect.size = CGSize.zero
            } else {
                var scale: CGFloat
                if contentMode == .scaleAspectFit {
                    if size.width / size.height < tmprect.size.width / tmprect.size.height {
                        scale = tmprect.size.height / size.height
                    } else {
                        scale = tmprect.size.width / size.width
                    }
                } else {
                    if size.width / size.height < tmprect.size.width / tmprect.size.height {
                        scale = tmprect.size.width / size.width
                    } else {
                        scale = tmprect.size.height / size.height
                    }
                }
                size.width *= scale
                size.height *= scale
                tmprect.size = size
                tmprect.origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
            }
        case .center:
            tmprect.size = size
            tmprect.origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        case .top:
            tmprect.origin.x = center.x - size.width * 0.5
            tmprect.size = size
        case .bottom:
            tmprect.origin.x = center.x - size.width * 0.5
            tmprect.origin.y += tmprect.size.height - size.height
            tmprect.size = size
        case .left:
            tmprect.origin.y = center.y - size.height * 0.5
        case .right:
            tmprect.origin.y = center.y - size.height * 0.5
            tmprect.origin.x += tmprect.size.width - size.width
            tmprect.size = size
        case .topLeft:
            tmprect.size = size
        case .topRight:
            tmprect.origin.x += tmprect.size.width - size.width
            tmprect.size = size
        case .bottomLeft:
            tmprect.origin.y += tmprect.size.height - size.height
            tmprect.size = size
        case .bottomRight:
            tmprect.origin.x += tmprect.size.width - size.width
            tmprect.origin.y += tmprect.size.height - size.height
            tmprect.size = size
        case .scaleToFill, .redraw:
            return rect
        default:
            return rect
        }
        return tmprect
    }
    
    /// Get main screen's scale.
    @objc public static var textScreenScale = UIScreen.main.scale
    
    /// Get main screen's size. Height is always larger than width.
    @objc public static var textScreenSize = CGSize(width: min(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width), height: max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width))
    
    /// Convert point to pixel.
    @objc(textCGFloatToPixel:)
    @inline(__always) public static func textCGFloat(toPixel value: CGFloat) -> CGFloat {
        return value * textScreenScale
    }
    
    /// Convert pixel to point.
    @objc(textCGFloatFromPixel:)
    @inline(__always) public static func textCGFloat(fromPixel value: CGFloat) -> CGFloat {
        return value / textScreenScale
    }
    
    /// floor point value for pixel-aligned
    @objc(textCGFloatPixelFloor:)
    @inline(__always) public static func textCGFloat(pixelFloor value: CGFloat) -> CGFloat {
        let scale = textScreenScale
        return floor(value * scale) / scale
    }
    
    /// round point value for pixel-aligned
    @objc(textCGFloatPixelRound:)
    @inline(__always) public static func textCGFloat(pixelRound value: CGFloat) -> CGFloat {
        let scale = textScreenScale
        return CGFloat(round(Double(value * scale)) / Double(scale))
    }
    
    /// ceil point value for pixel-aligned
    @objc(textCGFloatPixelCeil:)
    @inline(__always) public static func textCGFloat(pixelCeil value: CGFloat) -> CGFloat {
        let scale = textScreenScale
        return ceil(value * scale) / scale
    }
    
    /// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
    @objc(textCGFloatPixelHalf:)
    @inline(__always) public static func textCGFloat(pixelHalf value: CGFloat) -> CGFloat {
        let scale = textScreenScale
        return (floor(value * scale) + 0.5) / scale
    }
    
    /// floor point value for pixel-aligned
    @objc(textCGPointPixelFloor:)
    @inline(__always) public static func TextCGPoint(pixelFloor point: CGPoint) -> CGPoint {
        let scale = textScreenScale
        return CGPoint(x: floor(point.x * scale) / scale, y: floor(point.y * scale) / scale)
    }
    
    /// round point value for pixel-aligned
    @objc(textCGPointPixelRound:)
    @inline(__always) public static func TextCGPoint(pixelRound point: CGPoint) -> CGPoint {
        let scale = Double(textScreenScale)
        return CGPoint(x: CGFloat(round(Double(point.x) * scale) / scale), y: CGFloat(round(Double(point.y) * scale) / scale))
    }
    
    /// ceil point value for pixel-aligned
    @objc(textCGPointPixelCeil:)
    @inline(__always) public static func TextCGPoint(pixelCeil point: CGPoint) -> CGPoint {
        let scale = textScreenScale
        return CGPoint(x: ceil(point.x * scale) / scale, y: ceil(point.y * scale) / scale)
    }
    
    /// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
    @objc(textCGPointPixelHalf:)
    @inline(__always) public static func TextCGPoint(pixelHalf point: CGPoint) -> CGPoint {
        let scale = textScreenScale
        return CGPoint(x: (floor(point.x * scale) + 0.5) / scale, y: (floor(point.y * scale) + 0.5) / scale)
    }
    
    /// floor point value for pixel-aligned
    @objc(textCGSizePixelFloor:)
    @inline(__always) public static func TextCGSize(pixelFloor size: CGSize) -> CGSize {
        let scale = textScreenScale
        return CGSize(width: floor(size.width * scale) / scale, height: floor(size.height * scale) / scale)
    }
    
    /// round point value for pixel-aligned
    @objc(textCGSizePixelRound:)
    @inline(__always) public static func TextCGSize(pixelRound size: CGSize) -> CGSize {
        let scale = textScreenScale
        return CGSize(width: CGFloat(round(Double(size.width * scale)) / Double(scale)), height: CGFloat(round(Double(size.height * scale)) / Double(scale)))
    }
    
    /// ceil point value for pixel-aligned
    @objc(textCGSizePixelCeil:)
    @inline(__always) public static func TextCGSize(pixelCeil size: CGSize) -> CGSize {
        let scale = textScreenScale
        return CGSize(width: ceil(size.width * scale) / scale, height: ceil(size.height * scale) / scale)
    }
    
    /// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
    @objc(textCGSizePixelHalf:)
    @inline(__always) public static func TextCGSize(pixelHalf size: CGSize) -> CGSize {
        let scale = textScreenScale
        return CGSize(width: (floor(size.width * scale) + 0.5) / scale, height: (floor(size.height * scale) + 0.5) / scale)
    }
    
    /// floor point value for pixel-aligned
    @objc(textCGRectPixelFloor:)
    @inline(__always) public static func textCGRect(pixelFloor rect: CGRect) -> CGRect {
        let origin: CGPoint = TextCGPoint(pixelCeil: rect.origin)
        let corner = TextCGPoint(pixelFloor: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        var ret = CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
        if ret.size.width < 0 {
            ret.size.width = 0
        }
        if ret.size.height < 0 {
            ret.size.height = 0
        }
        return ret
    }
    
    /// round point value for pixel-aligned
    @objc(textCGRectPixelRound:)
    @inline(__always) public static func textCGRect(pixelRound rect: CGRect) -> CGRect {
        let origin: CGPoint = TextCGPoint(pixelRound: rect.origin)
        let corner = TextCGPoint(pixelRound: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        return CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
    }
    
    /// ceil point value for pixel-aligned
    @objc(textCGRectPixelCeil:)
    @inline(__always) public static func textCGRect(pixelCeil rect: CGRect) -> CGRect {
        let origin: CGPoint = TextCGPoint(pixelFloor: rect.origin)
        let corner = TextCGPoint(pixelCeil: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        return CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
    }
    
    /// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
    @objc(textCGRectPixelHalf:)
    @inline(__always) public static func textCGRect(pixelHalf rect: CGRect) -> CGRect {
        let origin: CGPoint = TextCGPoint(pixelHalf: rect.origin)
        let corner = TextCGPoint(pixelHalf: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        return CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
    }
    
    /// Returns the center for the rectangle.
    @objc(textCGRectGetCenter:)
    @inline(__always) public static func textCGRectGetCenter(_ rect: CGRect) -> CGPoint {
        return CGPoint(x: rect.midX, y: rect.midY)
    }
    
    /// Returns the area of the rectangle.
    @objc(textCGRectGetArea:)
    @inline(__always) public static func textCGRectGetArea(_ rect: CGRect) -> CGFloat {
        var rect = rect
        if rect.isNull {
            return 0
        }
        rect = rect.standardized
        return rect.size.width * rect.size.height
    }
    
    /// Returns the distance between two points.
    @objc(textCGPointGetDistanceToPoint:p2:)
    @inline(__always) public static func textCGPointGetDistance(to p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y))
    }
    
    /// Returns the minmium distance between a point to a rectangle.
    @objc(textCGPointGetDistanceToRect:r:)
    @inline(__always) public static func textCGPointGetDistance(to p: CGPoint, r: CGRect) -> CGFloat {
        let rect = r.standardized
        if rect.contains(p) {
            return 0
        }
        var distV: CGFloat
        var distH: CGFloat
        if rect.minY <= p.y && p.y <= rect.maxY {
            distV = 0
        } else {
            distV = p.y < rect.minY ? rect.minY - p.y : p.y - rect.maxY
        }
        if rect.minX <= p.x && p.x <= rect.maxX {
            distH = 0
        } else {
            distH = p.x < rect.minX ? rect.minX - p.x : p.x - rect.maxX
        }
        return max(distV, distH)
    }

    /// floor UIEdgeInset for pixel-aligned
    @objc(textUIEdgeInsetPixelFloor:)
    @inline(__always) public static func textUIEdgeInset(pixelFloor insets: UIEdgeInsets) -> UIEdgeInsets {
        var i = insets
        i.top = textCGFloat(pixelFloor: insets.top)
        i.left = textCGFloat(pixelFloor: insets.left)
        i.bottom = textCGFloat(pixelFloor: insets.bottom)
        i.right = textCGFloat(pixelFloor: insets.right)
        return i
    }
    
    /// ceil UIEdgeInset for pixel-aligned
    @objc(textUIEdgeInsetPixelCeil:)
    @inline(__always) public static func textUIEdgeInset(pixelCeil insets: UIEdgeInsets) -> UIEdgeInsets {
        var i = insets
        i.top = textCGFloat(pixelCeil: insets.top)
        i.left = textCGFloat(pixelCeil: insets.left)
        i.bottom = textCGFloat(pixelCeil: insets.bottom)
        i.right = textCGFloat(pixelCeil: insets.right)
        return i
    }
    
    @objc(textFontWithBold:)
    @inline(__always) public static func textFont(withBold font: UIFont?) -> UIFont? {
        if let aBold = font?.fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: aBold, size: font?.pointSize ?? 0)
        }
        return nil
    }
    
    @objc(textFontWithItalic:)
    @inline(__always) public static func textFont(withItalic font: UIFont?) -> UIFont? {
        if let anItalic = font?.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: anItalic, size: font?.pointSize ?? 0)
        }
        return nil
    }
    
    @objc(textFontWithBoldItalic:)
    @inline(__always) public static func textFont(withBoldItalic font: UIFont?) -> UIFont? {
        if let anItalic = font?.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            return UIFont(descriptor: anItalic, size: font?.pointSize ?? 0)
        }
        return nil
    }
    
    /**
     Convert CFRange to NSRange
     @param cfRange CFRange @return NSRange
     */
    @objc(textNSRangeFromCFRange:)
    @inline(__always) public static func textNSRange(from cfRange: CFRange) -> NSRange {
        return NSRange(location: cfRange.location, length: cfRange.length)
    }
    
    /**
     Convert NSRange to CFRange
     @param nsRange NSRange @return CFRange
     */
    @objc(textCFRangeFromNSRange:)
    @inline(__always) public static func textCFRange(from nsRange: NSRange) -> CFRange {
        return CFRangeMake(nsRange.location, nsRange.length)
    }
}
