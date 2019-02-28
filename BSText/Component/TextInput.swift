//
//  TextInput.swift
//  BSText
//
//  Created by BlueSky on 2018/10/31.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

/**
 Text position affinity. For example, the offset appears after the last
 character on a line is backward affinity, before the first character on
 the following line is forward affinity.
 */
@objc public enum TextAffinity : Int {
    ///< offset appears before the character
    case forward = 0
    ///< offset appears after the character
    case backward = 1
}

/**
 A TextPosition object represents a position in a text container; in other words,
 it is an index into the backing string in a text-displaying view.
 
 TextPosition has the same API as Apple's implementation in UITextView/UITextField,
 so you can alse use it to interact with UITextView/UITextField.
 */
public class TextPosition: UITextPosition, NSCopying {
    
    @objc public private(set) var offset: Int = 0
    @objc public private(set) var affinity: TextAffinity = .forward
    
    @objc override init() {
        super.init()
    }
    
    @objc(positionWithOffset:)
    public class func position(with offset: Int) -> TextPosition {
        return TextPosition.position(with: offset, affinity: TextAffinity.forward)
    }
    
    public convenience init(offset: Int) {
        self.init()
        self.offset = offset
    }
    
    @objc(positionWithOffset:affinity:)
    public class func position(with offset: Int, affinity: TextAffinity) -> TextPosition {
        let e = TextPosition()
        e.offset = offset
        e.affinity = affinity
        return e
    }
    
    public convenience init(offset: Int, affinity: TextAffinity) {
        self.init()
        self.offset = offset
        self.affinity = affinity
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return TextPosition.position(with: self.offset, affinity: self.affinity)
    }
    
    public override var description: String {
        return "<\(type(of: self)): \(String(format: "%p", self))> (\(offset)\(affinity == TextAffinity.forward ? "F" : "B"))"
    }
    
    public func hash() -> Int {
        return offset * 2 + (affinity == TextAffinity.forward ? 1 : 0)
    }
    
    public func isEqual(_ object: TextPosition?) -> Bool {
        guard let o = object else {
            return false
        }
        return offset == o.offset && affinity == o.affinity
    }
    
    @objc public func compare(_ otherPosition: TextPosition?) -> ComparisonResult {
        if otherPosition == nil {
            return .orderedAscending
        }
        if offset < otherPosition?.offset ?? 0 {
            return .orderedAscending
        }
        if offset > otherPosition?.offset ?? 0 {
            return .orderedDescending
        }
        if affinity == TextAffinity.backward && otherPosition?.affinity == TextAffinity.forward {
            return .orderedAscending
        }
        if affinity == TextAffinity.forward && otherPosition?.affinity == TextAffinity.backward {
            return .orderedDescending
        }
        return .orderedSame
    }
}

/**
 A TextRange object represents a range of characters in a text container; in other words,
 it identifies a starting index and an ending index in string backing a text-displaying view.
 
 TextRange has the same API as Apple's implementation in UITextView/UITextField,
 so you can alse use it to interact with UITextView/UITextField.
 */
public class TextRange: UITextRange, NSCopying {
    
    private var _start = TextPosition(offset: 0)
    @objc override public var start: TextPosition {
        set {
            _start = newValue
        }
        get {
            return _start
        }
    }
    
    private var _end = TextPosition(offset: 0)
    override public var end: TextPosition {
        set {
            _end = newValue
        }
        get {
            return _end
        }
    }
    
    override public var isEmpty: Bool {
        get {
            return _start.offset == _end.offset
        }
    }
    
    @objc(rangeWithRange:)
    public class func range(with range: NSRange) -> TextRange {
        return TextRange.range(with: range, affinity: .forward)
    }
    
    @objc(rangeWithRange:affinity:)
    public class func range(with range: NSRange, affinity: TextAffinity) -> TextRange {
        let start = TextPosition.position(with: range.location, affinity: affinity)
        let end = TextPosition.position(with: range.location + range.length, affinity: affinity)
        return TextRange.range(with: start, end: end)
    }
    
    @objc(rangeWithStart:end:)
    public class func range(with start: TextPosition, end: TextPosition) -> TextRange {
        
        let range = TextRange()
        if start.compare(end) == .orderedDescending {
            range._start = end
            range._end = start
        } else {
            range._start = start
            range._end = end
        }
        return range
    }
    
    override init() {
        super.init()
    }
    
    public convenience init(range: NSRange) {
        self.init(range: range, affinity: .forward)
    }
    
    public convenience init(range: NSRange, affinity: TextAffinity) {
        let start = TextPosition.position(with: range.location, affinity: affinity)
        let end = TextPosition.position(with: range.location + range.length, affinity: affinity)
        self.init(start: start, end: end)
    }
    
    public convenience init(start: TextPosition, end: TextPosition) {
        self.init()
        if start.compare(end) == .orderedDescending {
            self._start = end
            self._end = start
        } else {
            self._start = start
            self._end = end
        }
    }
    
    @objc public var asRange: NSRange {
        return NSRange(location: _start.offset, length: _end.offset - _start.offset)
    }
    
    @objc(defaultRange)
    public class func `default`() -> TextRange {
        return TextRange.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let e = TextRange.range(with: self.start, end: self.end)
        return e
    }
    
    public override var description: String {
        return "<\(type(of: self)): \(String(format: "%p", self))> (\(_start.offset), \(end.offset - start.offset))\(end.affinity == TextAffinity.forward ? "F" : "B")"
    }
    
    func hash() -> Int {
        return (MemoryLayout<Int>.size == 8 ? Int(CFSwapInt64(UInt64(start.hash()))) : Int(CFSwapInt32(UInt32(start.hash()))) + end.hash())
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let o = object as! TextRange? else {
            return false
        }
        return start.isEqual(o.start) && end.isEqual(o.end)
    }
}


/**
 A TextSelectionRect object encapsulates information about a selected range of
 text in a text-displaying view.
 
 TextSelectionRect has the same API as Apple's implementation in UITextView/UITextField,
 so you can alse use it to interact with UITextView/UITextField.
 */
public class TextSelectionRect: UITextSelectionRect, NSCopying {
    
    private var _rect = CGRect.zero
    @objc override public var rect: CGRect {
        set {
            _rect = newValue
        }
        get {
            return _rect
        }
    }
    
    private var _writingDirection: UITextWritingDirection = .natural
    @objc override public var writingDirection: UITextWritingDirection {
        set {
            _writingDirection = newValue
        }
        get {
            return _writingDirection
        }
    }
    
    private var _containsStart = false
    @objc override public var containsStart: Bool {
        set {
            _containsStart = newValue
        }
        get {
            return _containsStart
        }
    }
    
    private var _containsEnd = false
    @objc override public var containsEnd: Bool {
        set {
            _containsEnd = newValue
        }
        get {
            return _containsEnd
        }
    }
    
    private var _isVertical = false
    @objc override public var isVertical: Bool {
        set {
            _isVertical = newValue
        }
        get {
            return _isVertical
        }
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let one = TextSelectionRect()
        one.rect = self.rect
        one.writingDirection = self.writingDirection
        one.containsStart = self.containsStart
        one.containsEnd = self.containsEnd
        one.isVertical = self.isVertical
        return one
    }
}
