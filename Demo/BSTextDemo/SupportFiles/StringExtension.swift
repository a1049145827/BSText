//
//  StringExtension.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/23.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

extension String {
    
    // MARK: - Drawing
    
    /**
     Returns the size of the string if it were rendered with the specified constraints.
     
     @param font          The font to use for computing the string size.
     
     @param size          The maximum acceptable size for the string. This value is
     used to calculate where line breaks and wrapping would occur.
     
     @param lineBreakMode The line break options for computing the size of the string.
     For a list of possible values, see NSLineBreakMode.
     
     @return              The width and height of the resulting string's bounding box.
     These values may be rounded up to the nearest whole number.
     */
    func size(for font: UIFont?, size: CGSize, mode lineBreakMode: NSLineBreakMode) -> CGSize {
        var font = font
        var result: CGSize
        if font == nil {
            font = UIFont.systemFont(ofSize: 12)
        }
        
        var attr = [NSAttributedString.Key : Any]()
        if let font = font {
            attr[NSAttributedString.Key.font] = font
        }
        if lineBreakMode != .byWordWrapping {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = lineBreakMode
            attr[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }
        let rect: CGRect = (self as String).boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attr, context: nil)
        result = rect.size
        
        return result
    }
    
    /**
     Returns the width of the string if it were to be rendered with the specified
     font on a single line.
     
     @param font  The font to use for computing the string width.
     
     @return      The width of the resulting string's bounding box. These values may be
     rounded up to the nearest whole number.
     */
    func width(for font: UIFont?) -> CGFloat {
        let size = self.size(for: font, size: CGSize(width: Double(HUGE), height: Double(HUGE)), mode: .byWordWrapping)
        return size.width
    }

    /**
     Returns the height of the string if it were rendered with the specified constraints.
     
     @param font   The font to use for computing the string size.
     
     @param width  The maximum acceptable width for the string. This value is used
     to calculate where line breaks and wrapping would occur.
     
     @return       The height of the resulting string's bounding box. These values
     may be rounded up to the nearest whole number.
     */
    func height(for font: UIFont?, width: CGFloat) -> CGFloat {
        let size = self.size(for: font, size: CGSize(width: width, height: CGFloat(HUGE)), mode: .byWordWrapping)
        return size.height
    }
    
    // MARK: - Regular Expression
    
    /**
     Whether it can match the regular expression
     
     @param regex  The regular expression
     @param options     The matching options to report.
     @return YES if can match the regex; otherwise, NO.
     */
    func matchesRegex(_ regex: String?, options: NSRegularExpression.Options) -> Bool {
        let pattern = try? NSRegularExpression(pattern: regex ?? "", options: options)
        if pattern == nil {
            return false
        }
        return (pattern?.numberOfMatches(in: self, options: [], range: NSRange(location: 0, length: length)) ?? 0) > 0
    }
    
    /**
     Match the regular expression, and executes a given block using each object in the matches.
     
     @param regex    The regular expression
     @param options  The matching options to report.
     @param block    The block to apply to elements in the array of matches.
     The block takes four arguments:
     match: The match substring.
     matchRange: The matching options.
     stop: A reference to a Boolean value. The block can set the value
     to YES to stop further processing of the array. The stop
     argument is an out-only argument. You should only ever set
     this Boolean to YES within the Block.
     */
    func enumerateRegexMatches(_ regex: String?, options: NSRegularExpression.Options, usingBlock block: @escaping (_ match: String?, _ matchRange: NSRange, _ stop: UnsafeMutablePointer<ObjCBool>?) -> Void) {
        if (regex?.count ?? 0) == 0 {
            return
        }
        let pattern = try? NSRegularExpression(pattern: regex ?? "", options: options)
        if regex == nil {
            return
        }
        pattern?.enumerateMatches(in: self, options: [], range: NSRange(location: 0, length: length), using: { result, flags, stop in
            if let range = result?.range {
                block(self.subString(start: range.location, end: range.location + range.length), result!.range, stop)
            }
        })
    }
    
    /**
     Returns a new string containing matching regular expressions replaced with the template string.
     
     @param regex       The regular expression
     @param options     The matching options to report.
     @param replacement The substitution template used when replacing matching instances.
     
     @return A string with matching regular expressions replaced by the template string.
     */
    func string(byReplacingRegex regex: String?, options: NSRegularExpression.Options, with replacement: String?) -> String? {
        
        guard let pattern = try? NSRegularExpression(pattern: regex ?? "", options: options) else {
            return self
        }
        return pattern.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: length), withTemplate: replacement ?? "")
    }
    
    // MARK: - Utilities
    
    
    /**
     Trim blank characters (space and newline) in head and tail.
     @return the trimmed string.
     */
    func stringByTrim() -> String? {
        let `set` = CharacterSet.whitespacesAndNewlines
        return trimmingCharacters(in: `set`)
    }
    
    /**
     Add scale modifier to the file name (without path extension),
     From @"name" to @"name@2x".
     
     e.g.
     <table>
     <tr><th>Before     </th><th>After(scale:2)</th></tr>
     <tr><td>"icon"     </td><td>"icon@2x"     </td></tr>
     <tr><td>"icon "    </td><td>"icon @2x"    </td></tr>
     <tr><td>"icon.top" </td><td>"icon.top@2x" </td></tr>
     <tr><td>"/p/name"  </td><td>"/p/name@2x"  </td></tr>
     <tr><td>"/path/"   </td><td>"/path/"      </td></tr>
     </table>
     
     @param scale Resource scale.
     @return String by add scale modifier, or just return if it's not end with file name.
     */
    func string(byAppendingNameScale scale: CGFloat) -> String? {
        if abs(Float(scale - 1)) <= .ulpOfOne || length == 0 || hasSuffix("/") {
            return self
        }
        return self + ("@\(NSNumber(value: Float(scale)))x")
    }
    
    /**
     Add scale modifier to the file path (with path extension),
     From @"name.png" to @"name@2x.png".
     
     e.g.
     <table>
     <tr><th>Before     </th><th>After(scale:2)</th></tr>
     <tr><td>"icon.png" </td><td>"icon@2x.png" </td></tr>
     <tr><td>"icon..png"</td><td>"icon.@2x.png"</td></tr>
     <tr><td>"icon"     </td><td>"icon@2x"     </td></tr>
     <tr><td>"icon "    </td><td>"icon @2x"    </td></tr>
     <tr><td>"icon."    </td><td>"icon.@2x"    </td></tr>
     <tr><td>"/p/name"  </td><td>"/p/name@2x"  </td></tr>
     <tr><td>"/path/"   </td><td>"/path/"      </td></tr>
     </table>
     
     @param scale Resource scale.
     @return String by add scale modifier, or just return if it's not end with file name.
     */
    func string(byAppendingPathScale scale: CGFloat) -> String? {
        if abs(Float(scale - 1)) <= .ulpOfOne || length == 0 || hasSuffix("/") {
            return self
        }
        let ext = URL(fileURLWithPath: self).pathExtension
        var extRange = NSRange(location: length - ext.length, length: 0)
        if ext != "" {
            extRange.location -= 1
        }
        let scaleStr = "@\(NSNumber(value: Float(scale)))x"
        return replacingCharacters(in: range(from: extRange)!, with: scaleStr)
    }
    
    /**
     Return the path scale.
     
     e.g.
     <table>
     <tr><th>Path            </th><th>Scale </th></tr>
     <tr><td>"icon.png"      </td><td>1     </td></tr>
     <tr><td>"icon@2x.png"   </td><td>2     </td></tr>
     <tr><td>"icon@2.5x.png" </td><td>2.5   </td></tr>
     <tr><td>"icon@2x"       </td><td>1     </td></tr>
     <tr><td>"icon@2x..png"  </td><td>1     </td></tr>
     <tr><td>"icon@2x.png/"  </td><td>1     </td></tr>
     </table>
     */
    func pathScale() -> CGFloat {
        if length == 0 || hasSuffix("/") {
            return 1
        }
        let name = URL(fileURLWithPath: self).deletingPathExtension().absoluteString
        var scale: CGFloat = 1
        name.enumerateRegexMatches("@[0-9]+\\.?[0-9]*x$", options: NSRegularExpression.Options.anchorsMatchLines, usingBlock: { match, matchRange, stop in
            scale = CGFloat(Double(((match as NSString?)?.substring(with: NSRange(location: 1, length: (match?.count ?? 0) - 2)) ?? "")) ?? 0.0)
        })
        return scale
    }
    
    /**
     Returns NSMakeRange(0, self.length).
     */
    func rangeOfAll() -> NSRange {
        return NSRange(location: 0, length: length)
    }
    
//    func subString(start: Int, end: Int) -> String {
//        let startIndex = utf16.index(utf16.startIndex, offsetBy: start)
//        let endIndex = utf16.index(utf16.startIndex, offsetBy: end)
//        return String(self[startIndex..<endIndex])
//    }
    
    /// Hex String to Int
    ///
    /// - Parameter str: Hex String
    /// - Returns: Int Value
    public func hexToInt() -> Int {
        
        let input = self
        
        let str = input.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 start form 48
            if i >= 65 {                 // A-Z start from 65, origin is 10
                sum -= 7
            }
        }
        return sum

        // 下面这种方案也可以实现功能，不过效率略低，二者性能差异 5%~10%
//        let scanner = Scanner(string: input)
//        scanner.scanLocation = 0
//        var value: UInt32 = 0
//        scanner.scanHexInt32(&value)
//
//        return Int(value)
    }
    
    /// NSRange 转化为 Range
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        
        return from ..< to
    }
}
