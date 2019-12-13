//
//  TextLine.swift
//  BSText
//
//  Created by BlueSky on 2018/11/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

/**
 A range in CTRun, used for vertical form.
 */
public class TextLine: NSObject {
    
    private var firstGlyphPos: CGFloat = 0
    
    /*/< line index */
    @objc public var index: Int = 0
    
    /*/< line row */
    @objc public var row: Int = 0
    
    /*/< Run rotate range */
    @objc public var verticalRotateRange: [[TextRunGlyphRange]]?
    
    private var _ctLine: CTLine?
    
    /*/< CoreText line */
    @objc public private(set) var ctLine: CTLine? {
        set {
            if _ctLine != newValue {
                _ctLine = newValue
                
                if let line = newValue {
                    lineWidth = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
                    let range: CFRange = CTLineGetStringRange(line)
                    self.range = NSRange(location: range.location, length: range.length)
                    if CTLineGetGlyphCount(line) > 0 {
                        let runs = CTLineGetGlyphRuns(line)
                        let p = CFArrayGetValueAtIndex(runs, 0);
                        // 获取 UnsafeRawPointer 指针中的内容，用 unsafeBitCast 方法
                        let run = unsafeBitCast(p, to: CTRun.self)
                        
                        var pos = CGPoint.zero
                        CTRunGetPositions(run, CFRangeMake(0, 1), &pos)
                        
                        firstGlyphPos = pos.x
                    } else {
                        firstGlyphPos = 0
                    }
                    trailingWhitespaceWidth = CGFloat(CTLineGetTrailingWhitespaceWidth(line))
                } else {
                    trailingWhitespaceWidth = 0
                    firstGlyphPos = trailingWhitespaceWidth
                    leading = firstGlyphPos
                    descent = leading
                    ascent = descent
                    lineWidth = ascent
                    self.range = NSRange(location: 0, length: 0)
                }
                reloadBounds()
            }
        }
        get {
            return _ctLine
        }
    }
    
    /*/< string range */
    @objc public private(set) var range = NSRange(location: 0, length: 0)
    
    /*/< vertical form */
    @objc public private(set) var vertical = false
    
    /*/< bounds (ascent + descent) */
    @objc public private(set) var bounds = CGRect.zero
    
    /*/< bounds.size */
    @objc public var size: CGSize {
        return bounds.size
    }
    
    /*/< bounds.size.width */
    @objc public var width: CGFloat {
        return bounds.size.width
    }
    
    /*/< bounds.size.height */
    @objc public var height: CGFloat {
        return bounds.size.height
    }
    
    /*/< bounds.origin.y */
    @objc public var top: CGFloat {
        return bounds.minY
    }
    
    /*/< bounds.origin.y + bounds.size.height */
    @objc public var bottom: CGFloat {
        return bounds.maxY
    }
    
    /*/< bounds.origin.x */
    @objc public var left: CGFloat {
        return bounds.minX
    }
    
    /*/< bounds.origin.x + bounds.size.width */
    @objc public var right: CGFloat {
        return bounds.maxX
    }
    
    private var _position = CGPoint.zero
    
    /*/< baseline position */
    @objc public var position: CGPoint {
        set {
            _position = newValue
            self.reloadBounds()
        }
        get {
            return _position
        }
    }
    
    /*/< line ascent */
    @objc public private(set) var ascent: CGFloat = 0
    
    /*/< line descent */
    @objc public private(set) var descent: CGFloat = 0
    
    /*/< line leading */
    @objc public private(set) var leading: CGFloat = 0
    
    /*/< line width */
    @objc public private(set) var lineWidth: CGFloat = 0
    
    @objc public private(set) var trailingWhitespaceWidth: CGFloat = 0
    
    /*/< TextAttachment */
    @objc public private(set) var attachments: [TextAttachment]?
    
    /*/< NSRange(NSValue) */
    @objc public private(set) var attachmentRanges: [NSValue]?
    
    ///< CGRect(NSValue)
    @objc public private(set) var attachmentRects: [NSValue]?
    
    
    @objc(lineWithCTLine:position:vertical:)
    public class func lineWith(ctLine: CTLine, position: CGPoint, vertical isVertical: Bool) -> TextLine {
        
        let line = TextLine()
        line.position = position
        line.vertical = isVertical
        line.ctLine = ctLine
        
        return line
    }
    
    public override init() {
        super.init()
    }
    
    private func reloadBounds() {
        if vertical {
            bounds = CGRect(x: position.x - descent, y: position.y, width: self.ascent + descent, height: lineWidth)
            bounds.origin.y += firstGlyphPos
        } else {
            bounds = CGRect(x: position.x, y: position.y - self.ascent, width: lineWidth, height: self.ascent + descent)
            bounds.origin.x += firstGlyphPos
        }
        self.attachments = nil
        self.attachmentRanges = nil
        self.attachmentRects = nil
        if ctLine == nil {
            return
        }
        let runs = CTLineGetGlyphRuns(ctLine!)
        let runCount = CFArrayGetCount(runs)
        if runCount == 0 {
            return
        }
        var attachments_ = [TextAttachment]()
        var attachmentRanges_ = [NSValue]()
        var attachmentRects_ = [NSValue]()
        for r in 0..<runCount {
            let p = CFArrayGetValueAtIndex(runs, r);
            // 获取 UnsafeRawPointer 指针中的内容，用 unsafeBitCast 方法
            let run = unsafeBitCast(p, to: CTRun.self)
            let glyphCount: CFIndex = CTRunGetGlyphCount(run)
            if glyphCount == 0 {
                continue
            }
            let attrs = CTRunGetAttributes(run) as? [AnyHashable : Any]
            
            if let attachment = attrs?[TextAttribute.textAttachmentAttributeName] as? TextAttachment {
                var runPosition = CGPoint.zero
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition)
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                var leading: CGFloat = 0
                var runWidth: CGFloat = 0
                var runTypoBounds = CGRect.zero
                runWidth = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading))
                
                if vertical {
                    (runPosition.x, runPosition.y) = (runPosition.y, runPosition.x)
                    runPosition.y = position.y + runPosition.y
                    runTypoBounds = CGRect(x: position.x + runPosition.x - descent, y: runPosition.y, width: ascent + descent, height: runWidth)
                } else {
                    runPosition.x += position.x
                    runPosition.y = position.y - runPosition.y
                    runTypoBounds = CGRect(x: runPosition.x, y: runPosition.y - ascent, width: runWidth, height: ascent + descent)
                }
                let cfRange: CFRange = CTRunGetStringRange(run)
                let runRange = NSRange(location: cfRange.location, length: cfRange.length)
                
                attachments_.append(attachment)
                attachmentRanges_.append(NSValue(range: runRange))
                attachmentRects_.append(NSValue(cgRect: runTypoBounds))
            }
        }
        attachments = attachments_.count > 0 ? attachments_ : nil
        attachmentRanges = attachmentRanges_.count > 0 ? attachmentRanges_ : nil
        attachmentRects = attachmentRects_.count > 0 ? attachmentRects_ : nil
    }
    
    public override var description: String {
        var desc = ""
        let range = self.range
        desc += String(format: "<TextLine: %p> row: %zd range: %tu, %tu", self, row, range.location, range.length)
        desc += " position:\(NSCoder.string(for: position))"
        desc += " bounds:\(NSCoder.string(for: bounds))"
        return desc
    }
}

@objc public enum TextRunGlyphDrawMode : Int {
    /// No rotate.
    case horizontal = 0
    /// Rotate vertical for single glyph.
    case verticalRotate = 1
    /// Rotate vertical for single glyph, and move the glyph to a better position,
    /// such as fullwidth punctuation.
    case verticalRotateMove = 2
}

/**
 A range in CTRun, used for vertical form.
 */
public class TextRunGlyphRange: NSObject {
    
    @objc public var glyphRangeInRun = NSRange(location: 0, length: 0)
    @objc public var drawMode = TextRunGlyphDrawMode.horizontal
    
    @objc(rangeWithRange:drawMode:)
    public class func range(with range: NSRange, drawMode mode: TextRunGlyphDrawMode) -> TextRunGlyphRange {
        
        let one = TextRunGlyphRange()
        one.glyphRangeInRun = range
        one.drawMode = mode
        
        return one
    }
}
