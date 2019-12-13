//
//  TextLayout.swift
//  BSText
//
//  Created by BlueSky on 2018/12/5.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

fileprivate struct RowEdge {
    var head: CGFloat = 0
    var foot: CGFloat = 0
}

@inline(__always) private func textClipCGSize(_ size: CGSize) -> CGSize {
    var size = size
    if size.width > TextContainer.textContainerMaxSize.width {
        size.width = TextContainer.textContainerMaxSize.width
    }
    if size.height > TextContainer.textContainerMaxSize.height {
        size.height = TextContainer.textContainerMaxSize.height
    }
    return size
}

@inline(__always) private func UIEdgeInsetRotateVertical(insets: UIEdgeInsets) -> UIEdgeInsets {
    var one = UIEdgeInsets.zero
    one.top = insets.left
    one.left = insets.bottom
    one.bottom = insets.right
    one.right = insets.top
    return one
}

/**
 The TextContainer class defines a region in which text is laid out.
 TextLayout class uses one or more TextContainer objects to generate layouts.
 
 A TextContainer defines rectangular regions (`size` and `insets`) or
 nonrectangular shapes (`path`), and you can define exclusion paths inside the
 text container's bounding rectangle so that text flows around the exclusion
 path as it is laid out.
 
 All methods in this class is thread-safe.
 
 Example:
 
 ┌─────────────────────────────┐  <------- container
 │                             │
 │    asdfasdfasdfasdfasdfa   <------------ container insets
 │    asdfasdfa   asdfasdfa    │
 │    asdfas         asdasd    │
 │    asdfa        <----------------------- container exclusion path
 │    asdfas         adfasd    │
 │    asdfasdfa   asdfasdfa    │
 │    asdfasdfasdfasdfasdfa    │
 │                             │
 └─────────────────────────────┘
 */
public class TextContainer: NSObject, NSCoding, NSCopying, NSSecureCoding {
    
    /**
     The max text container size in layout.
     */
    @objc public static let textContainerMaxSize = CGSize(width: 0x100000, height: 0x100000)
    
    private var _size = CGSize.zero
    /// The constrained size. (if the size is larger than TextContainerMaxSize, it will be clipped)
    @objc public var size: CGSize {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            if _path == nil {
                _size = textClipCGSize(newValue)
            }
            lock.signal()
        }
        get {
            lock.wait()
            let s = _size
            lock.signal()
            return s
        }
    }
    
    private var _insets = UIEdgeInsets.zero
    /// The insets for constrained size. The inset value should not be negative. Default is UIEdgeInsetsZero.
    @objc public var insets: UIEdgeInsets {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            if _path == nil {
                var i = newValue
                if i.top < 0 { i.top = 0 }
                if i.left < 0 { i.left = 0 }
                if i.bottom < 0 { i.bottom = 0 }
                if i.right < 0 { i.right = 0 }
                _insets = i
            }
            lock.signal()
        }
        get {
            lock.wait()
            let i = _insets
            lock.signal()
            return i
        }
    }
    
    private var _path: UIBezierPath?
    /// Custom constrained path. Set this property to ignore `size` and `insets`. Default is nil.
    @objc public var path: UIBezierPath? {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            _path = newValue?.copy() as? UIBezierPath;
            if (_path != nil) {
                let bounds = _path!.bounds;
                var size = bounds.size;
                var insets = UIEdgeInsets.zero;
                if (bounds.origin.x < 0) { size.width += bounds.origin.x; }
                if (bounds.origin.x > 0) { insets.left = bounds.origin.x; }
                if (bounds.origin.y < 0) { size.height += bounds.origin.y; }
                if (bounds.origin.y > 0) { insets.top = bounds.origin.y; }
                _size = size;
                _insets = insets;
            }
            lock.signal()
        }
        get {
            lock.wait()
            let p = _path
            lock.signal()
            return p
        }
    }
    
    private var _exclusionPaths: [UIBezierPath]?
    /// An array of `UIBezierPath` for path exclusion. Default is nil.
    @objc public var exclusionPaths: [UIBezierPath]? {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            _exclusionPaths = newValue
            lock.signal()
        }
        get {
            lock.wait()
            let p = _exclusionPaths
            lock.signal()
            return p
        }
    }
    
    private var _pathLineWidth: CGFloat = 0
    /// Path line width. Default is 0;
    @objc public var pathLineWidth: CGFloat {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            _pathLineWidth = newValue
            lock.signal()
        }
        get {
            lock.wait()
            let p = _pathLineWidth
            lock.signal()
            return p
        }
    }
    
    private var _pathFillEvenOdd = true
    /// YES:(PathFillEvenOdd) Text is filled in the area that would be painted if the path were given to CGContextEOFillPath.
    /// NO: (PathFillWindingNumber) Text is fill in the area that would be painted if the path were given to CGContextFillPath.
    /// Default is YES;
    @objc public var pathFillEvenOdd: Bool {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            _pathFillEvenOdd = newValue
            lock.signal()
        }
        get {
            lock.wait()
            let p = _pathFillEvenOdd
            lock.signal()
            return p
        }
    }
    
    private var _isVerticalForm = false
    /// Whether the text is vertical form (may used for CJK text layout). Default is NO.
    @objc public var isVerticalForm: Bool {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            _isVerticalForm = newValue
            lock.signal()
        }
        get {
            lock.wait()
            let v = _isVerticalForm
            lock.signal()
            return v
        }
    }
    
    private var _maximumNumberOfRows: Int = 0
    /// Maximum number of rows, 0 means no limit. Default is 0.
    @objc public var maximumNumberOfRows: Int {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            _maximumNumberOfRows = newValue
            lock.signal()
        }
        get {
            lock.wait()
            let m = _maximumNumberOfRows
            lock.signal()
            return m
        }
    }
    
    private var _truncationType = TextTruncationType.none
    /// The line truncation type, default is none.
    @objc public var truncationType: TextTruncationType {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            _truncationType = newValue
            lock.signal()
        }
        get {
            lock.wait()
            let t = _truncationType
            lock.signal()
            return t
        }
    }
    
    private var _truncationToken: NSAttributedString?
    /// The truncation token. If nil, the layout will use "…" instead. Default is nil.
    @objc public var truncationToken: NSAttributedString? {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            _truncationToken = newValue?.copy() as? NSAttributedString
            lock.signal()
        }
        get {
            lock.wait()
            let t = _truncationToken
            lock.signal()
            return t
        }
    }
    
    private weak var _linePositionModifier: TextLinePositionModifier?
    /// This modifier is applied to the lines before the layout is completed,
    /// give you a chance to modify the line position. Default is nil.
    @objc public weak var linePositionModifier: TextLinePositionModifier? {
        set {
            if readonly {
                fatalError("Cannot change the property of the 'container' in 'TextLayout'.")
            }
            lock.wait()
            _linePositionModifier = _linePositionModifier?.copy() as? TextLinePositionModifier
            lock.signal()
        }
        get {
            lock.wait()
            let l = _linePositionModifier
            lock.signal()
            return l
        }
    }
    
    
    ///< used only in TextLayout.implementation
    fileprivate var readonly = false
    fileprivate lazy var lock: DispatchSemaphore = DispatchSemaphore(value: 1)

    
    /// Creates a container with the specified size. @param size The size.
    @objc(containerWithSize:)
    public class func container(with size: CGSize) -> TextContainer {
        return container(with: size, insets: UIEdgeInsets.zero)
    }
    
    /// Creates a container with the specified size and insets. @param size The size. @param insets The text insets.
    @objc(containerWithSize:insets:)
    public class func container(with size: CGSize, insets: UIEdgeInsets) -> TextContainer {
        let one = TextContainer.init()
        one.size = textClipCGSize(size)
        one.insets = insets
        return one
    }
    
    /// Creates a container with the specified path. @param path The path.
    @objc(containerWithPath:)
    public class func container(with path: UIBezierPath?) -> TextContainer {
        let one = TextContainer.init()
        one.path = path
        return one
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let one = TextContainer.init()
        lock.wait()
        one._size = _size
        one._insets = _insets
        one._path = _path
        one._exclusionPaths = _exclusionPaths
        one._pathFillEvenOdd = _pathFillEvenOdd
        one._pathLineWidth = _pathLineWidth
        one._isVerticalForm = _isVerticalForm
        one._maximumNumberOfRows = _maximumNumberOfRows
        one._truncationType = _truncationType
        one._truncationToken = _truncationToken?.copy() as? NSAttributedString
        one._linePositionModifier = _linePositionModifier
        lock.signal()
        return one
    }
    
    override public func mutableCopy() -> Any {
        return self.copy()
    }
    
    // MARK: - NSCoding
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(_size, forKey: "size")
        aCoder.encode(_insets, forKey: "insets")
        aCoder.encode(_path, forKey: "path")
        aCoder.encode(_exclusionPaths, forKey: "exclusionPaths")
        aCoder.encode(_pathFillEvenOdd, forKey: "pathFillEvenOdd")
        aCoder.encode(Float(_pathLineWidth), forKey: "pathLineWidth")
        aCoder.encode(_isVerticalForm, forKey: "isVerticalForm")
        aCoder.encode(_maximumNumberOfRows, forKey: "maximumNumberOfRows")
        aCoder.encode(_truncationType.rawValue, forKey: "truncationType")
        aCoder.encode(_truncationToken, forKey: "truncationToken")
        if (_linePositionModifier?.responds(to: #selector(self.encode(with:))) ?? false) {
            aCoder.encode(linePositionModifier, forKey: "linePositionModifier")
        }
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
        _size = aDecoder.decodeCGSize(forKey: "size")
        _insets = aDecoder.decodeUIEdgeInsets(forKey: "insets")
        _path = aDecoder.decodeObject(forKey: "path") as? UIBezierPath
        _exclusionPaths = aDecoder.decodeObject(forKey: "exclusionPaths") as? [UIBezierPath]
        _pathFillEvenOdd = aDecoder.decodeBool(forKey: "pathFillEvenOdd")
        _pathLineWidth = CGFloat(aDecoder.decodeFloat(forKey: "pathLineWidth"))
        _isVerticalForm = aDecoder.decodeBool(forKey: "isVerticalForm")
        _maximumNumberOfRows = aDecoder.decodeInteger(forKey: "maximumNumberOfRows")
        _truncationType = TextTruncationType(rawValue: aDecoder.decodeInteger(forKey: "truncationType"))!
        _truncationToken = aDecoder.decodeObject(forKey: "truncationToken") as? NSAttributedString
        _linePositionModifier = aDecoder.decodeObject(forKey: "linePositionModifier") as? TextLinePositionModifier
    }
    
    // MARK: - NSSecureCoding
    public static var supportsSecureCoding: Bool {
        return true
    }
}

/**
 The TextLinePositionModifier protocol declares the required method to modify
 the line position in text layout progress. See `TextLinePositionSimpleModifier` for example.
 */
@objc public protocol TextLinePositionModifier: NSObjectProtocol, NSCopying {
    /**
     This method will called before layout is completed. The method should be thread-safe.
     @param lines     An array of TextLine.
     @param text      The full text.
     @param container The layout container.
     */
    func modifyLines(_ lines: [TextLine]?, fromText text: NSAttributedString?, in container: TextContainer?)
}

/**
 A simple implementation of `TextLinePositionModifier`. It can fix each line's position
 to a specified value, lets each line of height be the same.
 */
public class TextLinePositionSimpleModifier: NSObject, TextLinePositionModifier {
    
    ///< The fixed line height (distance between two baseline).
    @objc public var fixedLineHeight: CGFloat = 0
    
    public func modifyLines(_ lines: [TextLine]?, fromText text: NSAttributedString?, in container: TextContainer?) {
        
        guard let l = lines, let c = container else {
            return
        }
        
        let maxCount = l.count
        
        if c.isVerticalForm {
            for i in 0..<maxCount {
                let line = l[i]
                var pos = line.position
                pos.x = c.size.width - c.insets.right - CGFloat(integerLiteral: line.row) * fixedLineHeight - fixedLineHeight * 0.9
                line.position = pos
            }
        } else {
            for i in 0..<maxCount {
                let line = l[i]
                var pos = line.position
                pos.y = CGFloat(integerLiteral: line.row) * fixedLineHeight + fixedLineHeight * 0.9 + c.insets.top
                line.position = pos
            }
        }
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let one = TextLinePositionSimpleModifier()
        one.fixedLineHeight = fixedLineHeight
        return one
    }
}

// CoreText bug when draw joined emoji since iOS 8.3.
// See -[NSMutableAttributedString setClearColorToJoinedEmoji] for more information.
fileprivate var needFixJoinedEmojiBug = { () -> Bool in
    let systemVersionDouble = Double(UIDevice.current.systemVersion) ?? 0
    if (8.3 <= systemVersionDouble && systemVersionDouble < 9) {
        return true
    }
    return false
}()

// It may use larger constraint size when create CTFrame with CTFramesetterCreateFrame in iOS 10.
fileprivate var needFixLayoutSizeBug = { () -> Bool in
    let systemVersionDouble = Double(UIDevice.current.systemVersion) ?? 0
    if (systemVersionDouble >= 10) {
        return true
    }
    return false
}()


/**
 TextLayout class is a readonly class stores text layout result.
 All the property in this class is readonly, and should not be changed.
 The methods in this class is thread-safe (except some of the draw methods).
 
 example: (layout with a circle exclusion path)
 
 ┌──────────────────────────┐  <------ container
 │ [--------Line0--------]  │  <- Row0
 │ [--------Line1--------]  │  <- Row1
 │ [-Line2-]     [-Line3-]  │  <- Row2
 │ [-Line4]       [Line5-]  │  <- Row3
 │ [-Line6-]     [-Line7-]  │  <- Row4
 │ [--------Line8--------]  │  <- Row5
 │ [--------Line9--------]  │  <- Row6
 └──────────────────────────┘
 */
public class TextLayout: NSObject, NSCoding, NSCopying {
    
    // MARK: - Text layout attributes
    
    ///=============================================================================
    /// @name Text layout attributes
    ///=============================================================================
    
    ///< The text container
    @objc public private(set) lazy var container = TextContainer()
    ///< The full text
    @objc public private(set) var text: NSAttributedString?
    ///< The text range in full text
    @objc public private(set) var range = NSRange(location: 0, length: 0)
    ///< CTFrameSetter
    @objc public private(set) lazy var frameSetter = CTFramesetterCreateWithAttributedString(NSAttributedString(string: ""))
    ///< CTFrame
    @objc public private(set) lazy var frame: CTFrame = {
        let ctSetter = CTFramesetterCreateWithAttributedString(NSAttributedString(string: ""))
        let ctFrame = CTFramesetterCreateFrame(ctSetter, TextUtilities.textCFRange(from: NSRange(location: 0, length: 0)), UIBezierPath().cgPath, [:] as CFDictionary)
        return ctFrame
    }()
    ///< Array of `TextLine`, no truncated
    @objc public private(set) lazy var lines: [TextLine] = []
    ///< TextLine with truncated token, or nil
    @objc public private(set) var truncatedLine: TextLine?
    ///< Array of `TextAttachment`
    @objc public private(set) var attachments: [TextAttachment]?
    ///< Array of NSRange(wrapped by NSValue) in text
    @objc public private(set) var attachmentRanges: [NSValue]?
    ///< Array of CGRect(wrapped by NSValue) in container
    @objc public private(set) var attachmentRects: [NSValue]?
    ///< Set of Attachment (UIImage/UIView/CALayer)
    @objc public private(set) var attachmentContentsSet: Set<AnyHashable>?
    ///< Number of rows
    @objc public private(set) var rowCount: Int = 0
    ///< Visible text range
    @objc public private(set) lazy var visibleRange = NSRange(location: 0, length: 0)
    ///< Bounding rect (glyphs)
    @objc public private(set) var textBoundingRect = CGRect.zero
    ///< Bounding size (glyphs and insets, ceil to pixel)
    @objc public private(set) var textBoundingSize = CGSize.zero
    ///< Has highlight attribute
    @objc public private(set) var containsHighlight = false
    ///< Has block border attribute
    @objc public private(set) var needDrawBlockBorder = false
    
    ///< Has background border attribute
    @objc public private(set) var needDrawBackgroundBorder = false
    ///< Has shadow attribute
    @objc public private(set) var needDrawShadow = false
    ///< Has underline attribute
    @objc public private(set) var needDrawUnderline = false
    ///< Has visible text
    @objc public private(set) var needDrawText = false
    ///< Has attachment attribute
    @objc public private(set) var needDrawAttachment = false
    ///< Has inner shadow attribute
    @objc public private(set) var needDrawInnerShadow = false
    ///< Has strickthrough attribute
    @objc public private(set) var needDrawStrikethrough = false
    ///< Has border attribute
    @objc public private(set) var needDrawBorder = false
    
    private var lineRowsIndex: UnsafeMutablePointer<Int>?
    ///< top-left origin
    private var lineRowsEdge: UnsafeMutablePointer<RowEdge>?
    
    
    private override init() {
        super.init()
    }
    
    private convenience init(container: TextContainer) {
        self.init()
        self.container = container
    }
    
    deinit {
        lineRowsEdge?.deallocate()
        lineRowsIndex?.deallocate()
    }
    
    // MARK: - Generate text layout
    ///=============================================================================
    /// @name Generate text layout
    ///=============================================================================
    /**
     Generate a layout with the given container size and text.
     
     @param containerSize The text container's size
     @param text The text (if nil, returns nil).
     @return A new layout, or nil when an error occurs.
     */
    @objc(initWithContainerSize:text:)
    public convenience init?(containerSize: CGSize, text: NSAttributedString?) {
        let container = TextContainer.container(with: containerSize)
        self.init(container: container, text: text)
    }
    
    /**
     Generate a layout with the given container and text.
     
     @param container The text container (if nil, returns nil).
     @param text      The text (if nil, returns nil).
     @return A new layout, or nil when an error occurs.
     */
    @objc(initWithContainer:text:)
    public convenience init?(container: TextContainer?, text: NSAttributedString?) {
        self.init(container: container, text: text, range: NSRange(location: 0, length: text?.length ?? 0))
    }
    
    /**
     Generate a layout with the given container and text.
     
     @param container The text container (if nil, returns nil).
     @param text      The text (if nil, returns nil).
     @param range     The text range (if out of range, returns nil). If the
     length of the range is 0, it means the length is no limit.
     @return A new layout, or nil when an error occurs.
     */
    @objc(initWithContainer:text:range:)
    public convenience init?(container: TextContainer?, text: NSAttributedString?, range: NSRange) {
        
        guard let t = text?.mutableCopy() as? NSMutableAttributedString, let c = container?.copy() as? TextContainer else {
            return nil
        }
        if range.location + range.length > t.length {
            return nil
        }
        self.init(container: c)
        
        var cgPath: CGPath
        var cgPathBox = CGRect.zero
        var isVerticalForm = false
        var rowMaySeparated = false
        var frameAttrs = [AnyHashable : AnyObject]()
        
        
        var ctLines: CFArray? = nil
        var lineOrigins: UnsafeMutablePointer<CGPoint>? = nil
        var lineCount: Int = 0
        var lines_ = [TextLine]()
        var attachments_: [TextAttachment]? = nil
        var attachmentRanges_: [NSValue]? = nil
        var attachmentRects_: [NSValue]? = nil
        var attachmentContentsSet_: Set<AnyHashable>? = nil
        var needTruncation = false
        var truncationToken: NSAttributedString? = nil
        var truncatedLine_: TextLine? = nil
        var lineRowsEdge_: UnsafeMutablePointer<RowEdge>? = nil
        var lineRowsIndex_: UnsafeMutablePointer<Int>? = nil
        
        var maximumNumberOfRows: Int = 0
        var constraintSizeIsExtended = false
        var constraintRectBeforeExtended = CGRect.zero
        
        c.readonly = true
        maximumNumberOfRows = c.maximumNumberOfRows
        
        if needFixJoinedEmojiBug {
            (text as? NSMutableAttributedString)?.bs_setClearColorToJoinedEmoji()
        }
        
        self.text = text
        self.container = c
        self.range = range
        isVerticalForm = c.isVerticalForm
        // set cgPath and cgPathBox
        if c.path == nil && (c.exclusionPaths?.count ?? 0) == 0 {
            if c.size.width <= 0 || c.size.height <= 0 {
                lineOrigins?.deallocate()
                lineRowsEdge_?.deallocate()
                lineRowsIndex_?.deallocate()
                return nil
            }
            var rect = CGRect.zero
            rect.size = c.size
            if needFixLayoutSizeBug {
                constraintSizeIsExtended = true
                constraintRectBeforeExtended = rect.inset(by: c.insets)
                constraintRectBeforeExtended = constraintRectBeforeExtended.standardized
                if c.isVerticalForm {
                    rect.size.width = TextContainer.textContainerMaxSize.width
                } else {
                    rect.size.height = TextContainer.textContainerMaxSize.height
                }
            }
            rect = rect.inset(by: c.insets)
            rect = rect.standardized
            cgPathBox = rect
            rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
            cgPath = CGPath(rect: rect, transform: nil) // let CGPathIsRect() returns true
            
        } else if (c.path != nil) && c.path!.cgPath.isRect(&cgPathBox) && c.exclusionPaths?.count ?? 0 == 0 {
            
            let rect: CGRect = cgPathBox.applying(CGAffineTransform(scaleX: 1, y: -1))
            cgPath = CGPath(rect: rect, transform: nil) // let CGPathIsRect() returns true
            
        } else {
            rowMaySeparated = true
            var path: CGMutablePath
            if c.path != nil {
                path = c.path!.cgPath.mutableCopy()!
            } else {
                var rect = CGRect.zero
                rect.size = c.size
                rect = rect.inset(by: c.insets)
                let rectPath = CGPath(rect: rect, transform: nil)
                path = rectPath.mutableCopy()!
            }
            if true {   // path != nil
                if let e = self.container.exclusionPaths {
                    for onePath in e {
                        path.addPath(onePath.cgPath, transform: .identity)
                    }
                }
                cgPathBox = path.boundingBoxOfPath
                var trans = CGAffineTransform(scaleX: 1, y: -1)
                let transPath = path.mutableCopy(using: &trans)!
                path = transPath
            }
            cgPath = path
        }
        
        // frame setter config
        if c.pathFillEvenOdd == false {
            frameAttrs[kCTFramePathFillRuleAttributeName] = NSNumber(value: CTFramePathFillRule.windingNumber.rawValue)
        }
        if c.pathLineWidth > 0 {
            frameAttrs[kCTFramePathWidthAttributeName] = NSNumber(value: Float(c.pathLineWidth))
        }
        if c.isVerticalForm == true {
            frameAttrs[kCTFrameProgressionAttributeName] = NSNumber(value: CTFrameProgression.rightToLeft.rawValue)
        }
        // create CoreText objects
        let ctSetter = CTFramesetterCreateWithAttributedString(t)
        let ctFrame = CTFramesetterCreateFrame(ctSetter, TextUtilities.textCFRange(from: range), cgPath, frameAttrs as CFDictionary)
        
        ctLines = CTFrameGetLines(ctFrame)
        lineCount = CFArrayGetCount(ctLines)
        if lineCount > 0 {
            lineOrigins = UnsafeMutablePointer<CGPoint>.allocate(capacity: lineCount)
            CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins!)
        }
        
        var textBoundingRect_ = CGRect.zero
        var textBoundingSize_ = CGSize.zero
        var rowIdx: Int = -1
        var rowCount_: Int = 0
        var lastRect = CGRect(x: 0, y: CGFloat(-Float.greatestFiniteMagnitude), width: 0, height: 0)
        var lastPosition = CGPoint(x: 0, y: CGFloat(-Float.greatestFiniteMagnitude))
        if isVerticalForm {
            lastRect = CGRect(x: CGFloat(Float.greatestFiniteMagnitude), y: 0, width: 0, height: 0)
            lastPosition = CGPoint(x: CGFloat(Float.greatestFiniteMagnitude), y: 0)
        }
        
        
        // calculate line frame
        var lineCurrentIdx: Int = 0;
        for i in 0..<lineCount {
            let ctLine = unsafeBitCast(CFArrayGetValueAtIndex(ctLines, i), to: CTLine.self)
            let ctRuns = CTLineGetGlyphRuns(ctLine)
            if CFArrayGetCount(ctRuns) == 0 {
                continue
            }
            // CoreText coordinate system
            let ctLineOrigin: CGPoint = lineOrigins![i]
            // UIKit coordinate system
            var position = CGPoint.zero
            position.x = cgPathBox.origin.x + ctLineOrigin.x
            position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin.y
            let line = TextLine.lineWith(ctLine: ctLine, position: position, vertical: isVerticalForm)
            let rect: CGRect = line.bounds
            if constraintSizeIsExtended {
                if isVerticalForm {
                    if rect.origin.x + rect.size.width > constraintRectBeforeExtended.origin.x + constraintRectBeforeExtended.size.width {
                        break
                    }
                } else {
                    if rect.origin.y + rect.size.height > constraintRectBeforeExtended.origin.y + constraintRectBeforeExtended.size.height {
                        break
                    }
                }
            }
            
            var newRow = true
            if rowMaySeparated && position.x != lastPosition.x {
                if isVerticalForm {
                    if rect.size.width > lastRect.size.width {
                        if rect.origin.x > lastPosition.x && lastPosition.x > rect.origin.x - rect.size.width {
                            newRow = false
                        }
                    } else {
                        if lastRect.origin.x > position.x && position.x > lastRect.origin.x - lastRect.size.width {
                            newRow = false
                        }
                    }
                } else {
                    if rect.size.height > lastRect.size.height {
                        if rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height {
                            newRow = false
                        }
                    } else {
                        if lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height {
                            newRow = false
                        }
                    }
                }
            }
            if newRow {
                rowIdx += 1
            }
            lastRect = rect
            lastPosition = position
            
            line.index = lineCurrentIdx
            line.row = rowIdx
            lines_.append(line)
            rowCount_ = rowIdx + 1
            lineCurrentIdx += 1
            if i == 0 {
                textBoundingRect_ = rect
            } else {
                if maximumNumberOfRows == 0 || rowIdx < maximumNumberOfRows {
                    textBoundingRect_ = textBoundingRect_.union(rect)
                }
            }
        }
        
        if rowCount_ > 0 {
            if maximumNumberOfRows > 0 {
                if rowCount_ > maximumNumberOfRows {
                    needTruncation = true
                    rowCount_ = maximumNumberOfRows
                    repeat {
                        let line = lines_.last
                        if line == nil {
                            break
                        }
                        if line!.row < rowCount_ {
                            break
                        }
                        lines_.removeLast()
                    } while true
                }
            }
            let lastLine = lines_.last
            if !needTruncation && (lastLine?.range.location)! + (lastLine?.range.length)! < text!.length {
                needTruncation = true
            }
            // Give user a chance to modify the line's position.
            if (c.linePositionModifier != nil) {
                c.linePositionModifier!.modifyLines(lines_, fromText: text, in: c)
                textBoundingRect_ = CGRect.zero
                var i = 0, maxCount = lines_.count
                while i < maxCount {
                    let line = lines_[i]
                    if i == 0 {
                        textBoundingRect_ = line.bounds
                    } else {
                        textBoundingRect_ = textBoundingRect_.union(line.bounds)
                    }
                    i += 1
                }
            }
            lineRowsEdge_ = UnsafeMutablePointer<RowEdge>.allocate(capacity: rowCount_)
            lineRowsIndex_ = UnsafeMutablePointer<Int>.allocate(capacity: rowCount_)
            
            var lastRowIdx: Int = -1
            var lastHead: CGFloat = 0
            var lastFoot: CGFloat = 0
            
            var i = 0, maxCount = lines_.count
            while i < maxCount {
                let line = lines_[i]
                let rect = line.bounds
                if line.row != lastRowIdx {
                    if lastRowIdx >= 0 {
                        lineRowsEdge_![lastRowIdx] = RowEdge(head: lastHead, foot: lastFoot)
                    }
                    lastRowIdx = line.row
                    lineRowsIndex_![lastRowIdx] = i
                    if isVerticalForm {
                        lastHead = rect.origin.x + rect.size.width
                        lastFoot = lastHead - rect.size.width
                    } else {
                        lastHead = rect.origin.y
                        lastFoot = lastHead + rect.size.height
                    }
                } else {
                    if isVerticalForm {
                        lastHead = max(lastHead, rect.origin.x + rect.size.width)
                        lastFoot = min(lastFoot, rect.origin.x)
                    } else {
                        lastHead = min(lastHead, rect.origin.y)
                        lastFoot = max(lastFoot, rect.origin.y + rect.size.height)
                    }
                }
                i += 1
            }
            
            lineRowsEdge_![lastRowIdx] = RowEdge(head: lastHead, foot: lastFoot)
            
            for i in 1..<rowCount_ {
                let v0: RowEdge = lineRowsEdge_![i - 1]
                let v1: RowEdge = lineRowsEdge_![i]
                let tmp = (v0.foot + v1.head) * 0.5
                lineRowsEdge_![i].head = tmp
                lineRowsEdge_![i - 1].foot = tmp
            }
        }
        
        if true {
            // calculate bounding size
            var rect: CGRect = textBoundingRect_
            if (c.path != nil) {
                if c.pathLineWidth > 0 {
                    let inset: CGFloat = c.pathLineWidth / 2
                    rect = rect.insetBy(dx: -inset, dy: -inset)
                }
            } else {
                rect = rect.inset(by: TextUtilities.textUIEdgeInsetsInvert(c.insets))
            }
            rect = rect.standardized
            var size: CGSize = rect.size
            if c.isVerticalForm {
                size.width += c.size.width - (rect.origin.x + rect.size.width)
            } else {
                size.width += rect.origin.x
            }
            size.height += rect.origin.y
            if size.width < 0 {
                size.width = 0
            }
            if size.height < 0 {
                size.height = 0
            }
            size.width = ceil(size.width)
            size.height = ceil(size.height)
            textBoundingSize_ = size
        }
        
        var visibleRange_ = TextUtilities.textNSRange(from: CTFrameGetVisibleStringRange(ctFrame))
        
        if needTruncation {
            let lastLine = lines_.last!
            let lastRange = lastLine.range
            visibleRange_.length = lastRange.location + lastRange.length - visibleRange_.location
            
            // create truncated line
            if c.truncationType != TextTruncationType.none {
                var truncationTokenLine: CTLine? = nil
                if (c.truncationToken != nil) {
                    truncationToken = c.truncationToken
                    truncationTokenLine = CTLineCreateWithAttributedString(truncationToken! as CFAttributedString)
                } else {
                    let runs = CTLineGetGlyphRuns(lastLine.ctLine!)
                    let runCount: Int = CFArrayGetCount(runs)
                    var attrs: [NSAttributedString.Key : Any]? = nil
                    if runCount > 0 {
                        let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, runCount - 1), to: CTRun.self)
                        attrs = CTRunGetAttributes(run) as? [NSAttributedString.Key : Any]
                        attrs = attrs != nil ? attrs : [NSAttributedString.Key : Any]()
                        
                        for k in NSMutableAttributedString.bs_allDiscontinuousAttributeKeys() {
                            attrs!.removeValue(forKey: k)
                        }
                        
                        var font = (attrs?[kCTFontAttributeName as NSAttributedString.Key] as! CTFont?)
                        let fontSize: CGFloat = font != nil ? CTFontGetSize(font!) : 12.0
                        let uiFont = UIFont.systemFont(ofSize: fontSize * 0.9)
                        font = CTFontCreateWithName((uiFont.fontName as CFString?)!, uiFont.pointSize, nil)
                        if font != nil {
                            attrs![kCTFontAttributeName as NSAttributedString.Key] = font
                        }
                        let color = (attrs?[kCTForegroundColorAttributeName as NSAttributedString.Key] as! CGColor?)
                        if let c = color, CFGetTypeID(c) == CGColor.typeID, c.alpha == 0 {
                            // ignore clear color
                            attrs?.removeValue(forKey: kCTForegroundColorAttributeName as NSAttributedString.Key)
                        }
                        if attrs == nil {
                            attrs = [NSAttributedString.Key : Any]()
                        }
                    }
                    truncationToken = NSAttributedString(string: TextAttribute.textTruncationToken, attributes: attrs)
                    truncationTokenLine = CTLineCreateWithAttributedString(truncationToken! as CFAttributedString)
                }
                
                if (truncationTokenLine != nil) {
                    var type: CTLineTruncationType = .end
                    if c.truncationType == TextTruncationType.start {
                        type = .start
                    } else if c.truncationType == TextTruncationType.middle {
                        type = .middle
                    }
                    let lastLineText = t.attributedSubstring(from: lastLine.range) as? NSMutableAttributedString
                    lastLineText?.append(truncationToken!)
                    let ctLastLineExtend = CTLineCreateWithAttributedString(lastLineText! as CFAttributedString)
                    
                    var truncatedWidth: CGFloat = lastLine.width
                    var cgPathRect = CGRect.zero
                    if cgPath.isRect(&cgPathRect) {
                        if isVerticalForm {
                            truncatedWidth = cgPathRect.size.height
                        } else {
                            truncatedWidth = cgPathRect.size.width
                        }
                    }
                    
                    if let ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, Double(truncatedWidth), type, truncationTokenLine) {
                        truncatedLine_ = TextLine.lineWith(ctLine: ctTruncatedLine, position: lastLine.position, vertical: isVerticalForm)
                        truncatedLine_!.index = lastLine.index
                        truncatedLine_!.row = lastLine.row
                    }
                }
            }
        }
        
        if (isVerticalForm) {
            let rotateCharset = TextUtilities.textVerticalFormRotateCharacterSet
            let rotateMoveCharset = TextUtilities.textVerticalFormRotateAndMoveCharacterSet
            let lineBlock: ((TextLine?) -> Void) = { line in
                guard let l = line, let ctl = l.ctLine else {
                    return
                }
                let runs = CTLineGetGlyphRuns(ctl)
                let runCount: Int = CFArrayGetCount(runs)
                if runCount == 0 {
                    return
                }
                line!.verticalRotateRange = [[TextRunGlyphRange]]()
                for i in 0..<runCount {
                    let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, i), to: CTRun.self)
                    var runRanges = [TextRunGlyphRange]()
                    let glyphCount: Int = CTRunGetGlyphCount(run)
                    if glyphCount == 0 {
                        continue
                    }
                    
                    let runStrIdx = UnsafeMutablePointer<CFIndex>.allocate(capacity: (glyphCount + 1))
                    CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx)
                    let runStrRange: CFRange = CTRunGetStringRange(run)
                    runStrIdx[glyphCount] = runStrRange.location + runStrRange.length
                    
                    let runAttrs = CTRunGetAttributes(run) as! [String: AnyObject]
                    let font = runAttrs[kCTFontAttributeName as String] as! CTFont
                    let isColorGlyph: Bool = TextUtilities.textCTFontContainsColorBitmapGlyphs(font)
                    var prevIdx: Int = 0
                    var prevMode = TextRunGlyphDrawMode.horizontal
                    let layoutStr = self.text!.string
                    
                    for g in 0..<glyphCount {
                        var glyphRotate = false
                        var glyphRotateMove = false
                        let runStrLen = CFIndex(runStrIdx[g + 1] - runStrIdx[g])
                        if isColorGlyph {
                            glyphRotate = true
                        } else if runStrLen == 1 {
                            let c = (layoutStr as NSString).character(at: runStrIdx[g])
                            glyphRotate = rotateCharset.characterIsMember(c)
                            if glyphRotate {
                                glyphRotateMove = rotateMoveCharset.characterIsMember(c)
                            }
                        } else if runStrLen > 1 {
                            let glyphStr = layoutStr[layoutStr.index(layoutStr.startIndex, offsetBy: runStrIdx[g])..<layoutStr.index(layoutStr.startIndex, offsetBy: (runStrIdx[g]+runStrLen))]
                            let glyphRotate: Bool = (glyphStr as NSString).rangeOfCharacter(from: rotateCharset as CharacterSet).location != NSNotFound
                            if glyphRotate {
                                glyphRotateMove = (glyphStr as NSString).rangeOfCharacter(from: rotateMoveCharset as CharacterSet).location != NSNotFound
                            }
                        }
                        let mode = glyphRotateMove ? TextRunGlyphDrawMode.verticalRotateMove : (glyphRotate ? TextRunGlyphDrawMode.verticalRotate : TextRunGlyphDrawMode.horizontal);
                        if g == 0 {
                            prevMode = mode
                        } else if mode != prevMode {
                            let aRange = TextRunGlyphRange.range(with: NSRange(location: prevIdx, length: g - prevIdx), drawMode: prevMode)
                            runRanges.append(aRange)
                            prevIdx = g
                            prevMode = mode
                        }
                    }
                    
                    if prevIdx < glyphCount {
                        let aRange = TextRunGlyphRange.range(with: NSRange(location: prevIdx, length: glyphCount - prevIdx), drawMode: prevMode)
                        runRanges.append(aRange)
                    }
                    runStrIdx.deallocate()
                    
                    line!.verticalRotateRange!.append(runRanges)
                }
            }
            
            for line in lines_ {
                lineBlock(line)
            }
            if (truncatedLine_ != nil) {
                lineBlock(truncatedLine_)
            }
        }
        
        if visibleRange_.length > 0 {
            self.needDrawText = true
            let block: ((_ attrs: [AnyHashable : Any]?, _ range: NSRange, _ stop: UnsafeMutablePointer<ObjCBool>?) -> Void)? = { attrs, range, stop in
                if attrs?[TextAttribute.textHighlightAttributeName] != nil {
                    self.containsHighlight = true
                }
                if attrs?[TextAttribute.textBlockBorderAttributeName] != nil {
                    self.needDrawBlockBorder = true
                }
                if attrs?[TextAttribute.textBackgroundBorderAttributeName] != nil {
                    self.needDrawBackgroundBorder = true
                }
                if attrs?[TextAttribute.textShadowAttributeName] != nil || attrs?[NSAttributedString.Key.shadow] != nil {
                    self.needDrawShadow = true
                }
                if attrs?[TextAttribute.textUnderlineAttributeName] != nil {
                    self.needDrawUnderline = true
                }
                if attrs?[TextAttribute.textAttachmentAttributeName] != nil {
                    self.needDrawAttachment = true
                }
                if attrs?[TextAttribute.textInnerShadowAttributeName] != nil {
                    self.needDrawInnerShadow = true
                }
                if attrs?[TextAttribute.textStrikethroughAttributeName] != nil {
                    self.needDrawStrikethrough = true
                }
                if attrs?[TextAttribute.textBorderAttributeName] != nil {
                    self.needDrawBorder = true
                }
            }
            if let aBlock = block {
                self.text!.enumerateAttributes(in: visibleRange_, options: .longestEffectiveRangeNotRequired, using: aBlock)
            }
            if (truncatedLine_ != nil) {
                if let aBlock = block {
                    truncationToken!.enumerateAttributes(in: NSRange(location: 0, length: truncationToken!.length), options: .longestEffectiveRangeNotRequired, using: aBlock)
                }
            }
        }
        
        attachments_ = [TextAttachment]()
        attachmentRanges_ = [NSValue]()
        attachmentRects_ = [NSValue]()
        attachmentContentsSet_ = Set<AnyHashable>()
        
        let maxCount = lines_.count
        for i in 0..<maxCount {
            
            var line = lines_[i]
            if (truncatedLine_ != nil) && line.index == truncatedLine_!.index {
                line = truncatedLine_!
            }
            if line.attachments?.count ?? 0 > 0 {
                if let anAttachments = line.attachments {
                    attachments_!.append(contentsOf: anAttachments)
                }
                if let aRanges = line.attachmentRanges {
                    attachmentRanges_?.append(contentsOf: aRanges)
                }
                if let aRects = line.attachmentRects {
                    attachmentRects_?.append(contentsOf: aRects)
                }
                for attachment in line.attachments! {
                    if let aContent = attachment.content {
                        attachmentContentsSet_!.insert(aContent as! AnyHashable)
                    }
                }
            }
        }
        if attachments_!.count == 0 {
            attachmentRects_ = nil
            attachmentRanges_ = nil
            attachments_ = nil
        }
        
        self.frameSetter = ctSetter
        self.frame = ctFrame
        self.lines = lines_
        self.truncatedLine = truncatedLine_
        self.attachments = attachments_
        self.attachmentRanges = attachmentRanges_
        self.attachmentRects = attachmentRects_
        self.attachmentContentsSet = attachmentContentsSet_
        self.rowCount = rowCount_
        self.visibleRange = visibleRange_
        self.textBoundingRect = textBoundingRect_
        self.textBoundingSize = textBoundingSize_
        self.lineRowsEdge = lineRowsEdge_
        self.lineRowsIndex = lineRowsIndex_
        
        lineOrigins?.deallocate()
    }
    
    @objc(layoutWithContainers:text:)
    public class func layout(with containers: [TextContainer]?, text: NSAttributedString?) -> [TextLayout]? {
        return self.layout(with: containers, text: text, range: NSRange(location: 0, length: text?.length ?? 0))
    }
    
    @objc(layoutWithContainers:text:range:)
    public class func layout(with containers: [TextContainer]?, text: NSAttributedString?, range: NSRange) -> [TextLayout]? {
        guard let c = containers, let t = text else {
            return nil
        }
        if range.location + range.length > t.length {
            return nil
        }
        var range = range
        var layouts: [TextLayout] = []
        let maxCount = c.count
        for i in 0..<maxCount {
            let container = c[i]
            
            guard let layout = TextLayout.init(container: container, text: text, range: range) else {
                return nil
            }
            let length = range.length - layout.visibleRange.length
            if length <= 0 {
                range.length = 0
                range.location = t.length
            } else {
                range.length = length
                range.location += layout.visibleRange.length
            }
            layouts.append(layout)
        }
        return layouts
    }
    
    
    // MARK: - Coding
    public func encode(with aCoder: NSCoder) {
        var textData: Data? = nil
        if let aText = text {
            textData = TextArchiver.archivedData(withRootObject: aText)
        }
        aCoder.encode(textData, forKey: "text")
        aCoder.encode(container, forKey: "container")
        aCoder.encode(NSValue(range: range), forKey: "range")
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        let textData = aDecoder.decodeObject(forKey: "text") as? Data
        var text: NSAttributedString? = nil
        if let aData = textData {
            text = TextUnarchiver.unarchiveObject(with: aData) as? NSAttributedString
        }
        let container = aDecoder.decodeObject(forKey: "container") as? TextContainer
        let range: NSRange = ((aDecoder.decodeObject(forKey: "range") as? NSValue)?.rangeValue)!
        self.init(container: container, text: text, range: range)
    }
    
    // MARK: - Copying
    public func copy(with zone: NSZone? = nil) -> Any {
        return self // readonly object
    }
    
    // MARK: - Query
    /**
     Get the row index with 'edge' distance.
     
     @param edge  The distance from edge to the point.
     If vertical form, the edge is left edge, otherwise the edge is top edge.
     
     @return Returns NSNotFound if there's no row at the point.
     */
    private func _rowIndex(for edge: CGFloat) -> Int {
        if rowCount == 0 {
            return NSNotFound
        }
        let isVertical = container.isVerticalForm
        var lo: Int = 0, hi: Int = rowCount - 1, mid: Int = 0
        var rowIdx: Int = NSNotFound
        while lo <= hi {
            mid = (lo + hi) / 2
            let oneEdge = lineRowsEdge![mid]
            if (isVertical ? (oneEdge.foot <= edge && edge <= oneEdge.head) : (oneEdge.head <= edge && edge <= oneEdge.foot)) {
                rowIdx = mid
                break
            }
            if (isVertical ? (edge > oneEdge.head) : (edge < oneEdge.head)) {
                if mid == 0 {
                    break
                }
                hi = mid - 1
            } else {
                lo = mid + 1
            }
        }
        return rowIdx
    }
    
    /**
     Get the closest row index with 'edge' distance.
     
     @param edge  The distance from edge to the point.
     If vertical form, the edge is left edge, otherwise the edge is top edge.
     
     @return Returns NSNotFound if there's no line.
     */
    private func _closestRowIndex(forEdge edge: CGFloat) -> Int {
        if rowCount == 0 {
            return NSNotFound
        }
        var rowIdx = _rowIndex(for: edge)
        if rowIdx == NSNotFound {
            if container.isVerticalForm {
                if edge > lineRowsEdge![0].head {
                    rowIdx = 0
                } else if edge < lineRowsEdge![rowCount - 1].foot {
                    rowIdx = rowCount - 1
                }
            } else {
                if edge < lineRowsEdge![0].head {
                    rowIdx = 0
                } else if edge > lineRowsEdge![rowCount - 1].foot {
                    rowIdx = rowCount - 1
                }
            }
        }
        return rowIdx
    }
    
    /**
     Get a CTRun from a line position.
     
     @param line     The text line.
     @param position The position in the whole text.
     
     @return Returns NULL if not found (no CTRun at the position).
     */
    private func _run(for line: TextLine?, position: TextPosition?) -> CTRun? {
        if line == nil || position == nil {
            return nil
        }
        let runs = CTLineGetGlyphRuns((line?.ctLine)!)
        var i = 0, max = CFArrayGetCount(runs)
        while i < max {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, i), to: CTRun.self)
            let range: CFRange = CTRunGetStringRange(run)
            if position?.affinity == TextAffinity.backward {
                if range.location < position?.offset ?? 0 && position?.offset ?? 0 <= range.location + range.length {
                    return run
                }
            } else {
                if range.location <= position?.offset ?? 0 && position?.offset ?? 0 < range.location + range.length {
                    return run
                }
            }
            i += 1
        }
        return nil
    }
    
    /**
     Whether the position is inside a composed character sequence.
     
     @param line     The text line.
     @param position Text text position in whole text.
     @param block    The block to be executed before returns YES.
     left:  left X offset
     right: right X offset
     prev:  left position
     next:  right position
     */
    @discardableResult
    private func _insideComposedCharacterSequences(_ line: TextLine?, position: Int, block: @escaping (_ `left`: CGFloat, _ `right`: CGFloat, _ prev: Int, _ next: Int) -> Void) -> Bool {
        
        guard let range = line?.range else {
            return false
        }
        if range.length == 0 {
            return false
        }
        var inside = false
        var _prev: Int = 0
        var _next: Int = 0
        
        guard let s = text?.string, let r = Range(range, in: s) else {
            return false
        }
        s.enumerateSubstrings(in: r, options: NSString.EnumerationOptions.byComposedCharacterSequences, { substring, substringRange, enclosingRange, stop in
            let tmpr = NSRange(substringRange, in: s)
            let prev = tmpr.location
            let next = tmpr.location + tmpr.length
            if prev == position || next == position {
                stop = true
            }
            if prev < position && position < next {
                inside = true
                _prev = prev
                _next = next
                stop = true
            }
        })
        if inside {
            let `left` = offset(for: _prev, lineIndex: line!.index)
            let `right` = offset(for: _next, lineIndex: line!.index)
            block(`left`, `right`, _prev, _next)
        }
        return inside
    }
    
    /**
     Whether the position is inside an emoji (such as National Flag Emoji).
     
     @param line     The text line.
     @param position Text text position in whole text.
     @param block    Yhe block to be executed before returns YES.
     left:  emoji's left X offset
     right: emoji's right X offset
     prev:  emoji's left position
     next:  emoji's right position
     */
    @discardableResult
    private func _insideEmoji(_ line: TextLine?, position: Int, block: @escaping (_ `left`: CGFloat, _ `right`: CGFloat, _ prev: Int, _ next: Int) -> Void) -> Bool {
        
        if line == nil {
            return false
        }
        let runs = CTLineGetGlyphRuns(line!.ctLine!)
        let rMax = CFArrayGetCount(runs)
        for r in 0..<rMax {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
            let glyphCount = CTRunGetGlyphCount(run)
            if glyphCount == 0 {
                continue
            }
            let range: CFRange = CTRunGetStringRange(run)
            if range.length <= 1 {
                continue
            }
            if position <= range.location || position >= range.location + range.length {
                continue
            }
            let attrs = CTRunGetAttributes(run) as! [String: AnyObject]
            
            let font = attrs[kCTFontAttributeName as String] as! CTFont
            if !TextUtilities.textCTFontContainsColorBitmapGlyphs(font) {
                continue
            }
            // Here's Emoji runs (larger than 1 unichar), and position is inside the range.
            let indices = UnsafeMutablePointer<CFIndex>.allocate(capacity: glyphCount)
            CTRunGetStringIndices(run, CFRangeMake(0, glyphCount), indices)
            for g in 0..<glyphCount {
                let prev: CFIndex = indices[g]
                let next: CFIndex = g + 1 < glyphCount ? indices[g + 1] : range.location + range.length
                if position == prev {
                    break // Emoji edge
                }
                if prev < position && position < next {
                    // inside an emoji (such as National Flag Emoji)
                    var pos = CGPoint.zero
                    var adv = CGSize.zero
                    CTRunGetPositions(run, CFRangeMake(g, 1), &pos)
                    CTRunGetAdvances(run, CFRangeMake(g, 1), &adv)
                    //if block
                    block(line?.position.x ?? 0 + pos.x, line?.position.x ?? 0 + pos.x + adv.width, prev, next)
                    
                    return true
                }
            }
            indices.deallocate()
        }
        return false
    }
    
    /**
     Whether the write direction is RTL at the specified point
     
     @param line  The text line
     @param point The point in layout.
     
     @return YES if RTL.
     */
    private func _isRightToLeft(in line: TextLine?, at point: CGPoint) -> Bool {
        if line == nil {
            return false
        }
        // get write direction
        var RTL = false
        let runs = CTLineGetGlyphRuns(line!.ctLine!)
        var r = 0, max = CFArrayGetCount(runs)
        while r < max {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
            var glyphPosition = CGPoint.zero
            CTRunGetPositions(run, CFRangeMake(0, 1), &glyphPosition)
            if container.isVerticalForm {
                var runX: CGFloat = glyphPosition.x
                runX += line?.position.y ?? 0
                let runWidth = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), nil, nil, nil))
                if runX <= point.y && point.y <= runX + runWidth {
                    if CTRunGetStatus(run).rawValue & CTRunStatus.rightToLeft.rawValue != 0 {
                        RTL = true
                    }
                    break
                }
            } else {
                var runX: CGFloat = glyphPosition.x
                runX += line?.position.x ?? 0
                let runWidth = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), nil, nil, nil))
                if runX <= point.x && point.x <= runX + runWidth {
                    if CTRunGetStatus(run).rawValue & CTRunStatus.rightToLeft.rawValue != 0 {
                        RTL = true
                    }
                    break
                }
            }
            r += 1
        }
        return RTL
    }
    
    /**
     Correct the range's edge.
     */
    private func _correctedRange(withEdge range: TextRange) -> TextRange? {
        var range = range
        let visibleRange = self.visibleRange
        var start = range.start
        var end = range.end
        if start.offset == visibleRange.location && start.affinity == TextAffinity.backward {
            start = TextPosition.position(with: start.offset, affinity: TextAffinity.forward)
        }
        if end.offset == visibleRange.location + visibleRange.length && start.affinity == TextAffinity.forward {
            end = TextPosition.position(with: end.offset, affinity: TextAffinity.backward)
        }
        if start != range.start || end != range.end {
            range = TextRange.range(with: start, end: end)
        }
        return range
    }

    
    // MARK: - Query information from text layout
    
    ///=============================================================================
    /// @name Query information from text layout
    ///=============================================================================
    
    /**
     The first line index for row.
     
     @param row  A row index.
     @return The line index, or NSNotFound if not found.
     */
    @objc(lineIndexForRow:)
    public func lineIndex(for row: Int) -> Int {
        if row >= rowCount {
            return NSNotFound
        }
        return lineRowsIndex![row]
    }
    
    /**
     The number of lines for row.
     
     @param row  A row index.
     @return The number of lines, or NSNotFound when an error occurs.
     */
    @objc(lineCountForRow:)
    public func lineCount(for row: Int) -> Int {
        if (row >= self.rowCount) { return NSNotFound }
        if (row == self.rowCount - 1) {
            return self.lines.count - lineRowsIndex![row]
        } else {
            return lineRowsIndex![row + 1] - lineRowsIndex![row]
        }
    }
    
    /**
     The row index for line.
     
     @param line A row index.
     
     @return The row index, or NSNotFound if not found.
     */
    public func rowIndex(for line: Int) -> Int {
        if line >= lines.count {
            return NSNotFound
        }
        return lines[line].row
    }
    
    /**
     The line index for a specified point.
     
     @discussion It returns NSNotFound if there's no text at the point.
     
     @param point  A point in the container.
     @return The line index, or NSNotFound if not found.
     */
    @objc(lineIndexForPoint:)
    public func lineIndex(for point: CGPoint) -> Int {
        if lines.count == 0 || rowCount == 0 {
            return NSNotFound
        }
        let rowIdx: Int = _rowIndex(for: container.isVerticalForm ? point.x : point.y)
        if rowIdx == NSNotFound {
            return NSNotFound
        }
        let lineIdx0: Int = lineRowsIndex![rowIdx]
        let lineIdx1: Int = (rowIdx == (rowCount - 1)) ? (lines.count - 1) : (lineRowsIndex![rowIdx + 1] - 1)
        for i in lineIdx0...lineIdx1 {
            let bounds = lines[i].bounds
            if bounds.contains(point) {
                return i
            }
        }
        return NSNotFound
    }
    
    /**
     The line index closest to a specified point.
     
     @param point  A point in the container.
     @return The line index, or NSNotFound if no line exist in layout.
     */
    @objc(closestLineIndexForPoint:)
    public func closestLineIndex(for point: CGPoint) -> Int {
        let isVertical = container.isVerticalForm
        if lines.count == 0 || rowCount == 0 {
            return NSNotFound
        }
        let rowIdx: Int = _closestRowIndex(forEdge: isVertical ? point.x : point.y)
        if rowIdx == NSNotFound {
            return NSNotFound
        }
        let lineIdx0: Int = lineRowsIndex![rowIdx]
        let lineIdx1: Int = (rowIdx == rowCount - 1) ? (lines.count - 1) : (lineRowsIndex![rowIdx + 1] - 1)
        if lineIdx0 == lineIdx1 {
            return lineIdx0
        }
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        var minIndex: Int = lineIdx0
        for i in lineIdx0...lineIdx1 {
            let bounds = lines[i].bounds
            if isVertical {
                if bounds.origin.y <= point.y && point.y <= bounds.origin.y + bounds.size.height {
                    return i
                }
                var distance: CGFloat = 0
                if point.y < bounds.origin.y {
                    distance = bounds.origin.y - point.y
                } else {
                    distance = point.y - (bounds.origin.y + bounds.size.height)
                }
                if distance < minDistance {
                    minDistance = distance
                    minIndex = i
                }
            } else {
                if bounds.origin.x <= point.x && point.x <= bounds.origin.x + bounds.size.width {
                    return i
                }
                var distance: CGFloat = 0
                if point.x < bounds.origin.x {
                    distance = bounds.origin.x - point.x
                } else {
                    distance = point.x - (bounds.origin.x + bounds.size.width)
                }
                if distance < minDistance {
                    minDistance = distance
                    minIndex = i
                }
            }
        }
        return minIndex
    }
    
    /**
     The offset in container for a text position in a specified line.
     
     @discussion The offset is the text position's baseline point.x.
     If the container is vertical form, the offset is the baseline point.y;
     
     @param textPosition   The text position in string.
     @param lineIndex  The line index.
     @return The offset in container, or CGFloat.greatestFiniteMagnitude if not found.
     */
    @objc(offsetForTextPosition:lineIndex:)
    public func offset(for textPosition: Int, lineIndex: Int) -> CGFloat {
        if lineIndex >= lines.count {
            return CGFloat.greatestFiniteMagnitude
        }
        let position = textPosition
        let line = lines[lineIndex]
        let range: CFRange = CTLineGetStringRange(line.ctLine!)
        if position < range.location || position > range.location + range.length {
            return CGFloat.greatestFiniteMagnitude
        }
        let offset: CGFloat = CTLineGetOffsetForStringIndex(line.ctLine!, position, nil)
        return container.isVerticalForm ? (offset + line.position.y) : (offset + line.position.x)
    }
    
    /**
     The text position for a point in a specified line.
     
     @discussion This method just call CTLineGetStringIndexForPosition() and does
     NOT consider the emoji, line break character, binding text...
     
     @param point      A point in the container.
     @param lineIndex  The line index.
     @return The text position, or NSNotFound if not found.
     */
    @objc(textPositionForPoint:lineIndex:)
    public func textPosition(for point: CGPoint, lineIndex: Int) -> Int {
        if lineIndex >= lines.count {
            return NSNotFound
        }
        var point = point
        let line = lines[lineIndex]
        if container.isVerticalForm {
            point.x = point.y - line.position.y
            point.y = 0
        } else {
            point.x -= line.position.x
            point.y = 0
        }
        var idx: CFIndex = CTLineGetStringIndexForPosition(line.ctLine!, point)
        if idx == kCFNotFound {
            return NSNotFound
        }
        
        /*
         If the emoji contains one or more variant form (such as ☔️ "\u2614\uFE0F")
         and the font size is smaller than 379/15, then each variant form ("\uFE0F")
         will rendered as a single blank glyph behind the emoji glyph. Maybe it's a
         bug in CoreText? Seems iOS8.3 fixes this problem.
         
         If the point hit the blank glyph, the CTLineGetStringIndexForPosition()
         returns the position before the emoji glyph, but it should returns the
         position after the emoji and variant form.
         
         Here's a workaround.
         */
        let runs = CTLineGetGlyphRuns(line.ctLine!)
        var r = 0, max = CFArrayGetCount(runs)
        while r < max {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
            let range: CFRange = CTRunGetStringRange(run)
            if range.location <= idx && idx < range.location + range.length {
                let glyphCount: Int = CTRunGetGlyphCount(run)
                if glyphCount == 0 {
                    break
                }
                let attrs = CTRunGetAttributes(run) as! [String: AnyObject]
                let font = attrs[kCTFontAttributeName as String] as! CTFont
                if !TextUtilities.textCTFontContainsColorBitmapGlyphs(font) {
                    break
                }
                let indices = UnsafeMutablePointer<CFIndex>.allocate(capacity: glyphCount)
                let positions = UnsafeMutablePointer<CGPoint>.allocate(capacity: glyphCount)
                CTRunGetStringIndices(run, CFRangeMake(0, glyphCount), indices)
                CTRunGetPositions(run, CFRangeMake(0, glyphCount), positions)
                for g in 0..<glyphCount {
                    let gIdx: Int = indices[g]
                    if gIdx == idx && g + 1 < glyphCount {
                        let `right`: CGFloat = positions[g + 1].x
                        if point.x < `right` {
                            break
                        }
                        var next: Int = indices[g + 1]
                        repeat {
                            if next == range.location + range.length {
                                break
                            }
                            let c = (text!.string as NSString).character(at: next)
                            if (c == 0xfe0e || c == 0xfe0f) {
                                // unicode variant form for emoji style
                                next += 1
                            } else {
                                break
                            }
                        } while true
                        if next != indices[g + 1] {
                            idx = next
                        }
                        break
                    }
                }
                indices.deallocate()
                positions.deallocate()
                break
            }
            r += 1
        }
        return idx
    }
    
    /**
     The closest text position to a specified point.
     
     @discussion This method takes into account the restrict of emoji, line break
     character, binding text and text affinity.
     
     @param point  A point in the container.
     @return A text position, or nil if not found.
     */
    @objc(closestPositionToPoint:)
    public func closestPosition(to point: CGPoint) -> TextPosition? {
        let isVertical: Bool = container.isVerticalForm
        var point = point
        // When call CTLineGetStringIndexForPosition() on ligature such as 'fi',
        // and the point `hit` the glyph's left edge, it may get the ligature inside offset.
        // I don't know why, maybe it's a bug of CoreText. Try to avoid it.
        if isVertical {
            point.y += 0.00001234
        } else {
            point.x += 0.00001234
        }
        var lineIndex: Int = closestLineIndex(for: point)
        if lineIndex == NSNotFound {
            return nil
        }
        var line: TextLine? = lines[lineIndex]
        var position: Int = textPosition(for: point, lineIndex: lineIndex)
        if position == NSNotFound {
            position = line?.range.location ?? 0
        }
        if position <= visibleRange.location {
            return TextPosition.position(with: visibleRange.location, affinity: TextAffinity.forward)
        } else if position >= visibleRange.location + visibleRange.length {
            return TextPosition.position(with: visibleRange.location + visibleRange.length, affinity: TextAffinity.backward)
        }
        var finalAffinity = TextAffinity.forward
        var finalAffinityDetected = false
        // binding range
        var bindingRange = NSRange(location: 0, length: 0)
        let binding = text!.attribute(NSAttributedString.Key(rawValue: TextAttribute.textBindingAttributeName), at: position, longestEffectiveRange: &bindingRange, in: NSRange(location: 0, length: text!.length))
        
        if let _ = binding, bindingRange.length > 0 {
            let headLineIdx: Int = self.lineIndex(for: TextPosition.position(with: bindingRange.location))
            let tailLineIdx: Int = self.lineIndex(for: TextPosition.position(with: bindingRange.location + bindingRange.length, affinity: TextAffinity.backward))
            if headLineIdx == lineIndex && lineIndex == tailLineIdx {
                // all in same line
                let `left` = offset(for: bindingRange.location, lineIndex: lineIndex)
                let `right` = offset(for: bindingRange.location + bindingRange.length, lineIndex: lineIndex)
                if `left` != CGFloat.greatestFiniteMagnitude && `right` != CGFloat.greatestFiniteMagnitude {
                    if container.isVerticalForm {
                        if abs(Float(point.y - `left`)) < abs(Float(point.y - `right`)) {
                            position = bindingRange.location
                            finalAffinity = TextAffinity.forward
                        } else {
                            position = bindingRange.location + bindingRange.length
                            finalAffinity = TextAffinity.backward
                        }
                    } else {
                        if abs(Float(point.x - `left`)) < abs(Float(point.x - `right`)) {
                            position = bindingRange.location
                            finalAffinity = TextAffinity.forward
                        } else {
                            position = bindingRange.location + bindingRange.length
                            finalAffinity = TextAffinity.backward
                        }
                    }
                } else if `left` != CGFloat.greatestFiniteMagnitude {
                    position = Int(`left`)
                    finalAffinity = TextAffinity.forward
                } else if `right` != CGFloat.greatestFiniteMagnitude {
                    position = Int(`right`)
                    finalAffinity = TextAffinity.backward
                }
                finalAffinityDetected = true
            } else if headLineIdx == lineIndex {
                let `left`: CGFloat = offset(for: bindingRange.location, lineIndex: lineIndex)
                if `left` != CGFloat.greatestFiniteMagnitude {
                    position = bindingRange.location
                    finalAffinity = TextAffinity.forward
                    finalAffinityDetected = true
                }
            } else if tailLineIdx == lineIndex {
                let `right`: CGFloat = offset(for: bindingRange.location + bindingRange.length, lineIndex: lineIndex)
                if `right` != CGFloat.greatestFiniteMagnitude {
                    position = bindingRange.location + bindingRange.length
                    finalAffinity = TextAffinity.backward
                    finalAffinityDetected = true
                }
            } else {
                var onLeft = false
                var onRight = false
                if headLineIdx != NSNotFound && tailLineIdx != NSNotFound {
                    if abs(headLineIdx - lineIndex) < abs(tailLineIdx - lineIndex) {
                        onLeft = true
                    } else {
                        onRight = true
                    }
                } else if headLineIdx != NSNotFound {
                    onLeft = true
                } else if tailLineIdx != NSNotFound {
                    onRight = true
                }
                if onLeft {
                    let `left` = offset(for: bindingRange.location, lineIndex: headLineIdx)
                    if `left` != CGFloat.greatestFiniteMagnitude {
                        lineIndex = headLineIdx
                        line = lines[headLineIdx]
                        position = bindingRange.location
                        finalAffinity = TextAffinity.forward
                        finalAffinityDetected = true
                    }
                } else if onRight {
                    let `right` = offset(for: bindingRange.location + bindingRange.length, lineIndex: tailLineIdx)
                    if `right` != CGFloat.greatestFiniteMagnitude {
                        lineIndex = tailLineIdx
                        line = lines[tailLineIdx]
                        position = bindingRange.location + bindingRange.length
                        finalAffinity = TextAffinity.backward
                        finalAffinityDetected = true
                    }
                }
            }
        }
        
        // empty line
        if line!.range.length == 0 {
            let behind: Bool = lines.count > 1 && lineIndex == lines.count - 1 //end line
            return TextPosition.position(with: line!.range.location, affinity: behind ? TextAffinity.backward : TextAffinity.forward)
        }
        // detect weather the line is a linebreak token
        if line!.range.length <= 2 {
            let r = line!.range
            let str = text!.string.subString(start: r.location, end: r.location + r.length)
            if TextUtilities.textIsLinebreakString(str) {
                // an empty line ("\r", "\n", "\r\n")
                return TextPosition.position(with: line!.range.location)
            }
        }
        // above whole text frame
        if lineIndex == 0 && (isVertical ? (point.x > line!.right) : (point.y < line!.top)) {
            position = 0
            finalAffinity = TextAffinity.forward
            finalAffinityDetected = true
        }
        // below whole text frame
        if lineIndex == lines.count - 1 && (isVertical ? (point.x < line!.left) : (point.y > line!.bottom)) {
            position = line!.range.location + line!.range.length
            finalAffinity = TextAffinity.backward
            finalAffinityDetected = true
        }
        
        // There must be at least one non-linebreak char,
        // ignore the linebreak characters at line end if exists.
        // There must be at least one non-linebreak char,
        // ignore the linebreak characters at line end if exists.
        if position >= line!.range.location + line!.range.length - 1 {
            if position > line!.range.location {
                let c1 = (text!.string as NSString).character(at: position - 1)
                if TextUtilities.textIsLinebreakChar(c1) {
                    position -= 1
                    if position > line!.range.location {
                        let c0 = (text!.string as NSString).character(at: position - 1)
                        if TextUtilities.textIsLinebreakChar(c0) {
                            position -= 1
                        }
                    }
                }
            }
        }
        if position == line!.range.location {
            return TextPosition.position(with: position)
        }
        if position == line!.range.location + line!.range.length {
            return TextPosition.position(with: position, affinity: TextAffinity.backward)
        }
        
        _insideComposedCharacterSequences(line, position: position) { `left`, `right`, prev, next in
            if isVertical {
                position = (abs(Float(`left` - point.y)) < abs(Float(`right` - point.y))) && (abs(Float(`right` - point.y)) < Float(`right` != 0 ? prev : next)) ? 1 : 0
            } else {
                position = (abs(Float(`left` - point.x)) < abs(Float(`right` - point.x))) && (abs(Float(`right` - point.x)) < Float(`right` != 0 ? prev : next)) ? 1 : 0
            }
        }
        
        _insideEmoji(line, position: position) { `left`, `right`, prev, next in
            if isVertical {
                position = (abs(Float(`left` - point.y)) < abs(Float(`right` - point.y))) && (abs(Float(`right` - point.y)) < Float(`right` != 0 ? prev : next)) ? 1 : 0
            } else {
                position = (abs(Float(`left` - point.x)) < abs(Float(`right` - point.x))) && (abs(Float(`right` - point.x)) < Float(`right` != 0 ? prev : next)) ? 1 : 0
            }
        }
        
        if position < visibleRange.location {
            position = visibleRange.location
        } else if position > visibleRange.location + visibleRange.length {
            position = visibleRange.location + visibleRange.length
        }
        if !finalAffinityDetected {
            let ofs: CGFloat = offset(for: position, lineIndex: lineIndex)
            if ofs != CGFloat.greatestFiniteMagnitude {
                let RTL: Bool = _isRightToLeft(in: line, at: point)
                if position >= line!.range.location + line!.range.length {
                    finalAffinity = RTL ? TextAffinity.forward : TextAffinity.backward
                } else if position <= line!.range.location {
                    finalAffinity = RTL ? TextAffinity.backward : TextAffinity.forward
                } else {
                    finalAffinity = (ofs < (isVertical ? point.y : point.x) && !RTL) ? TextAffinity.forward : TextAffinity.backward
                }
            }
        }
        return TextPosition.position(with: position, affinity: finalAffinity)
    }
    
    /**
     Returns the new position when moving selection grabber in text view.
     
     @discussion There are two grabber in the text selection period, user can only
     move one grabber at the same time.
     
     @param point          A point in the container.
     @param oldPosition    The old text position for the moving grabber.
     @param otherPosition  The other position in text selection view.
     
     @return A text position, or nil if not found.
     */
    @objc(positionForPoint:oldPosition:otherPosition:)
    public func position(for point: CGPoint, oldPosition: TextPosition?, otherPosition: TextPosition?) -> TextPosition? {
        guard let old = oldPosition, let other = otherPosition else {
            return oldPosition
        }
        var point = point
        var newPos = closestPosition(to: point)
        if newPos == nil {
            return oldPosition
        }
        if newPos?.compare(otherPosition) == old.compare(otherPosition) && newPos?.offset != other.offset {
            return newPos
        }
        let lineIndex: Int = self.lineIndex(for: otherPosition)
        if lineIndex == NSNotFound {
            return oldPosition
        }
        let line = lines[lineIndex]
        let vertical = lineRowsEdge![line.row]
        
        if container.isVerticalForm {
            point.x = (vertical.head + vertical.foot) * 0.5
        } else {
            point.y = (vertical.head + vertical.foot) * 0.5
        }
        newPos = closestPosition(to: point)
        if newPos?.compare(otherPosition) == old.compare(otherPosition) && newPos?.offset != other.offset {
            return newPos
        }
        
        if container.isVerticalForm {
            if old.compare(other) == .orderedAscending {
                // search backward
                let range: TextRange? = textRange(byExtending: otherPosition, in: UITextLayoutDirection.up, offset: 1)
                if range != nil {
                    return range?.start
                }
            } else {
                // search forward
                let range: TextRange? = textRange(byExtending: otherPosition, in: UITextLayoutDirection.down, offset: 1)
                if range != nil {
                    return range?.end
                }
            }
        } else {
            if old.compare(other) == .orderedAscending {
                // search backward
                let range: TextRange? = textRange(byExtending: otherPosition, in: UITextLayoutDirection.left, offset: 1)
                if range != nil {
                    return range?.start
                }
            } else {
                // search forward
                let range: TextRange? = textRange(byExtending: otherPosition, in: UITextLayoutDirection.right, offset: 1)
                if range != nil {
                    return range?.end
                }
            }
        }
        return oldPosition
    }
    
    
    /**
     Returns the character or range of characters that is at a given point in the container.
     If there is no text at the point, returns nil.
     
     @discussion This method takes into account the restrict of emoji, line break
     character, binding text and text affinity.
     
     @param point  A point in the container.
     @return An object representing a range that encloses a character (or characters)
     at point. Or nil if not found.
     */
    @objc(textRangeAtPoint:)
    public func textRange(at point: CGPoint) -> TextRange? {
        let lineIndex: Int = self.lineIndex(for: point)
        if lineIndex == NSNotFound {
            return nil
        }
        let textPosition: Int = self.textPosition(for: point, lineIndex: lineIndex)
        if textPosition == NSNotFound {
            return nil
        }
        let pos = self.closestPosition(to: point)
        if pos == nil {
            return nil
        }
        // get write direction
        let RTL: Bool = _isRightToLeft(in: lines[lineIndex], at: point)
        let rect = caretRect(for: pos!)
        
        if rect.isNull {
            return nil
        }
        if container.isVerticalForm {
            let range: TextRange? = textRange(byExtending: pos, in: ((rect.origin.y ) >= point.y && !RTL) ? .up : .down, offset: 1)
            return range
        } else {
            let range: TextRange? = textRange(byExtending: pos, in: ((rect.origin.x ) >= point.x && !RTL) ? .left : .right, offset: 1)
            return range
        }
    }
    
    /**
     Returns the closest character or range of characters that is at a given point in
     the container.
     
     @discussion This method takes into account the restrict of emoji, line break
     character, binding text and text affinity.
     
     @param point  A point in the container.
     @return An object representing a range that encloses a character (or characters)
     at point. Or nil if not found.
     */
    @objc(closestTextRangeAtPoint:)
    public func closestTextRange(at point: CGPoint) -> TextRange? {
        let pos = closestPosition(to: point)
        if pos == nil {
            return nil
        }
        let lineIndex: Int = self.lineIndex(for: pos)
        if lineIndex == NSNotFound {
            return nil
        }
        let line = lines[lineIndex]
        let RTL: Bool = _isRightToLeft(in: line, at: point)
        let rect = caretRect(for: pos!)
        
        if rect.isNull {
            return nil
        }
        var direction: UITextLayoutDirection = .right
        if pos!.offset >= line.range.location + line.range.length {
            if direction.rawValue != (RTL ? 1 : 0) {
                direction = container.isVerticalForm ? .up : .left
            } else {
                direction = container.isVerticalForm ? .down : .right
            }
        } else if pos!.offset <= line.range.location {
            if direction.rawValue != (RTL ? 1 : 0) {
                direction = container.isVerticalForm ? .down : .right
            } else {
                direction = container.isVerticalForm ? .up : .left
            }
        } else {
            if container.isVerticalForm {
                direction = ((rect.origin.y ) >= point.y && !RTL) ? .up : .down
            } else {
                direction = ((rect.origin.x ) >= point.x && !RTL) ? .left : .right
            }
        }
        let range: TextRange? = textRange(byExtending: pos, in: direction, offset: 1)
        return range
    }
    
    /**
     If the position is inside an emoji, composed character sequences, line break '\\r\\n'
     or custom binding range, then returns the range by extend the position. Otherwise,
     returns a zero length range from the position.
     
     @param position A text-position object that identifies a location in layout.
     
     @return A text-range object that extend the position. Or nil if an error occurs
     */
    @objc(textRangeByExtendingPosition:)
    public func textRange(byExtending position: TextPosition?) -> TextRange? {
        
        let visibleStart: Int = visibleRange.location
        let visibleEnd: Int = visibleRange.location + visibleRange.length
        guard let p = position, p.offset >= visibleStart, p.offset <= visibleEnd else {
            return nil
        }
        
        // head or tail, returns immediately
        if p.offset == visibleStart {
            return TextRange.range(with: NSRange(location: p.offset, length: 0))
        } else if p.offset == visibleEnd {
            return TextRange.range(with: NSRange(location: p.offset, length: 0), affinity: TextAffinity.backward)
        }
        
        // binding range
        var tRange = NSRange(location: 0, length: 0)
        let binding = text!.attribute(NSAttributedString.Key(rawValue: TextAttribute.textBindingAttributeName), at: p.offset, longestEffectiveRange: &tRange, in: visibleRange)
        if binding != nil && tRange.length != 0 && tRange.location < p.offset {
            return TextRange.range(with: tRange)
        }
        // inside emoji or composed character sequences
        let lineIndex: Int = self.lineIndex(for: position)
        
        if lineIndex != NSNotFound {
            var _prev: Int = 0
            var _next: Int = 0
            var emoji = false
            var seq = false
            let line = lines[lineIndex]
            emoji = _insideEmoji(line, position: p.offset, block: { `left`, `right`, prev, next in
                _prev = prev
                _next = next
            })
            if !emoji {
                seq = _insideComposedCharacterSequences(line, position: p.offset, block: { `left`, `right`, prev, next in
                    _prev = prev
                    _next = next
                })
            }
            if emoji || seq {
                return TextRange.range(with: NSRange(location: _prev, length:_next - _prev))
            }
        }
        
        // inside linebreak '\r\n'
        if p.offset > visibleStart && p.offset < visibleEnd {
            
            let c0 = (text!.string as NSString).character(at: p.offset - 1)
            if (c0 == ("\r" as NSString).character(at: 0)) && p.offset < visibleEnd {
                let c1 = (text!.string as NSString).character(at: p.offset)
                if c1 == ("\n" as NSString).character(at: 0) {
                    return TextRange.range(with: TextPosition.position(with: p.offset - 1), end: TextPosition.position(with: p.offset + 1))
                }
            }
            if TextUtilities.textIsLinebreakChar(c0) && p.affinity == TextAffinity.backward {
                let str = (text!.string as NSString).substring(to: p.offset)
                let len: Int = TextUtilities.textLinebreakTailLength(str)
                return TextRange.range(with: TextPosition.position(with: p.offset - len), end: TextPosition.position(with: p.offset))
            }
        }
        
        return TextRange.range(with: NSRange(location: p.offset, length: 0), affinity: p.affinity)
    }
    
    /**
     Returns a text range at a given offset in a specified direction from another
     text position to its farthest extent in a certain direction of layout.
     
     @param position  A text-position object that identifies a location in layout.
     @param direction A constant that indicates a direction of layout (right, left, up, down).
     @param offset    A character offset from position.
     
     @return A text-range object that represents the distance from position to the
     farthest extent in direction. Or nil if an error occurs.
     */
    @objc(textRangeByExtendingPosition:inDirection:offset:)
    public func textRange(byExtending position: TextPosition?, in direction: UITextLayoutDirection, offset: Int) -> TextRange? {
        
        let visibleStart: Int = visibleRange.location
        let visibleEnd: Int = visibleRange.location + visibleRange.length
        guard let p = position, p.offset >= visibleStart, p.offset <= visibleEnd else {
            return nil
        }
        if offset == 0 {
            return textRange(byExtending: position)
        }
        var offset = offset
        
        let isVerticalForm = container.isVerticalForm
        var verticalMove = false
        var forwardMove = false
        if isVerticalForm {
            verticalMove = direction == .left || direction == .right
            forwardMove = direction == .left || direction == .down
        } else {
            verticalMove = direction == .up || direction == .down
            forwardMove = direction == .down || direction == .right
        }
        if offset < 0 {
            forwardMove = !forwardMove
            offset = -offset
        }
        // head or tail, returns immediately
        if !forwardMove && p.offset == visibleStart {
            return TextRange.range(with: NSRange(location: visibleRange.location, length: 0))
        } else if forwardMove && p.offset == visibleEnd {
            return TextRange.range(with: NSRange(location: p.offset, length: 0), affinity: TextAffinity.backward)
        }

        // extend from position
        guard let fromRange = textRange(byExtending: p) else {
            return nil
        }
        let allForward = TextRange.range(with: fromRange.start, end: TextPosition.position(with: visibleEnd))
        let allBackward = TextRange.range(with: TextPosition.position(with: visibleStart), end: fromRange.end)
        
        if (verticalMove) { // up/down in text layout
            
            let lineIndex: Int = self.lineIndex(for: position)
            if lineIndex == NSNotFound {
                return nil
            }
            let line = lines[lineIndex]
            let moveToRowIndex = line.row + (forwardMove ? offset : -offset)
            if moveToRowIndex < 0 {
                return allBackward
            } else if moveToRowIndex >= Int(rowCount) {
                return allForward
            }
            let ofs: CGFloat = self.offset(for: p.offset, lineIndex: lineIndex)
            if ofs == CGFloat.greatestFiniteMagnitude {
                return nil
            }
            let moveToLineFirstIndex: Int = self.lineIndex(for: moveToRowIndex)
            let moveToLineCount: Int = lineCount(for: moveToRowIndex)
            if moveToLineFirstIndex == NSNotFound || moveToLineCount == NSNotFound || moveToLineCount == 0 {
                return nil
            }
            var mostLeft: CGFloat = CGFloat.greatestFiniteMagnitude
            var mostRight: CGFloat = -CGFloat.greatestFiniteMagnitude
            var mostLeftLine = TextLine()
            var mostRightLine = TextLine()
            var insideIndex: Int = NSNotFound
            
            for i in 0..<moveToLineCount {
                let lineIndex: Int = moveToLineFirstIndex + i
                let line = lines[lineIndex]
                if isVerticalForm {
                    if line.top <= ofs && ofs <= line.bottom {
                        insideIndex = line.index
                        break
                    }
                    if line.top < mostLeft {
                        mostLeft = line.top
                        mostLeftLine = line
                    }
                    if line.bottom > mostRight {
                        mostRight = line.bottom
                        mostRightLine = line
                    }
                } else {
                    if line.left <= ofs && ofs <= line.right {
                        insideIndex = line.index
                        break
                    }
                    if line.left < mostLeft {
                        mostLeft = line.left
                        mostLeftLine = line
                    }
                    if line.right > mostRight {
                        mostRight = line.right
                        mostRightLine = line
                    }
                }
            }
            
            var afinityEdge = false
            if insideIndex == NSNotFound {
                if ofs <= mostLeft {
                    insideIndex = mostLeftLine.index
                } else {
                    insideIndex = mostRightLine.index
                }
                afinityEdge = true
            }
            let insideLine = lines[insideIndex]
            var pos: Int = 0
            if isVerticalForm {
                pos = textPosition(for: CGPoint(x: insideLine.position.x, y: ofs), lineIndex: insideIndex)
            } else {
                pos = textPosition(for: CGPoint(x: ofs, y: insideLine.position.y), lineIndex: insideIndex)
            }
            if pos == NSNotFound {
                return nil
            }
            var extPos: TextPosition?
            
            if afinityEdge {
                if pos == insideLine.range.location + insideLine.range.length {
                    let subStr = text!.string.subString(start: insideLine.range.location, end:insideLine.range.location + insideLine.range.length)
                    let lineBreakLen: Int = TextUtilities.textLinebreakTailLength(subStr)
                    extPos = TextPosition.position(with: pos - lineBreakLen)
                } else {
                    extPos = TextPosition.position(with: pos)
                }
            } else {
                extPos = TextPosition.position(with: pos)
            }
            
            guard let ext = textRange(byExtending: extPos) else {
                return nil
            }
            if forwardMove {
                return TextRange.range(with: fromRange.start, end: ext.end)
            } else {
                return TextRange.range(with: ext.start, end: fromRange.end)
            }
        } else {
            let toPosition = TextPosition.position(with: p.offset + (forwardMove ? offset : -offset))
            if toPosition.offset <= visibleStart {
                return allBackward
            } else if toPosition.offset >= visibleEnd {
                return allForward
            }
            
            guard let toRange = textRange(byExtending: toPosition) else {
                return nil
            }
            let start: Int = min(fromRange.start.offset, toRange.start.offset)
            let end: Int = max(fromRange.end.offset, toRange.end.offset)
            return TextRange.range(with: NSRange(location: start, length: end - start))
        }
    }

    /**
     Returns the line index for a given text position.
     
     @discussion This method takes into account the text affinity.
     
     @param position A text-position object that identifies a location in layout.
     @return The line index, or NSNotFound if not found.
     */
    @objc(lineIndexForPosition:)
    public func lineIndex(for position: TextPosition?) -> Int {
        guard let p = position else {
            return NSNotFound
        }
        if lines.count == 0 {
            return NSNotFound
        }
        let location = p.offset
        var lo: Int = 0
        var hi: Int = lines.count - 1
        var mid: Int = 0
        if position?.affinity == TextAffinity.backward {
            while lo <= hi {
                mid = (lo + hi) / 2
                let line = lines[mid]
                let range = line.range
                if (range.location < location) && (location <= (range.location + range.length)) {
                    return mid
                }
                if location <= range.location {
                    hi = mid - 1
                } else {
                    lo = mid + 1
                }
            }
        } else {
            while lo <= hi {
                mid = (lo + hi) / 2
                let line = lines[mid]
                let range = line.range
                if (range.location <= location) && (location < (range.location + range.length)) {
                    return mid
                }
                if location < range.location {
                    hi = mid - 1
                } else {
                    lo = mid + 1
                }
            }
        }
        return NSNotFound
    }
    
    /**
     Returns the baseline position for a given text position.
     
     @param position An object that identifies a location in the layout.
     @return The baseline position for text, or CGPointZero if not found.
     */
    @objc(linePositionForPosition:)
    public func linePosition(for position: TextPosition?) -> CGPoint {
        let lineIndex = self.lineIndex(for: position)
        if lineIndex == NSNotFound {
            return CGPoint.zero
        }
        let line = lines[lineIndex]
        let offset = self.offset(for: position!.offset, lineIndex: lineIndex)
        if offset == CGFloat.greatestFiniteMagnitude {
            return CGPoint.zero
        }
        if container.isVerticalForm {
            return CGPoint(x: line.position.x, y: offset)
        } else {
            return CGPoint(x: offset, y: line.position.y)
        }
    }
    
    /**
     Returns a rectangle used to draw the caret at a given insertion point.
     
     @param position An object that identifies a location in the layout.
     @return A rectangle that defines the area for drawing the caret. The width is
     always zero in normal container, the height is always zero in vertical form container.
     If not found, it returns CGRectNull.
     */
    @objc(caretRectForPosition:)
    public func caretRect(for position: TextPosition) -> CGRect {
        let lineIndex = self.lineIndex(for: position)
        if lineIndex == NSNotFound {
            return CGRect.null
        }
        let line = lines[lineIndex]
        let offset = self.offset(for: position.offset, lineIndex: lineIndex)
        if offset == CGFloat.greatestFiniteMagnitude {
            return CGRect.null
        }
        if container.isVerticalForm {
            return CGRect(x: line.bounds.origin.x, y: offset, width: line.bounds.size.width, height: 0)
        } else {
            return CGRect(x: offset, y: line.bounds.origin.y, width: 0, height: line.bounds.size.height)
        }
    }
    
    /**
     Returns the first rectangle that encloses a range of text in the layout.
     
     @param range An object that represents a range of text in layout.
     
     @return The first rectangle in a range of text. You might use this rectangle to
     draw a correction rectangle. The "first" in the name refers the rectangle
     enclosing the first line when the range encompasses multiple lines of text.
     If not found, it returns CGRectNull.
     */
    @objc(firstRectForRange:)
    public func firstRect(for range: TextRange) -> CGRect {
        var range = range
        range = _correctedRange(withEdge: range)!
        let startLineIndex: Int = self.lineIndex(for: range.start)
        let endLineIndex: Int = self.lineIndex(for: range.end)
        if startLineIndex == NSNotFound || endLineIndex == NSNotFound {
            return CGRect.null
        }
        if startLineIndex > endLineIndex {
            return CGRect.null
        }
        let startLine = self.lines[startLineIndex]
        let endLine = self.lines[endLineIndex]
        var lines_ = [TextLine]()
        for i in startLineIndex...startLineIndex {
            let line = self.lines[i]
            if line.row != startLine.row {
                break
            }
            lines_.append(line)
        }
        if container.isVerticalForm {
            if lines_.count == 1 {
                var top: CGFloat = self.offset(for: range.start.offset, lineIndex: startLineIndex)
                var bottom: CGFloat = 0
                if startLine == endLine {
                    bottom = self.offset(for: range.end.offset, lineIndex: startLineIndex)
                } else {
                    bottom = startLine.bottom
                }
                if top == CGFloat.greatestFiniteMagnitude || bottom == CGFloat.greatestFiniteMagnitude {
                    return CGRect.null
                }
                if top > bottom {
                    (top, bottom) = (bottom, top)
                }
                return CGRect(x: startLine.left, y: top, width: startLine.width, height: bottom - top)
            } else {
                var top: CGFloat = self.offset(for: range.start.offset, lineIndex: startLineIndex)
                var bottom: CGFloat = startLine.bottom
                if top == CGFloat.greatestFiniteMagnitude || bottom == CGFloat.greatestFiniteMagnitude {
                    return CGRect.null
                }
                if top > bottom {
                    (top, bottom) = (bottom, top)
                }
                var rect = CGRect(x: startLine.left, y: top, width: startLine.width, height: bottom - top)
                for i in 1..<lines_.count {
                    let line = lines_[i]
                    rect = rect.union(line.bounds)
                }
                return rect
            }
        } else {
            if lines_.count == 1 {
                var `left`: CGFloat = offset(for: range.start.offset, lineIndex: startLineIndex)
                var `right`: CGFloat = 0
                if startLine == endLine {
                    `right` = offset(for: range.end.offset, lineIndex: startLineIndex)
                } else {
                    `right` = startLine.right
                }
                if `left` == CGFloat.greatestFiniteMagnitude || `right` == CGFloat.greatestFiniteMagnitude {
                    return CGRect.null
                }
                if `left` > `right` {
                    (`left`, `right`) = (`right`, `left`)
                }
                return CGRect(x: `left`, y: startLine.top, width: `right` - `left`, height: startLine.height)
            } else {
                var `left`: CGFloat = offset(for: range.start.offset, lineIndex: startLineIndex)
                var `right`: CGFloat = startLine.right
                if `left` == CGFloat.greatestFiniteMagnitude || `right` == CGFloat.greatestFiniteMagnitude {
                    return CGRect.null
                }
                if `left` > `right` {
                    (`left`, `right`) = (`right`, `left`)
                }
                var rect = CGRect(x: `left`, y: startLine.top, width: `right` - `left`, height: startLine.height)
                for i in 1..<lines_.count {
                    let line = lines_[i]
                    rect = rect.union(line.bounds)
                }
                return rect
            }
        }
    }
    
    /**
     Returns the rectangle union that encloses a range of text in the layout.
     
     @param range An object that represents a range of text in layout.
     
     @return A rectangle that defines the area than encloses the range.
     If not found, it returns CGRectNull.
     */
    @objc(rectForRange:)
    public func rect(for range: TextRange?) -> CGRect {
        var rects: [UITextSelectionRect]? = nil
        if let aRange = range {
            rects = selectionRects(for: aRange)
        }
        guard let r = rects, r.count > 0 else {
            return CGRect.null
        }
        var rectUnion = r.first!.rect
        for rect in r {
            rectUnion = rectUnion.union(rect.rect)
        }
        return rectUnion
    }
    
    /**
     Returns an array of selection rects corresponding to the range of text.
     The start and end rect can be used to show grabber.
     
     @param range An object representing a range in text.
     @return An array of `TextSelectionRect` objects that encompass the selection.
     If not found, the array is empty.
     */
    @objc(selectionRectsForRange:)
    public func selectionRects(for range: TextRange) -> [TextSelectionRect] {
        
        let range = _correctedRange(withEdge: range)!
        let isVertical = container.isVerticalForm
        var rects: [TextSelectionRect] = []
        
        var startLineIndex: Int = lineIndex(for: range.start)
        var endLineIndex: Int = lineIndex(for: range.end)
        if startLineIndex == NSNotFound || endLineIndex == NSNotFound {
            return rects
        }
        if startLineIndex > endLineIndex {
            TextUtilities.numberSwap(&startLineIndex, b: &endLineIndex)
        }
        let startLine = lines[startLineIndex]
        let endLine = lines[endLineIndex]
        var offsetStart: CGFloat = offset(for: range.start.offset, lineIndex: startLineIndex)
        var offsetEnd: CGFloat = offset(for: range.end.offset, lineIndex: endLineIndex)
        let start = TextSelectionRect()
        if isVertical {
            start.rect = CGRect(x: startLine.left, y: offsetStart, width: startLine.width, height: 0)
        } else {
            start.rect = CGRect(x: offsetStart, y: startLine.top, width: 0, height: startLine.height)
        }
        start.containsStart = true
        start.isVertical = isVertical
        rects.append(start)
        let end = TextSelectionRect()
        if isVertical {
            end.rect = CGRect(x: endLine.left, y: offsetEnd, width: endLine.width, height: 0)
        } else {
            end.rect = CGRect(x: offsetEnd, y: endLine.top, width: 0, height: endLine.height)
        }
        end.containsEnd = true
        end.isVertical = isVertical
        rects.append(end)
        
        if startLine.row == endLine.row {
            // same row
            if offsetStart > offsetEnd {
                TextUtilities.numberSwap(&offsetStart, b: &offsetEnd)
            }
            let rect = TextSelectionRect()
            if isVertical {
                rect.rect = CGRect(x: startLine.bounds.origin.x, y: offsetStart, width: max(startLine.width, endLine.width), height: offsetEnd - offsetStart)
            } else {
                rect.rect = CGRect(x: offsetStart, y: startLine.bounds.origin.y, width: offsetEnd - offsetStart, height: max(startLine.height, endLine.height))
            }
            rect.isVertical = isVertical
            rects.append(rect)
        } else { // more than one row
            
            // start line select rect
            let topRect = TextSelectionRect()
            topRect.isVertical = isVertical
            let topOffset: CGFloat = offset(for: range.start.offset, lineIndex: startLineIndex)
            let topRun = _run(for: startLine, position: range.start)
            if topRun != nil && (CTRunGetStatus(topRun!).rawValue & CTRunStatus.rightToLeft.rawValue) != 0 {
                if isVertical {
                    topRect.rect = CGRect(x: startLine.left, y: (container.path != nil) ? startLine.top : container.insets.top, width: startLine.width, height: topOffset - startLine.top)
                } else {
                    topRect.rect = CGRect(x: (container.path != nil) ? startLine.left : container.insets.left, y: startLine.top, width: topOffset - startLine.left, height: startLine.height)
                }
                topRect.writingDirection = UITextWritingDirection.rightToLeft
            } else {
                if isVertical {
                    topRect.rect = CGRect(x: startLine.left, y: topOffset, width: startLine.width, height: ((container.path != nil) ? startLine.bottom : container.size.height - container.insets.bottom) - topOffset)
                } else {
                    topRect.rect = CGRect(x: topOffset, y: startLine.top, width: ((container.path != nil) ? startLine.right : container.size.width - container.insets.right) - topOffset, height: startLine.height)
                }
            }
            rects.append(topRect)
            // end line select rect
            let bottomRect = TextSelectionRect()
            bottomRect.isVertical = isVertical
            let bottomOffset: CGFloat = offset(for: range.end.offset, lineIndex: endLineIndex)
            let bottomRun = _run(for: endLine, position: range.end)
            
            if (bottomRun != nil) && (CTRunGetStatus(bottomRun!).rawValue & CTRunStatus.rightToLeft.rawValue) != 0 {
                if isVertical {
                    bottomRect.rect = CGRect(x: endLine.left, y: bottomOffset, width: endLine.width, height: ((container.path != nil) ? endLine.bottom : container.size.height - container.insets.bottom) - bottomOffset)
                } else {
                    bottomRect.rect = CGRect(x: bottomOffset, y: endLine.top, width: ((container.path != nil) ? endLine.right : container.size.width - container.insets.right) - bottomOffset, height: endLine.height)
                }
                bottomRect.writingDirection = .rightToLeft
            } else {
                if isVertical {
                    let top: CGFloat = (container.path != nil) ? endLine.top : container.insets.top
                    bottomRect.rect = CGRect(x: endLine.left, y: top, width: endLine.width, height: bottomOffset - top)
                } else {
                    let `left`: CGFloat = (container.path != nil) ? endLine.left : container.insets.left
                    bottomRect.rect = CGRect(x: `left`, y: endLine.top, width: bottomOffset - `left`, height: endLine.height)
                }
            }
            rects.append(bottomRect)
            
            if endLineIndex - startLineIndex >= 2 {
                var r = CGRect.zero
                var startLineDetected = false
                for l in startLineIndex + 1..<endLineIndex {
                    let line = lines[l]
                    if line.row == startLine.row || line.row == endLine.row {
                        continue
                    }
                    if !startLineDetected {
                        r = line.bounds
                        startLineDetected = true
                    } else {
                        r = r.union(line.bounds)
                    }
                }
                if startLineDetected {
                    if isVertical {
                        if container.path == nil {
                            r.origin.y = container.insets.top
                            r.size.height = container.size.height - container.insets.bottom - container.insets.top
                        }
                        r.size.width = topRect.rect.minX - bottomRect.rect.maxX
                        r.origin.x = bottomRect.rect.maxX
                    } else {
                        if container.path == nil {
                            r.origin.x = container.insets.left
                            r.size.width = container.size.width - container.insets.right - container.insets.left
                        }
                        r.origin.y = topRect.rect.maxY
                        r.size.height = bottomRect.rect.origin.y - r.origin.y
                    }
                    let rect = TextSelectionRect()
                    rect.rect = r
                    rect.isVertical = isVertical
                    rects.append(rect)
                }
            } else {
                if isVertical {
                    var r0: CGRect = bottomRect.rect
                    var r1: CGRect = topRect.rect
                    let mid: CGFloat = (r0.maxX + r1.minX) * 0.5
                    r0.size.width = mid - r0.origin.x
                    let r1ofs: CGFloat = r1.origin.x - mid
                    r1.origin.x -= r1ofs
                    r1.size.width += r1ofs
                    topRect.rect = r1
                    bottomRect.rect = r0
                } else {
                    var r0: CGRect = topRect.rect
                    var r1: CGRect = bottomRect.rect
                    let mid: CGFloat = (r0.maxY + r1.minY) * 0.5
                    r0.size.height = mid - r0.origin.y
                    let r1ofs: CGFloat = r1.origin.y - mid
                    r1.origin.y -= r1ofs
                    r1.size.height += r1ofs
                    topRect.rect = r0
                    bottomRect.rect = r1
                }
            }
        }
        
        return rects
    }
    
    /**
     Returns an array of selection rects corresponding to the range of text.
     
     @param range An object representing a range in text.
     @return An array of `TextSelectionRect` objects that encompass the selection.
     If not found, the array is empty.
     */
    @objc(selectionRectsWithoutStartAndEndForRange:)
    public func selectionRectsWithoutStartAndEnd(for range: TextRange) -> [TextSelectionRect] {
        
        var rects = selectionRects(for: range)
        var i = 0, max = rects.count
        while i < max {
            let rect = rects[i]
            if rect.containsStart || rect.containsEnd {
                rects.remove(at: i)
                i -= 1
                max -= 1
            }
            i += 1
        }
        return rects
    }
    
    /**
     Returns the start and end selection rects corresponding to the range of text.
     The start and end rect can be used to show grabber.
     
     @param range An object representing a range in text.
     @return An array of `TextSelectionRect` objects contains the start and end to
     the selection. If not found, the array is empty.
     */
    @objc(selectionRectsWithOnlyStartAndEndForRange:)
    public func selectionRectsWithOnlyStartAndEnd(for range: TextRange) -> [TextSelectionRect] {
        
        var rects = selectionRects(for: range)
        var i = 0, max = rects.count
        while i < max {
            let rect = rects[i]
            if rect.containsStart && rect.containsEnd {
                rects.remove(at: i)
                i -= 1
                max -= 1
            }
            i += 1
        }
        return rects
    }
    
    // MARK: - Draw text layout
    ///=============================================================================
    /// @name Draw text layout
    ///=============================================================================
    
    /**
     Draw the layout and show the attachments.
     
     @discussion If the `view` parameter is not nil, then the attachment views will
     add to this `view`, and if the `layer` parameter is not nil, then the attachment
     layers will add to this `layer`.
     
     @warning This method should be called on main thread if `view` or `layer` parameter
     is not nil and there's UIView or CALayer attachments in layout.
     Otherwise, it can be called on any thread.
     
     @param context The draw context. Pass nil to avoid text and image drawing.
     @param size    The context size.
     @param point   The point at which to draw the layout.
     @param view    The attachment views will add to this view.
     @param layer   The attachment layers will add to this layer.
     @param debug   The debug option. Pass nil to avoid debug drawing.
     @param cancel  The cancel checker block. It will be called in drawing progress.
     If it returns YES, the further draw progress will be canceled.
     Pass nil to ignore this feature.
     */
    @objc(drawInContext:size:point:view:layer:debug:cancel:)
    public func draw(in context: CGContext?, size: CGSize, point: CGPoint, view: UIView?, layer: CALayer?, debug: TextDebugOption?, cancel: (() -> Bool)? = nil) {
        
        if needDrawBlockBorder, let c = context {
            if let _cancel = cancel, _cancel() { return }
            TextDrawBlockBorder(self, context: c, size: size, point: point, cancel: cancel)
        }
        
        if needDrawBackgroundBorder, let c = context {
            if let _cancel = cancel, _cancel() { return }
            TextDrawBorder(self, context: c, size: size, point: point, type: TextBorderType.backgound, cancel: cancel)
        }
        
        if needDrawShadow, let c = context {
            if let _cancel = cancel, _cancel() { return }
            TextDrawShadow(self, context: c, size: size, point: point, cancel: cancel)
        }
        
        if needDrawUnderline, let c = context {
            if let _cancel = cancel, _cancel() { return }
            TextDrawDecoration(self, context: c, size: size, point: point, type: TextDecorationType.underline, cancel: cancel)
        }
        
        if needDrawText, let c = context {
            if let _cancel = cancel, _cancel() { return }
            TextDrawText(self, context: c, size: size, point: point, cancel: cancel)
        }
        
        if needDrawAttachment && (context != nil || view != nil || layer != nil) {
            if let _cancel = cancel, _cancel() { return }
            TextDrawAttachment(self, context: context, size: size, point: point, targetView: view, targetLayer: layer, cancel: cancel)
        }
        
        if needDrawInnerShadow, let c = context {
            if let _cancel = cancel, _cancel() { return }
            TextDrawInnerShadow(self, context: c, size: size, point: point, cancel: cancel)
        }
        
        if needDrawStrikethrough, let c = context {
            if let _cancel = cancel, _cancel() { return }
            TextDrawDecoration(self, context: c, size: size, point: point, type: TextDecorationType.strikethrough, cancel: cancel)
        }
        
        if needDrawBorder, let c = context {
            if let _cancel = cancel, _cancel() { return }
            TextDrawBorder(self, context: c, size: size, point: point, type: TextBorderType.normal, cancel: cancel)
        }
        
        if let d = debug?.needDrawDebug, d, let c = context {
            if let _cancel = cancel, _cancel() { return }
            TextDrawDebug(self, context: c, size: size, point: point, op: debug)
        }
    }
    
    /**
     Draw the layout text and image (without view or layer attachments).
     
     @discussion This method is thread safe and can be called on any thread.
     
     @param context The draw context. Pass nil to avoid text and image drawing.
     @param size    The context size.
     @param debug   The debug option. Pass nil to avoid debug drawing.
     */
    @objc(drawInContext:size:debug:)
    public func draw(in context: CGContext?, size: CGSize, debug: TextDebugOption?) {
        self.draw(in: context, size: size, point: CGPoint.zero, view: nil, layer: nil, debug: debug, cancel: nil)
    }
    
    /**
     Show view and layer attachments.
     
     @warning This method must be called on main thread.
     
     @param view  The attachment views will add to this view.
     @param layer The attachment layers will add to this layer.
     */
    @objc(addAttachmentToView:layer:)
    public func addAttachment(to view: UIView?, layer: CALayer?) {
        assert(Thread.isMainThread, "This method must be called on the main thread")
        self.draw(in: nil, size: CGSize.zero, point: CGPoint.zero, view: view, layer: layer, debug: nil, cancel: nil)
    }
    
    /**
     Remove attachment views and layers from their super container.
     
     @warning This method must be called on main thread.
     */
    @objc(removeAttachmentFromViewAndLayer)
    public func removeAttachmentFromViewAndLayer() {
        assert(Thread.isMainThread, "This method must be called on the main thread")
        guard let att = attachments else {
            return
        }
        for a in att {
            if (a.content is UIView) {
                let v = a.content! as! UIView
                v.removeFromSuperview()
            } else if (a.content is CALayer) {
                let l = a.content! as! CALayer
                l.removeFromSuperlayer()
            }
        }
    }
}

fileprivate struct TextDecorationType : OptionSet {
    let rawValue: Int
    static let underline = TextDecorationType(rawValue: 1 << 0)
    static let strikethrough = TextDecorationType(rawValue: 1 << 1)
}

fileprivate struct TextBorderType : OptionSet {
    let rawValue: Int
    static let backgound = TextBorderType(rawValue: 1 << 0)
    static let normal = TextBorderType(rawValue: 1 << 1)
}

private func TextMergeRectInSameLine(rect1: CGRect, rect2: CGRect, isVertical: Bool) -> CGRect {
    if isVertical {
        let top = min(rect1.origin.y, rect2.origin.y)
        let bottom = max(rect1.origin.y + rect1.size.height, rect2.origin.y + rect2.size.height)
        let width = max(rect1.size.width, rect2.size.width)
        return CGRect(x: rect1.origin.x, y: top, width: width, height: bottom - top)
    } else {
        let `left` = min(rect1.origin.x, rect2.origin.x)
        let `right` = max(rect1.origin.x + rect1.size.width, rect2.origin.x + rect2.size.width)
        let height = max(rect1.size.height, rect2.size.height)
        return CGRect(x: `left`, y: rect1.origin.y, width: `right` - `left`, height: height)
    }
}

private func TextGetRunsMaxMetric(runs: CFArray, xHeight: UnsafeMutablePointer<CGFloat>, underlinePosition: UnsafeMutablePointer<CGFloat>?, lineThickness: UnsafeMutablePointer<CGFloat>) {
    let xHeight = xHeight
    let underlinePosition = underlinePosition
    let lineThickness = lineThickness
    var maxXHeight: CGFloat = 0
    var maxUnderlinePos: CGFloat = 0
    var maxLineThickness: CGFloat = 0
    let max = CFArrayGetCount(runs)
    for i in 0..<max {
        let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, i), to: CTRun.self)
        
        if let attrs = CTRunGetAttributes(run) as? [String: AnyObject] {
            if let font = attrs[kCTFontAttributeName as String] as! CTFont? {
                
                let xHeight = CTFontGetXHeight(font)
                if xHeight > maxXHeight {
                    maxXHeight = xHeight
                }
                let underlinePos = CTFontGetUnderlinePosition(font)
                if underlinePos < maxUnderlinePos {
                    maxUnderlinePos = underlinePos
                }
                let lineThickness = CTFontGetUnderlineThickness(font)
                if lineThickness > maxLineThickness {
                    maxLineThickness = lineThickness
                }
            }
        }
    }
    if xHeight.pointee != 0 {
        xHeight.pointee = maxXHeight
    }
    if underlinePosition != nil {
        underlinePosition!.pointee = maxUnderlinePos
    }
    if lineThickness.pointee != 0 {
        lineThickness.pointee = maxLineThickness
    }
}

private func TextDrawRun(line: TextLine, run: CTRun, context: CGContext, size: CGSize, isVertical: Bool, runRanges: [TextRunGlyphRange]?, verticalOffset: CGFloat) {
    
    let runTextMatrix: CGAffineTransform = CTRunGetTextMatrix(run)
    let runTextMatrixIsID = runTextMatrix.isIdentity
    let runAttrs = CTRunGetAttributes(run) as! [String: AnyObject]
    
    let glyphTransformValue = runAttrs[TextAttribute.textGlyphTransformAttributeName] as? NSValue
    
    if !isVertical && glyphTransformValue == nil {
        // draw run
        if !runTextMatrixIsID {
            context.saveGState()
            let trans: CGAffineTransform = context.textMatrix
            context.textMatrix = trans.concatenating(runTextMatrix)
        }
        CTRunDraw(run, context, CFRangeMake(0, 0))
        if !runTextMatrixIsID {
            context.restoreGState()
        }
    } else {
        
        guard let runFont = runAttrs[kCTFontAttributeName as String] as! CTFont? else {
            return
        }
        
        let glyphCount: Int = CTRunGetGlyphCount(run)
        if glyphCount <= 0 {
            return
        }
        let glyphs = UnsafeMutablePointer<CGGlyph>.allocate(capacity: glyphCount)
        let glyphPositions = UnsafeMutablePointer<CGPoint>.allocate(capacity: glyphCount)
        CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs)
        CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions)
        
        let fillColor = (runAttrs[kCTForegroundColorAttributeName as String] as! CGColor?) ?? UIColor.black.cgColor
        let strokeWidth = runAttrs[kCTStrokeWidthAttributeName as String] as? Int ?? 0
        
        context.saveGState()
        do {
            context.setFillColor(fillColor)
            if strokeWidth == 0 {
                context.setTextDrawingMode(.fill)
            } else {
                
                var strokeColor = runAttrs[kCTStrokeColorAttributeName as String] as! CGColor?
                if strokeColor == nil {
                    strokeColor = fillColor
                }
                if let aColor = strokeColor {
                    context.setStrokeColor(aColor)
                }
                context.setLineWidth(CTFontGetSize(runFont) * CGFloat(abs(Float(strokeWidth) * 0.01)))
                if strokeWidth > 0 {
                    context.setTextDrawingMode(.stroke)
                } else {
                    context.setTextDrawingMode(.fillStroke)
                }
            }
            
            if isVertical {
                let runStrIdx = UnsafeMutablePointer<CFIndex>.allocate(capacity: glyphCount + 1)
                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx)
                let runStrRange: CFRange = CTRunGetStringRange(run)
                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length
                let glyphAdvances = UnsafeMutablePointer<CGSize>.allocate(capacity: glyphCount)
                CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances)
                let ascent: CGFloat = CTFontGetAscent(runFont)
                let descent: CGFloat = CTFontGetDescent(runFont)
                let glyphTransform = glyphTransformValue?.cgAffineTransformValue
                let zeroPoint = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
                zeroPoint.pointee = CGPoint.zero
                
                for oneRange in runRanges ?? [] {
                    let range = oneRange.glyphRangeInRun
                    let rangeMax = range.location + range.length
                    let mode: TextRunGlyphDrawMode = oneRange.drawMode
                    
                    for g in range.location..<rangeMax {
                    
                        context.saveGState()
                        do {
                            context.textMatrix = .identity
                            if glyphTransformValue != nil {
                                context.textMatrix = glyphTransform!
                            }
                            if mode != .horizontal {
                                // CJK glyph, need rotated
                                let ofs = (ascent - descent) * 0.5
                                let w = glyphAdvances[g].width * 0.5
                                var x = line.position.x + verticalOffset + (glyphPositions + g).pointee.y + (ofs - w)
                                var y = -line.position.y + size.height - glyphPositions[g].x - (ofs + w)
                                if mode == TextRunGlyphDrawMode.verticalRotateMove {
                                    x += w
                                    y += w
                                }
                                context.textPosition = CGPoint(x: x, y: y)
                            } else {
                                context.rotate(by: TextUtilities.textRadians(from: (-90)))
                                context.textPosition = CGPoint(x: line.position.y - size.height + glyphPositions[g].x, y: line.position.x + verticalOffset + glyphPositions[g].y)
                            }
                            if TextUtilities.textCTFontContainsColorBitmapGlyphs((runFont)) {
                                CTFontDrawGlyphs(runFont, glyphs + g, zeroPoint, 1, context)
                            } else {
                                let cgFont = CTFontCopyGraphicsFont(runFont, nil)
                                context.setFont(cgFont)
                                context.setFontSize(CTFontGetSize(runFont))
                                context.showGlyphs(Array(UnsafeBufferPointer(start: glyphs + g, count: 1)), at: Array(UnsafeBufferPointer(start: zeroPoint, count: 1)))
                            }
                        }
                        context.restoreGState()
                    }
                }
                
                runStrIdx.deallocate()
                glyphAdvances.deallocate()
                zeroPoint.deallocate()
                
            } else {
                if glyphTransformValue != nil {
                    let runStrIdx = UnsafeMutablePointer<CFIndex>.allocate(capacity: glyphCount + 1)
                    CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx)
                    let runStrRange: CFRange = CTRunGetStringRange(run)
                    (runStrIdx + glyphCount).pointee = runStrRange.location + runStrRange.length
                    let glyphAdvances = UnsafeMutablePointer<CGSize>.allocate(capacity: glyphCount)
                    CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances)
                    let glyphTransform: CGAffineTransform = glyphTransformValue!.cgAffineTransformValue
                    let zeroPoint = UnsafeMutablePointer<CGPoint>.allocate(capacity: 1)
                    zeroPoint.pointee = CGPoint.zero
                
                    for g in 0..<glyphCount {
                        context.saveGState()
                        do {
                            context.textMatrix = .identity
                            context.textMatrix = glyphTransform
                            context.textPosition = CGPoint(x: line.position.x + glyphPositions[g].x, y: size.height - (line.position.y + glyphPositions[g].y))
                            if TextUtilities.textCTFontContainsColorBitmapGlyphs((runFont)) {
                                CTFontDrawGlyphs(runFont, glyphs + g, zeroPoint, 1, context)
                            } else {
                                let cgFont = CTFontCopyGraphicsFont(runFont, nil)
                                context.setFont(cgFont)
                                context.setFontSize(CTFontGetSize(runFont))
                                context.showGlyphs(Array(UnsafeBufferPointer(start: glyphs + g, count: 1)), at: Array(UnsafeBufferPointer(start: zeroPoint, count: 1)))
                            }
                        }
                        context.restoreGState()
                    }
                    
                    runStrIdx.deallocate()
                    glyphAdvances.deallocate()
                    zeroPoint.deallocate()
                    
                } else {
                    
                    if TextUtilities.textCTFontContainsColorBitmapGlyphs((runFont)) {
                        CTFontDrawGlyphs(runFont, glyphs, glyphPositions, glyphCount, context)
                    } else {
                        let cgFont = CTFontCopyGraphicsFont(runFont, nil)
                        context.setFont(cgFont)
                        context.setFontSize(CTFontGetSize(runFont))
                        context.showGlyphs(Array(UnsafeBufferPointer(start: glyphs, count: glyphCount)), at: Array(UnsafeBufferPointer(start: glyphPositions, count: glyphCount)))
                    }
                }
            }
        }
        context.restoreGState()
        
        glyphs.deallocate()
        glyphPositions.deallocate()
    }
}

private func TextSetLinePatternInContext(style: TextLineStyle, width: CGFloat, phase: CGFloat, context: CGContext) {
    
    context.setLineWidth(width)
    context.setLineCap(CGLineCap.butt)
    context.setLineJoin(CGLineJoin.miter)
    let dash: CGFloat = 12
    let dot: CGFloat = 5
    let space: CGFloat = 3
    let pattern = style.rawValue & 0xf00
    if pattern == TextLineStyle.none.rawValue {
        // TextLineStylePatternSolid
        context.setLineDash(phase: phase, lengths: [])
    } else if pattern == TextLineStyle.patternDot.rawValue {
        let lengths = [width * dot, width * space]
        context.setLineDash(phase: phase, lengths: lengths)
    } else if pattern == TextLineStyle.patternDash.rawValue {
        let lengths = [width * dash, width * space]
        context.setLineDash(phase: phase, lengths: lengths)
    } else if pattern == TextLineStyle.patternDashDot.rawValue {
        let lengths = [width * dash, width * space, width * dot, width * space]
        context.setLineDash(phase: phase, lengths: lengths)
    } else if pattern == TextLineStyle.patternDashDotDot.rawValue {
        let lengths = [width * dash, width * space, width * dot, width * space, width * dot, width * space]
        context.setLineDash(phase: phase, lengths: lengths)
    } else if pattern == TextLineStyle.patternCircleDot.rawValue {
        let lengths = [width * 0, width * 3]
        context.setLineDash(phase: phase, lengths: lengths)
        context.setLineCap(CGLineCap.round)
        context.setLineJoin(CGLineJoin.round)
    }
}

private func TextDrawBorderRects(context: CGContext, size: CGSize, border: TextBorder, rects: [NSValue], isVertical: Bool) {
    
    if rects.count == 0 {
        return
    }
    
    if let shadow = border.shadow, let color = shadow.color {
        context.saveGState()
        context.setShadow(offset: shadow.offset, blur: shadow.radius, color: color.cgColor)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
    }
    var paths = [UIBezierPath]()
    for value in rects {
        var rect = value.cgRectValue
        if isVertical {
            rect = rect.inset(by: UIEdgeInsetRotateVertical(insets: border.insets))
        } else {
            rect = rect.inset(by: border.insets)
        }
        rect = TextUtilities.textCGRect(pixelRound: rect)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: border.cornerRadius)
        path.close()
        paths.append(path)
    }
    if let color = border.fillColor {
        context.saveGState()
        context.setFillColor(color.cgColor)
        for path in paths {
            context.addPath(path.cgPath)
        }
        context.fillPath()
        context.restoreGState()
    }
    if border.strokeColor != nil && border.lineStyle.rawValue > 0 && border.strokeWidth > 0 {
        //-------------------------- single line ------------------------------//
        context.saveGState()
        for path in paths {
            
            var bounds: CGRect = path.bounds.union(CGRect(origin: CGPoint.zero, size: size))
            bounds = bounds.insetBy(dx: -2 * border.strokeWidth, dy: -2 * border.strokeWidth)
            context.addRect(bounds)
            context.addPath(path.cgPath)
            context.clip(using: .evenOdd)
        }
        border.strokeColor!.setStroke()
        TextSetLinePatternInContext(style: border.lineStyle, width: border.strokeWidth, phase: 0, context: context)
        var inset: CGFloat = -border.strokeWidth * 0.5
        if (border.lineStyle.rawValue & 0xff) == TextLineStyle.thick.rawValue {
            inset *= 2
            context.setLineWidth(border.strokeWidth * 2)
        }
        var radiusDelta: CGFloat = -inset
        if border.cornerRadius <= 0 {
            radiusDelta = 0
        }
        context.setLineJoin(border.lineJoin)
        for value in rects {
            var rect = value.cgRectValue
            if isVertical {
                rect = rect.inset(by: UIEdgeInsetRotateVertical(insets: border.insets))
            } else {
                rect = rect.inset(by: border.insets)
            }
            rect = rect.insetBy(dx: inset, dy: inset)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: border.cornerRadius + radiusDelta)
            path.close()
            context.addPath(path.cgPath)
        }
        context.strokePath()
        context.restoreGState()
        
        //------------------------- second line ------------------------------//
        if (border.lineStyle.rawValue & 0xff) == TextLineStyle.double.rawValue {
            
            context.saveGState()
            var inset: CGFloat = -border.strokeWidth * 2
            for value in rects {
                var rect = value.cgRectValue
                rect = rect.inset(by: border.insets)
                rect = rect.insetBy(dx: inset, dy: inset)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: border.cornerRadius + 2 * border.strokeWidth)
                path.close()
                
                var bounds: CGRect = path.bounds.union(CGRect(origin: CGPoint.zero, size: size))
                bounds = bounds.insetBy(dx: -2 * border.strokeWidth, dy: -2 * border.strokeWidth)
                context.addRect(bounds)
                context.addPath(path.cgPath)
                context.clip(using: .evenOdd)
            }
            if let aColor = border.strokeColor?.cgColor {
                context.setStrokeColor(aColor)
            }
            TextSetLinePatternInContext(style: border.lineStyle, width: border.strokeWidth, phase: 0, context: context)
            context.setLineJoin(border.lineJoin)
            inset = -border.strokeWidth * 2.5
            radiusDelta = border.strokeWidth * 2
            if border.cornerRadius <= 0 {
                radiusDelta = 0
            }
            for value in rects {
                var rect = value.cgRectValue
                rect = rect.inset(by: border.insets)
                rect = rect.insetBy(dx: inset, dy: inset)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: border.cornerRadius + radiusDelta)
                path.close()
                context.addPath(path.cgPath)
            }
            context.strokePath()
            context.restoreGState()
        }
    }
    
    if let _ = border.shadow?.color {
        context.endTransparencyLayer()
        context.restoreGState()
    }
}

private func TextDrawLineStyle(context: CGContext, length: CGFloat, lineWidth: CGFloat, style: TextLineStyle, position: CGPoint, color: CGColor, isVertical: Bool) {
    
    let styleBase = style.rawValue & 0xff
    if styleBase == 0 {
        return
    }
    context.saveGState()
    do {
        if isVertical {
            var x: CGFloat
            var y1: CGFloat
            var y2: CGFloat
            var w: CGFloat
            y1 = TextUtilities.textCGFloat(pixelRound: position.y)
            y2 = TextUtilities.textCGFloat(pixelRound: (position.y + length))
            w = styleBase == TextLineStyle.thick.rawValue ? lineWidth * 2 : lineWidth
            let linePixel = TextUtilities.textCGFloat(toPixel: w)
            if abs(Float(linePixel - floor(linePixel))) < 0.1 {
                let iPixel = Int(linePixel)
                if iPixel == 0 || (iPixel % 2) != 0 {
                    // odd line pixel
                    x = TextUtilities.textCGFloat(pixelHalf: position.x)
                } else {
                    x = TextUtilities.textCGFloat(pixelFloor: position.x)
                }
            } else {
                x = position.x
            }
            
            context.setStrokeColor(color)
            
            TextSetLinePatternInContext(style: style, width: lineWidth, phase: position.y, context: context)
            context.setLineWidth(w)
            if styleBase == TextLineStyle.single.rawValue {
                context.move(to: CGPoint(x: x, y: y1))
                context.addLine(to: CGPoint(x: x, y: y2))
                context.strokePath()
            } else if styleBase == TextLineStyle.thick.rawValue {
                context.move(to: CGPoint(x: x, y: y1))
                context.addLine(to: CGPoint(x: x, y: y2))
                context.strokePath()
            } else if styleBase == TextLineStyle.double.rawValue {
                context.move(to: CGPoint(x: x - w, y: y1))
                context.addLine(to: CGPoint(x: x - w, y: y2))
                context.strokePath()
                context.move(to: CGPoint(x: x + w, y: y1))
                context.addLine(to: CGPoint(x: x + w, y: y2))
                context.strokePath()
            }
        } else {
            var x1: CGFloat = 0
            var x2: CGFloat = 0
            var y: CGFloat = 0
            var w: CGFloat = 0
            x1 = TextUtilities.textCGFloat(pixelRound: position.x)
            x2 = TextUtilities.textCGFloat(pixelRound: position.x + length)
            w = styleBase == TextLineStyle.thick.rawValue ? lineWidth * 2 : lineWidth
            let linePixel = TextUtilities.textCGFloat(toPixel: w)
            if abs(Float(linePixel - floor(linePixel))) < 0.1 {
                let iPixel = Int(linePixel)
                if iPixel == 0 || (iPixel % 2) != 0 {
                    // odd line pixel
                    y = TextUtilities.textCGFloat(pixelHalf: position.y)
                } else {
                    y = TextUtilities.textCGFloat(pixelFloor: position.y)
                }
            } else {
                y = position.y
            }
            context.setStrokeColor(color)
            TextSetLinePatternInContext(style: style, width: lineWidth, phase: position.x, context: context)
            context.setLineWidth(w)
            if styleBase == TextLineStyle.single.rawValue {
                context.move(to: CGPoint(x: x1, y: y))
                context.addLine(to: CGPoint(x: x2, y: y))
                context.strokePath()
            } else if styleBase == TextLineStyle.thick.rawValue {
                context.move(to: CGPoint(x: x1, y: y))
                context.addLine(to: CGPoint(x: x2, y: y))
                context.strokePath()
            } else if styleBase == TextLineStyle.double.rawValue {
                context.move(to: CGPoint(x: x1, y: y - w))
                context.addLine(to: CGPoint(x: x2, y: y - w))
                context.strokePath()
                context.move(to: CGPoint(x: x1, y: y + w))
                context.addLine(to: CGPoint(x: x2, y: y + w))
                context.strokePath()
            }
        }
    }
    
    context.restoreGState()
}

private func TextDrawText(_ layout: TextLayout, context: CGContext, size: CGSize, point: CGPoint, cancel: (() -> Bool)? = nil) {
    context.saveGState()
    do {
        context.translateBy(x: point.x, y: point.y)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        let isVertical = layout.container.isVerticalForm
        let verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0
        let lines = layout.lines
        
        for l in lines {
            var line = l
            if let tmpL = layout.truncatedLine, tmpL.index == line.index {
                line = tmpL
            }
            let lineRunRanges = line.verticalRotateRange
            let posX: CGFloat = line.position.x
            let posY: CGFloat = size.height - line.position.y
            let runs = CTLineGetGlyphRuns(line.ctLine!)
            let rMax = CFArrayGetCount(runs)
            for r in 0..<rMax {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
                context.textMatrix = .identity
                context.textPosition = CGPoint(x: posX, y: posY)
                TextDrawRun(line: line, run: run, context: context, size: size, isVertical: isVertical, runRanges: lineRunRanges?[r], verticalOffset: verticalOffset)
            }
            if let _cancel = cancel, _cancel() {
                break
            }
        }
        // Use this to draw frame for test/debug.
        // CGContextTranslateCTM(context, verticalOffset, size.height);
        // CTFrameDraw(layout.frame, context);
    }
    context.restoreGState()
}

private func TextDrawBlockBorder(_ layout: TextLayout, context: CGContext, size: CGSize, point: CGPoint, cancel: (() -> Bool)? = nil) {
    
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    let isVertical = layout.container.isVerticalForm
    let verticalOffset: CGFloat = isVertical ? (size.width - layout.container.size.width) : 0
    let lines = layout.lines
    
    var l = 0, lMax = lines.count
    while l < lMax {
        if let _cancel = cancel, _cancel() {
            break
        }
        var line = lines[l]
        if let tmpL = layout.truncatedLine, tmpL.index == line.index {
            line = tmpL
        }
        let runs = CTLineGetGlyphRuns(line.ctLine!)
        let rMax = CFArrayGetCount(runs)
        for r in 0..<rMax {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
            let glyphCount = CTRunGetGlyphCount(run)
            if glyphCount == 0 {
                continue
            }
            let attrs = CTRunGetAttributes(run) as? [AnyHashable : Any]
            
            guard let border = attrs?[TextAttribute.textBlockBorderAttributeName] as? TextBorder else {
                continue
            }
            var lineStartIndex = line.index
            while lineStartIndex > 0 {
                if (lines[lineStartIndex - 1]).row == line.row {
                    lineStartIndex = (lineStartIndex - 1)
                } else {
                    break
                }
            }
            var unionRect = CGRect.zero
            let lineStartRow = (lines[lineStartIndex]).row
            var lineContinueIndex = lineStartIndex
            var lineContinueRow = lineStartRow
            
            repeat {
                let one = lines[lineContinueIndex]
                if lineContinueIndex == lineStartIndex {
                    unionRect = one.bounds
                } else {
                    unionRect = unionRect.union(one.bounds)
                }
                if lineContinueIndex + 1 == lMax {
                    break
                }
                let next = lines[lineContinueIndex + 1]
                if next.row != lineContinueRow {
                    let nextBorder = layout.text?.bs_attribute(NSAttributedString.Key(rawValue: TextAttribute.textBlockBorderAttributeName), at: next.range.location) as? TextBorder
                    if nextBorder == border {
                        lineContinueRow += 1
                    } else {
                        break
                    }
                }
                lineContinueIndex += 1
            } while true
            
            if isVertical {
                let insets: UIEdgeInsets = layout.container.insets
                unionRect.origin.y = insets.top
                unionRect.size.height = layout.container.size.height - insets.top - insets.bottom
            } else {
                let insets: UIEdgeInsets = layout.container.insets
                unionRect.origin.x = insets.left
                unionRect.size.width = layout.container.size.width - insets.left - insets.right
            }
            unionRect.origin.x += verticalOffset
            TextDrawBorderRects(context: context, size: size, border: border, rects: [NSValue(cgRect: unionRect)], isVertical: isVertical)
            l = lineContinueIndex
            break
        }
        l += 1
    }
    context.restoreGState()
}

private func TextDrawBorder(_ layout: TextLayout, context: CGContext, size: CGSize, point: CGPoint, type: TextBorderType, cancel: (() -> Bool)? = nil) {
    
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    let isVertical = layout.container.isVerticalForm
    let verticalOffset: CGFloat = isVertical ? (size.width - layout.container.size.width) : 0
    let lines = layout.lines
    let borderKey = (type == TextBorderType.normal ? TextAttribute.textBorderAttributeName : TextAttribute.textBackgroundBorderAttributeName)
    var needJumpRun = false
    var jumpRunIndex: Int = 0
    
    var l = 0, lMax = lines.count
    while l < lMax {
        if let _cancel = cancel, _cancel() {
            break
        }
        var line = lines[l]
        if let tmpL = layout.truncatedLine, tmpL.index == line.index {
            line = tmpL
        }
        let runs = CTLineGetGlyphRuns(line.ctLine!)
        var r = 0, rMax = CFArrayGetCount(runs)
        while r < rMax {
            
            if needJumpRun {
                needJumpRun = false
                r = jumpRunIndex + 1
                if r >= rMax {
                    break
                }
            }
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
            let glyphCount = CTRunGetGlyphCount(run)
            if glyphCount == 0 {
                r += 1
                continue
            }
            let attrs = CTRunGetAttributes(run) as? [AnyHashable : AnyObject]
            
            guard let border = attrs?[borderKey] as? TextBorder else {
                r += 1
                continue
            }
            let runRange: CFRange = CTRunGetStringRange(run)
            if runRange.location == kCFNotFound || runRange.length == 0 {
                r += 1
                continue
            }
            if runRange.location + runRange.length > layout.text?.length ?? 0 {
                r += 1
                continue
            }
            var runRects = [NSValue]()
            var endLineIndex = l
            var endRunIndex: Int = r
            var endFound = false
            for ll in l..<lMax {
                if endFound {
                    break
                }
                let iLine = lines[ll]
                let iRuns = CTLineGetGlyphRuns(iLine.ctLine!)
                var extLineRect = CGRect.null
                
                let rr_ = (ll == l) ? r : 0, rrMax = CFArrayGetCount(iRuns)
                for rr in rr_..<rrMax {
                    let iRun = unsafeBitCast(CFArrayGetValueAtIndex(iRuns, rr), to: CTRun.self)
                    let iAttrs = CTRunGetAttributes(iRun) as? [AnyHashable : Any]
                    let iBorder = iAttrs?[borderKey] as? TextBorder
                    if !(border == iBorder) {
                        endFound = true
                        break
                    }
                    endLineIndex = ll
                    endRunIndex = rr
                    var iRunPosition = CGPoint.zero
                    CTRunGetPositions(iRun, CFRangeMake(0, 1), &iRunPosition)
                    var ascent: CGFloat = 0
                    var descent: CGFloat = 0
                    let iRunWidth: CGFloat = CGFloat(CTRunGetTypographicBounds(iRun, CFRangeMake(0, 0), &ascent, &descent, nil))
                    if isVertical {
                        TextUtilities.numberSwap(&iRunPosition.x, b: &iRunPosition.y)
                        iRunPosition.y += iLine.position.y
                        let iRect = CGRect(x: verticalOffset + line.position.x - descent, y: iRunPosition.y, width: ascent + descent, height: iRunWidth)
                        if extLineRect.isNull {
                            extLineRect = iRect
                        } else {
                            extLineRect = extLineRect.union(iRect)
                        }
                    } else {
                        iRunPosition.x += iLine.position.x
                        let iRect = CGRect(x: iRunPosition.x, y: iLine.position.y - ascent, width: iRunWidth, height: ascent + descent)
                        if extLineRect.isNull {
                            extLineRect = iRect
                        } else {
                            extLineRect = extLineRect.union(iRect)
                        }
                    }
                }
                if !extLineRect.isNull {
                    runRects.append(NSValue(cgRect: extLineRect))
                }
            }
            var drawRects = [NSValue]()
            var curRect = runRects.first!.cgRectValue
            let reMax = runRects.count
            for re in 0..<reMax {
                let rect = runRects[re].cgRectValue
                if isVertical {
                    if abs(Float((rect.origin.x) - (curRect.origin.x))) < 1 {
                        curRect = TextMergeRectInSameLine(rect1: rect, rect2: curRect, isVertical: isVertical)
                    } else {
                        drawRects.append(NSValue(cgRect: curRect))
                        curRect = rect
                    }
                } else {
                    if abs(Float((rect.origin.y) - (curRect.origin.y))) < 1 {
                        curRect = TextMergeRectInSameLine(rect1: rect, rect2: curRect, isVertical: isVertical)
                    } else {
                        drawRects.append(NSValue(cgRect: curRect))
                        curRect = rect
                    }
                }
            }
            if !curRect.equalTo(CGRect.zero) {
                drawRects.append(NSValue(cgRect: curRect))
            }
            TextDrawBorderRects(context: context, size: size, border: border, rects: drawRects, isVertical: isVertical)
            if l == endLineIndex {
                r = endRunIndex
            } else {
                l = endLineIndex - 1
                needJumpRun = true
                jumpRunIndex = endRunIndex
                break
            }
            r += 1
        }
        l += 1
    }
    context.restoreGState()
}

private func TextDrawDecoration(_ layout: TextLayout, context: CGContext, size: CGSize, point: CGPoint, type: TextDecorationType, cancel: (() -> Bool)? = nil) {
    
    let lines = layout.lines
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    let isVertical = layout.container.isVerticalForm
    let verticalOffset: CGFloat = isVertical ? (size.width - layout.container.size.width) : 0
    context.translateBy(x: verticalOffset, y: 0)
    
    let lMax = layout.lines.count
    for l in 0..<lMax {
        if let _cancel = cancel, _cancel() {
            break
        }
        var line = lines[l]
        if let tmpL = layout.truncatedLine, tmpL.index == line.index {
            line = tmpL
        }
        let runs = CTLineGetGlyphRuns(line.ctLine!)
        let rMax = CFArrayGetCount(runs)
        for r in 0..<rMax {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
            let glyphCount = CTRunGetGlyphCount(run)
            if glyphCount == 0 {
                continue
            }
            let attrs = CTRunGetAttributes(run) as? [AnyHashable : Any]
            let underline = attrs?[TextAttribute.textUnderlineAttributeName] as? TextDecoration
            let strikethrough = attrs?[TextAttribute.textStrikethroughAttributeName] as? TextDecoration
            var needDrawUnderline = false
            var needDrawStrikethrough = false
            if (type.rawValue & TextDecorationType.underline.rawValue) != 0 && underline?.style.rawValue ?? 0 > 0 {
                needDrawUnderline = true
            }
            if (type.rawValue & TextDecorationType.strikethrough.rawValue) != 0 && strikethrough?.style.rawValue ?? 0 > 0 {
                needDrawStrikethrough = true
            }
            if !needDrawUnderline && !needDrawStrikethrough {
                continue
            }
            let runRange: CFRange = CTRunGetStringRange(run)
            if runRange.location == kCFNotFound || runRange.length == 0 { continue }
            if runRange.location + runRange.length > layout.text!.length {
                continue
            }
            let runStr = layout.text!.attributedSubstring(from: NSRange(location: runRange.location, length: runRange.length)).string
            if TextUtilities.textIsLinebreakString((runStr)) {
                continue // may need more checks...
            }
            var xHeight: CGFloat = 0
            var underlinePosition: CGFloat = 0
            var lineThickness: CGFloat = 0
            TextGetRunsMaxMetric(runs: runs, xHeight: &xHeight, underlinePosition: &underlinePosition, lineThickness: &lineThickness)
            var underlineStart = CGPoint.zero
            var strikethroughStart = CGPoint.zero
            var length: CGFloat = 0
            if isVertical {
                underlineStart.x = line.position.x + underlinePosition
                strikethroughStart.x = line.position.x + xHeight / 2
                var runPosition = CGPoint.zero
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition)
                strikethroughStart.y = runPosition.x + line.position.y
                underlineStart.y = strikethroughStart.y
                length = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), nil, nil, nil))
            } else {
                underlineStart.y = line.position.y - underlinePosition
                strikethroughStart.y = line.position.y - xHeight / 2
                var runPosition = CGPoint.zero
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition)
                strikethroughStart.x = runPosition.x + line.position.x
                underlineStart.x = strikethroughStart.x
                length = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), nil, nil, nil))
            }
            
            if needDrawUnderline {
                
                var color = underline?.color?.cgColor
                if color == nil {
                    if let aName = attrs?[kCTForegroundColorAttributeName] as! CGColor? {
                        color = aName
                    }
                }
                
                let thickness = (underline?.width != nil) ? CGFloat(underline!.width!.floatValue) : lineThickness
                var shadow = underline?.shadow
                while shadow != nil {
                    if shadow!.color == nil {
                        shadow = shadow?.subShadow
                        continue
                    }
                    let offsetAlterX: CGFloat = size.width + 0xffff
                    context.saveGState()
                    do {
                        var offset = shadow!.offset
                        offset.width -= offsetAlterX
                        context.saveGState()
                        do {
                            context.setShadow(offset: offset, blur: shadow!.radius, color: shadow!.color!.cgColor)
                            context.setBlendMode(shadow!.blendMode)
                            context.translateBy(x: offsetAlterX, y: 0)
                            TextDrawLineStyle(context: context, length: length, lineWidth: thickness, style: underline!.style, position: underlineStart, color: color!, isVertical: isVertical)
                        }
                        context.restoreGState()
                    }
                    context.restoreGState()
                    shadow = shadow?.subShadow
                }
                TextDrawLineStyle(context: context, length: length, lineWidth: thickness, style: underline!.style, position: underlineStart, color: color!, isVertical: isVertical)
            }
            
            if needDrawStrikethrough {
                var color = strikethrough?.color?.cgColor
                
                if color == nil {
                    if let aName = (attrs?[kCTForegroundColorAttributeName]) as! CGColor? {
                        color = aName
                    }
                }
                
                let thickness = (strikethrough?.width != nil) ? CGFloat((strikethrough!.width?.floatValue)!) : lineThickness
                var shadow = underline?.shadow
                while shadow != nil {
                    if shadow?.color == nil {
                        shadow = shadow?.subShadow
                        continue
                    }
                    let offsetAlterX: CGFloat = size.width + 0xffff
                    context.saveGState()
                    do {
                        var offset: CGSize? = shadow?.offset
                        offset?.width -= offsetAlterX
                        context.saveGState()
                        do {
                            context.setShadow(offset: offset!, blur: (shadow?.radius)!, color: shadow?.color?.cgColor)
                            context.setBlendMode((shadow?.blendMode)!)
                            context.translateBy(x: offsetAlterX, y: 0)
                            TextDrawLineStyle(context: context, length: length, lineWidth: thickness, style: underline!.style, position: underlineStart, color: color!, isVertical: isVertical)
                        }
                        context.restoreGState()
                    }
                    context.restoreGState()
                    shadow = shadow?.subShadow
                }
                TextDrawLineStyle(context: context, length: length, lineWidth: thickness, style: strikethrough!.style, position: strikethroughStart, color: color!, isVertical: isVertical)
            }
        }
    }
    context.restoreGState()
}

private func TextDrawAttachment(_ layout: TextLayout, context: CGContext?, size: CGSize, point: CGPoint, targetView: UIView?, targetLayer: CALayer?, cancel: (() -> Bool)? = nil) {
    
    let isVertical = layout.container.isVerticalForm
    let verticalOffset: CGFloat = isVertical ? (size.width - layout.container.size.width) : 0
    let max = layout.attachments?.count ?? 0
    for i in 0..<max {
        let a = layout.attachments![i]
        if a.content == nil {
            continue
        }
        var image: UIImage? = nil
        var view: UIView? = nil
        var layer: CALayer? = nil
        if (a.content is UIImage) {
            image = a.content as? UIImage
        } else if (a.content is UIView) {
            view = a.content as? UIView
        } else if (a.content is CALayer) {
            layer = a.content as? CALayer
        }
        if image == nil && view == nil && layer == nil {
            continue
        }
        if image != nil && context == nil {
            continue
        }
        if view != nil && targetView == nil {
            continue
        }
        if layer != nil && targetLayer == nil {
            continue
        }
        if let _cancel = cancel, _cancel() {
            break
        }
        let asize = image != nil ? image!.size : view != nil ? view!.frame.size : layer!.frame.size
        var rect = (layout.attachmentRects?[i])?.cgRectValue
        if isVertical {
            rect = rect?.inset(by: UIEdgeInsetRotateVertical(insets: a.contentInsets))
        } else {
            rect = rect?.inset(by: a.contentInsets)
        }
        rect = TextUtilities.textCGRectFit(with: a.contentMode, rect: rect!, size: asize)
        rect = TextUtilities.textCGRect(pixelRound: rect!)
        rect = rect?.standardized
        rect?.origin.x += point.x + verticalOffset
        rect?.origin.y += point.y
        if image != nil {
            if let ref = image!.cgImage {
                context?.saveGState()
                context?.translateBy(x: 0, y: rect!.maxY + rect!.minY)
                context?.scaleBy(x: 1, y: -1)
                context?.draw(ref, in: rect!)
                context?.restoreGState()
            }
        } else if view != nil {
            view!.frame = rect!
            targetView?.addSubview(view!)
        } else if layer != nil {
            layer!.frame = rect!
            targetLayer?.addSublayer(layer!)
        }
    }
}

private func TextDrawShadow(_ layout: TextLayout, context: CGContext, size: CGSize, point: CGPoint, cancel: (() -> Bool)? = nil) {
    
    // move out of context. (0xFFFF is just a random large number)
    let offsetAlterX: CGFloat = size.width + 0xffff
    let isVertical = layout.container.isVerticalForm
    let verticalOffset: CGFloat = isVertical ? (size.width - layout.container.size.width) : 0
    context.saveGState()
    do {
        context.translateBy(x: point.x, y: point.y)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        let lines = layout.lines
        let lMax = layout.lines.count
        for l in 0..<lMax {
            if let _cancel = cancel, _cancel() {
                break
            }
            var line = lines[l]
            if let tmp = layout.truncatedLine, tmp.index == line.index {
                line = tmp
            }
            let lineRunRanges = line.verticalRotateRange
            let linePosX = line.position.x
            let linePosY: CGFloat = size.height - line.position.y
            let runs = CTLineGetGlyphRuns(line.ctLine!)
            let rMax = CFArrayGetCount(runs)
            for r in 0..<rMax {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
                context.textMatrix = .identity
                context.textPosition = CGPoint(x: linePosX, y: linePosY)
                let attrs = CTRunGetAttributes(run) as? [AnyHashable : Any]
                var shadow = attrs?[TextAttribute.textShadowAttributeName] as? TextShadow
                let nsShadow = TextShadow.shadow(with: (attrs?[NSAttributedString.Key.shadow] as? NSShadow)) // NSShadow compatible
                
                if nsShadow != nil {
                    nsShadow!.subShadow = shadow
                    shadow = nsShadow
                }
            
                while shadow != nil {
                    if shadow?.color == nil {
                        shadow = shadow?.subShadow
                        continue
                    }
                    var offset: CGSize = shadow!.offset
                    offset.width -= offsetAlterX
                    context.saveGState()
                    do {
                        context.setShadow(offset: offset, blur: shadow!.radius, color: shadow!.color!.cgColor)
                        context.setBlendMode(shadow!.blendMode)
                        context.translateBy(x: offsetAlterX, y: 0)
                        TextDrawRun(line: line, run: run, context: context, size: size, isVertical: isVertical, runRanges: lineRunRanges?[r], verticalOffset: verticalOffset)
                    }
                    context.restoreGState()
                    shadow = shadow!.subShadow
                }
            }
        }
    }
    context.restoreGState()
}

private func TextDrawInnerShadow(_ layout: TextLayout, context: CGContext, size: CGSize, point: CGPoint, cancel: (() -> Bool)? = nil) {
    
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1, y: -1)
    context.textMatrix = .identity
    let isVertical = layout.container.isVerticalForm
    let verticalOffset: CGFloat = isVertical ? (size.width - layout.container.size.width) : 0
    let lines = layout.lines
    
    let lMax = lines.count
    for l in 0..<lMax {
        if let _cancel = cancel, _cancel() {
            break
        }
        var line = lines[l]
        if let tmp = layout.truncatedLine, tmp.index == line.index {
            line = tmp
        }
        let lineRunRanges = line.verticalRotateRange
        let linePosX = line.position.x
        let linePosY: CGFloat = size.height - line.position.y
        let runs = CTLineGetGlyphRuns(line.ctLine!)
        let rMax = CFArrayGetCount(runs)
        for r in 0..<rMax {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
            if CTRunGetGlyphCount(run) == 0 {
                continue
            }
            context.textMatrix = .identity
            context.textPosition = CGPoint(x: linePosX, y: linePosY)
            let attrs = CTRunGetAttributes(run) as? [AnyHashable : Any]
            var shadow = attrs?[TextAttribute.textInnerShadowAttributeName] as? TextShadow
            while shadow != nil {
                if shadow?.color == nil {
                    shadow = shadow?.subShadow
                    continue
                }
                var runPosition = CGPoint.zero
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition)
                var runImageBounds: CGRect = CTRunGetImageBounds(run, context, CFRangeMake(0, 0))
                runImageBounds.origin.x += runPosition.x
                if runImageBounds.size.width < 0.1 || runImageBounds.size.height < 0.1 {
                    continue
                }
                let runAttrs = CTRunGetAttributes(run) as! [String: AnyObject]
                
                if let _ = runAttrs[TextAttribute.textGlyphTransformAttributeName] as? NSValue {
                    runImageBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                }
                // text inner shadow
                context.saveGState()
                do {
                    context.setBlendMode(shadow!.blendMode)
                    context.setShadow(offset: CGSize.zero, blur: 0, color: nil)
                    context.setAlpha(shadow!.color!.cgColor.alpha)
                    context.clip(to: runImageBounds)
                    context.beginTransparencyLayer(auxiliaryInfo: nil)
                    do {
                        let opaqueShadowColor = shadow!.color!.withAlphaComponent(1)
                        context.setShadow(offset: shadow!.offset, blur: shadow!.radius, color: opaqueShadowColor.cgColor)
                        context.setFillColor(opaqueShadowColor.cgColor)
                        context.setBlendMode(CGBlendMode.sourceOut)
                        context.beginTransparencyLayer(auxiliaryInfo: nil)
                        do {
                            context.fill(runImageBounds)
                            context.setBlendMode(CGBlendMode.destinationIn)
                            context.beginTransparencyLayer(auxiliaryInfo: nil)
                            do {
                                TextDrawRun(line: line, run: run, context: context, size: size, isVertical: isVertical, runRanges: lineRunRanges?[r], verticalOffset: verticalOffset)
                            }
                            context.endTransparencyLayer()
                        }
                        context.endTransparencyLayer()
                    }
                    context.endTransparencyLayer()
                }
                context.restoreGState()
                shadow = shadow!.subShadow
            }
        }
    }
    context.restoreGState()
}

private func TextDrawDebug(_ layout: TextLayout, context: CGContext, size: CGSize, point: CGPoint, op: TextDebugOption?) {
    
    UIGraphicsPushContext(context)
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    context.setLineWidth(1.0 / TextUtilities.textScreenScale)
    context.setLineDash(phase: 0, lengths: [])
    context.setLineJoin(CGLineJoin.miter)
    context.setLineCap(CGLineCap.butt)
    let isVertical = layout.container.isVerticalForm
    let verticalOffset: CGFloat = (isVertical ? (size.width - layout.container.size.width) : 0)
    context.translateBy(x: verticalOffset, y: 0)
    
    if op?.ctFrameBorderColor != nil || op?.ctFrameFillColor != nil {
        var path = layout.container.path
        if path == nil {
            var rect = CGRect.zero
            rect.size = layout.container.size
            rect = rect.inset(by: layout.container.insets)
            if op?.ctFrameBorderColor != nil {
                rect = TextUtilities.textCGRect(pixelHalf: rect)
            } else {
                rect = TextUtilities.textCGRect(pixelRound: rect)
            }
            path = UIBezierPath(rect: rect)
        }
        path?.close()
        for ex in layout.container.exclusionPaths ?? [] {
            path?.append(ex)
        }
        if op?.ctFrameFillColor != nil {
            op!.ctFrameFillColor!.setFill()
            if layout.container.pathLineWidth > 0 {
                context.saveGState()
                do {
                    context.beginTransparencyLayer(auxiliaryInfo: nil)
                    do {
                        context.addPath(path!.cgPath)
                        if layout.container.pathFillEvenOdd {
                            context.fillPath(using: .evenOdd)
                        } else {
                            context.fillPath()
                        }
                        context.setBlendMode(CGBlendMode.destinationOut)
                        UIColor.black.setFill()
                        let cgPath = path!.cgPath.copy(strokingWithWidth: layout.container.pathLineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: 0, transform: .identity)
                        //if cgPath
                        context.addPath(cgPath)
                        context.fillPath()
                    }
                    context.endTransparencyLayer()
                }
                context.restoreGState()
            } else {
                context.addPath(path!.cgPath)
                if layout.container.pathFillEvenOdd {
                    context.fillPath(using: .evenOdd)
                } else {
                    context.fillPath()
                }
            }
        }
        if ((op?.ctFrameBorderColor) != nil) {
            context.saveGState()
            do {
                if layout.container.pathLineWidth > 0 {
                    context.setLineWidth(layout.container.pathLineWidth)
                }
                op!.ctFrameBorderColor!.setStroke()
                context.addPath(path!.cgPath)
                context.strokePath()
            }
            context.restoreGState()
        }
    }
    
    let lines = layout.lines
    let lMax = lines.count
    for l in 0..<lMax {
        var line = lines[l]
        if let tmp = layout.truncatedLine, tmp.index == line.index {
            line = tmp
        }
        let lineBounds = line.bounds
        if op?.ctLineFillColor != nil {
            op!.ctLineFillColor!.setFill()
            context.addRect(TextUtilities.textCGRect(pixelRound: lineBounds))
            context.fillPath()
        }
        if op?.ctLineBorderColor != nil {
            op!.ctLineBorderColor!.setStroke()
            context.addRect(TextUtilities.textCGRect(pixelHalf: lineBounds))
            context.strokePath()
        }
        if op?.baselineColor != nil {
            op!.baselineColor!.setStroke()
            if isVertical {
                let x: CGFloat = TextUtilities.textCGFloat(pixelHalf: line.position.x)
                let y1: CGFloat = TextUtilities.textCGFloat(pixelHalf: line.top)
                let y2: CGFloat = TextUtilities.textCGFloat(pixelHalf: line.bottom)
                context.move(to: CGPoint(x: x, y: y1))
                context.addLine(to: CGPoint(x: x, y: y2))
                context.strokePath()
            } else {
                let x1: CGFloat = TextUtilities.textCGFloat(pixelHalf: lineBounds.origin.x)
                let x2: CGFloat = TextUtilities.textCGFloat(pixelHalf: (lineBounds.origin.x + lineBounds.size.width))
                let y: CGFloat = TextUtilities.textCGFloat(pixelHalf: line.position.y)
                context.move(to: CGPoint(x: x1, y: y))
                context.addLine(to: CGPoint(x: x2, y: y))
                context.strokePath()
            }
        }
        if op?.ctLineNumberColor != nil {
            op!.ctLineNumberColor!.set()
            let num = NSMutableAttributedString(string: l.description)
            num.bs_color = op?.ctLineNumberColor
            num.bs_font = UIFont.systemFont(ofSize: 6)
            num.draw(at: CGPoint(x: line.position.x, y: line.position.y - (isVertical ? 1 : 6)))
        }
        if op?.ctRunFillColor != nil || op?.ctRunBorderColor != nil || op?.ctRunNumberColor != nil || op?.cgGlyphFillColor != nil || op?.cgGlyphBorderColor != nil {
            let runs = CTLineGetGlyphRuns(line.ctLine!)
            let rMax = CFArrayGetCount(runs)
            for r in 0..<rMax {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
                let glyphCount: CFIndex = CTRunGetGlyphCount(run)
                if glyphCount == 0 {
                    continue
                }
                let glyphPositions = UnsafeMutablePointer<CGPoint>.allocate(capacity: glyphCount)
                CTRunGetPositions(run, CFRangeMake(0, glyphCount), glyphPositions)
                let glyphAdvances = UnsafeMutablePointer<CGSize>.allocate(capacity: glyphCount)
                CTRunGetAdvances(run, CFRangeMake(0, glyphCount), glyphAdvances)
                var runPosition: CGPoint = glyphPositions[0]
                
                if isVertical {
                    TextUtilities.numberSwap(&runPosition.x, b: &runPosition.y)
                    runPosition.x = line.position.x
                    runPosition.y += line.position.y
                } else {
                    runPosition.x += line.position.x
                    runPosition.y = line.position.y - runPosition.y
                }
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                var leading: CGFloat = 0
                let width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading))
                var runTypoBounds = CGRect.zero
                if isVertical {
                    runTypoBounds = CGRect(x: runPosition.x - descent, y: runPosition.y, width: ascent + descent, height: width)
                } else {
                    runTypoBounds = CGRect(x: runPosition.x, y: line.position.y - ascent, width: width, height: ascent + descent)
                }
                if op?.ctRunFillColor != nil {
                    op!.ctRunFillColor!.setFill()
                    context.addRect(TextUtilities.textCGRect(pixelRound: runTypoBounds))
                    context.fillPath()
                }
                if op?.ctRunBorderColor != nil {
                    op!.ctRunBorderColor!.setStroke()
                    context.addRect(TextUtilities.textCGRect(pixelHalf: runTypoBounds))
                    context.strokePath()
                }
                if op?.ctRunNumberColor != nil {
                    op!.ctRunNumberColor!.set()
                    let num = NSMutableAttributedString(string: r.description)
                    num.bs_color = op?.ctRunNumberColor
                    num.bs_font = UIFont.systemFont(ofSize: 6)
                    num.draw(at: CGPoint(x: runTypoBounds.origin.x, y: runTypoBounds.origin.y - 1))
                }
                if op?.cgGlyphBorderColor != nil || op?.cgGlyphFillColor != nil {
                    for g in 0..<glyphCount {
                        var pos: CGPoint = glyphPositions[g]
                        let adv: CGSize = glyphAdvances[g]
                        var rect = CGRect.zero
                        if isVertical {
                            TextUtilities.numberSwap(&pos.x, b: &pos.y)
                            pos.x = runPosition.x
                            pos.y += line.position.y
                            rect = CGRect(x: pos.x - descent, y: pos.y, width: runTypoBounds.size.width, height: adv.width)
                        } else {
                            pos.x += line.position.x
                            pos.y = runPosition.y
                            rect = CGRect(x: pos.x, y: pos.y - ascent, width: adv.width, height: runTypoBounds.size.height)
                        }
                        if op?.cgGlyphFillColor != nil {
                            op!.cgGlyphFillColor!.setFill()
                            context.addRect(TextUtilities.textCGRect(pixelRound: rect))
                            context.fillPath()
                        }
                        if op?.cgGlyphBorderColor != nil {
                            op!.cgGlyphBorderColor!.setStroke()
                            context.addRect(TextUtilities.textCGRect(pixelHalf: rect))
                            context.strokePath()
                        }
                    }
                }
                glyphPositions.deallocate()
                glyphAdvances.deallocate()
            }
        }
    }
    context.restoreGState()
    UIGraphicsPopContext()
}
