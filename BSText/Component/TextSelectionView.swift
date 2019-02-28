//
//  TextSelectionView.swift
//  BSText
//
//  Created by BlueSky on 2018/12/3.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

fileprivate let kMarkAlpha: CGFloat = 0.2
fileprivate let kLineWidth: CGFloat = 2.0
fileprivate let kBlinkDuration = 0.5
fileprivate let kBlinkFadeDuration = 0.2
fileprivate let kBlinkFirstDelay = 0.1
fileprivate let kTouchTestExtend: CGFloat = 14.0
fileprivate let kTouchDotExtend: CGFloat = 7.0


/**
 A single dot view. The frame should be foursquare.
 Change the background color for display.
 
 @discussion Typically, you should not use this class directly.
 */
@objc public class SelectionGrabberDot: UIView {
    
    /// Dont't access this property. It was used by `TextEffectWindow`.
    @objc public var mirror: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let length = min(bounds.size.width, bounds.size.height)
        layer.cornerRadius = length * 0.5
        mirror.bounds = bounds
        mirror.layer.cornerRadius = layer.cornerRadius
    }
    
    func setBackgroundColor(_ backgroundColor: UIColor?) {
        super.backgroundColor = backgroundColor
        mirror.backgroundColor = backgroundColor
    }
}

/**
 A grabber (stick with a dot).
 
 @discussion Typically, you should not use this class directly.
 */
@objc public class SelectionGrabber: UIView {
    
    /*/< the dot view */
    @objc public private(set) var dot = SelectionGrabberDot(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    /*/< don't support composite direction */
    @objc public var dotDirection = TextDirection.none {
        didSet {
            addSubview(dot)
            var frame: CGRect = dot.frame
            let ofs: CGFloat = 0.5
            if dotDirection == TextDirection.top {
                frame.origin.y = -frame.size.height + ofs
                frame.origin.x = (bounds.size.width - frame.size.width) / 2
            } else if dotDirection == TextDirection.right {
                frame.origin.x = bounds.size.width - ofs
                frame.origin.y = (bounds.size.height - frame.size.height) / 2
            } else if dotDirection == TextDirection.bottom {
                frame.origin.y = bounds.size.height - ofs
                frame.origin.x = (bounds.size.width - frame.size.width) / 2
            } else if dotDirection == TextDirection.left {
                frame.origin.x = -frame.size.width + ofs
                frame.origin.y = (bounds.size.height - frame.size.height) / 2
            } else {
                dot.removeFromSuperview()
            }
            dot.frame = frame
        }
    }
    
    ///< tint color, default is nil
    public var color: UIColor? {
        willSet {
            backgroundColor = newValue
            dot.backgroundColor = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let d = dotDirection
        self.dotDirection = d
    }
    
    func touchRect() -> CGRect {
        var rect: CGRect = frame.insetBy(dx: -kTouchTestExtend, dy: -kTouchTestExtend)
        var insets = UIEdgeInsets.zero
        if dotDirection == TextDirection.top {
            insets.top = -kTouchDotExtend
        } else if dotDirection == TextDirection.right {
            insets.right = -kTouchDotExtend
        } else if dotDirection == TextDirection.bottom {
            insets.bottom = -kTouchDotExtend
        } else if dotDirection == TextDirection.left {
            insets.left = -kTouchDotExtend
        }
        rect = rect.inset(by: insets)
        return rect
    }
}

/**
 The selection view for text edit and select.
 
 @discussion Typically, you should not use this class directly.
 */
@objc public class TextSelectionView: UIView {
    
    /*/< the holder view */
    @objc public weak var hostView: UIView?
    
    /*/< the tint color */
    @objc public var color: UIColor? {
        didSet {
            caretView.backgroundColor = color
            startGrabber.color = color
            endGrabber.color = color
            for v in markViews {
                v.backgroundColor = color
            }
        }
    }
    
    /*/< whether the caret is blinks */
    @objc public var caretBlinks = false {
        willSet {
            if caretBlinks != newValue {
                caretView.alpha = 1
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self._startBlinks), object: nil)
                if newValue {
                    perform(#selector(self._startBlinks), with: nil, afterDelay: kBlinkFirstDelay)
                } else {
                    caretTimer?.invalidate()
                    caretTimer = nil
                }
            }
        }
    }
    
    /*/< whether the caret is visible */
    @objc public var caretVisible = false {
        didSet {
            caretView.isHidden = !caretVisible
            caretView.alpha = 1
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self._startBlinks), object: nil)
            if caretBlinks {
                perform(#selector(self._startBlinks), with: nil, afterDelay: kBlinkFirstDelay)
            }
        }
    }
    
    /*/< weather the text view is vertical form */
    @objc public var verticalForm = false {
        didSet {
            if (verticalForm != oldValue) {
                let c = caretRect
                self.caretRect = c
                startGrabber.dotDirection = verticalForm ? TextDirection.right : TextDirection.top
                endGrabber.dotDirection = verticalForm ? TextDirection.left : TextDirection.bottom
            }
        }
    }
    
    /*/< caret rect (width==0 or height==0) */
    @objc public var caretRect = CGRect.zero {
        didSet {
            caretView.frame = _standardCaretRect(caretRect)
            let minWidth = min(caretView.bounds.size.width, caretView.bounds.size.height)
            caretView.layer.cornerRadius = minWidth / 2
        }
    }
    
    /*/< default is nil */
    @objc public var selectionRects: [TextSelectionRect]? {
        didSet {
            for v in markViews {
                v.removeFromSuperview()
            }
            markViews.removeAll()
            startGrabber.isHidden = true
            endGrabber.isHidden = true
            (selectionRects as NSArray?)?.enumerateObjects({ r, idx, stop in
                guard let tmpr = r as? TextSelectionRect else {
                    return
                }
                var rect: CGRect = tmpr.rect
                rect = rect.standardized
                rect = TextUtilities.textCGRect(pixelRound: rect)
                if tmpr.containsStart || tmpr.containsEnd {
                    rect = self._standardCaretRect(rect)
                    if tmpr.containsStart {
                        self.startGrabber.isHidden = false
                        self.startGrabber.frame = rect
                    }
                    if tmpr.containsEnd {
                        self.endGrabber.isHidden = false
                        self.endGrabber.frame = rect
                    }
                } else {
                    if (rect.size.width > 0) && (rect.size.height > 0) {
                        let mark = UIView(frame: rect)
                        mark.backgroundColor = self.color
                        mark.alpha = kMarkAlpha
                        self.insertSubview(mark, at: 0)
                        self.markViews.append(mark)
                    }
                }
            })
        }
    }
    
    @objc public private(set) var caretView = UIView()
    @objc public private(set) var startGrabber = SelectionGrabber()
    @objc public private(set) var endGrabber = SelectionGrabber()
    
    private var caretTimer: Timer?
    private lazy var markViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        clipsToBounds = false
        
        caretView.isHidden = true
        startGrabber.dotDirection = TextDirection.top
        startGrabber.isHidden = true
        endGrabber.dotDirection = TextDirection.bottom
        endGrabber.isHidden = true
        addSubview(startGrabber)
        addSubview(endGrabber)
        addSubview(caretView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        caretTimer?.invalidate()
    }
    
    @objc func _startBlinks() {
        caretTimer?.invalidate()
        if caretVisible {
            caretTimer = Timer.bs_scheduledTimer(with: kBlinkDuration, target: self, selector: #selector(self._doBlink), userInfo: nil, repeats: true)
            RunLoop.current.add(caretTimer!, forMode: .default)
        } else {
            caretView.alpha = 1
        }
    }
    
    @objc func _doBlink() {
        UIView.animate(withDuration: kBlinkFadeDuration, delay: 0, options: .curveEaseInOut, animations: {
            if self.caretView.alpha == 1 {
                self.caretView.alpha = 0
            } else {
                self.caretView.alpha = 1
            }
        })
    }
    
    private func _standardCaretRect(_ caretRect: CGRect) -> CGRect {
        var c = caretRect.standardized
        if verticalForm {
            if c.size.height == 0 {
                c.size.height = kLineWidth
                c.origin.y -= kLineWidth * 0.5
            }
            if c.origin.y < 0 {
                c.origin.y = 0
            } else if c.origin.y + c.size.height > bounds.size.height {
                c.origin.y = bounds.size.height - c.size.height
            }
        } else {
            if c.size.width == 0 {
                c.size.width = kLineWidth
                c.origin.x -= kLineWidth * 0.5
            }
            if c.origin.x < 0 {
                c.origin.x = 0
            } else if c.origin.x + c.size.width > bounds.size.width {
                c.origin.x = bounds.size.width - c.size.width
            }
        }
        c = TextUtilities.textCGRect(pixelRound: c)
        if c.origin.x.isNaN || c.origin.x.isInfinite {
            c.origin.x = 0
        }
        if c.origin.y.isNaN || c.origin.y.isInfinite {
            c.origin.y = 0
        }
        if c.size.width.isNaN || c.size.width.isInfinite {
            c.size.width = 0
        }
        if c.size.height.isNaN || c.size.height.isInfinite {
            c.size.height = 0
        }
        return c
    }
    
    @objc(isGrabberContainsPoint:)
    public func isGrabberContains(_ point: CGPoint) -> Bool {
        return isStartGrabberContains(point) || isEndGrabberContains(point)
    }
    
    @objc(isStartGrabberContainsPoint:)
    public func isStartGrabberContains(_ point: CGPoint) -> Bool {
        if startGrabber.isHidden {
            return false
        }
        let startRect: CGRect = startGrabber.touchRect()
        let endRect: CGRect = endGrabber.touchRect()
        if startRect.intersects(endRect) {
            let distStart = TextUtilities.textCGPointGetDistance(to: point, p2: TextUtilities.textCGRectGetCenter(startRect))
            let distEnd = TextUtilities.textCGPointGetDistance(to: point, p2: TextUtilities.textCGRectGetCenter(endRect))
            if distEnd <= distStart {
                return false
            }
        }
        return startRect.contains(point)
    }
    
    @objc(isEndGrabberContainsPoint:)
    public func isEndGrabberContains(_ point: CGPoint) -> Bool {
        if endGrabber.isHidden {
            return false
        }
        let startRect: CGRect = startGrabber.touchRect()
        let endRect: CGRect = endGrabber.touchRect()
        if startRect.intersects(endRect) {
            let distStart = TextUtilities.textCGPointGetDistance(to: point, p2: TextUtilities.textCGRectGetCenter(startRect))
            let distEnd = TextUtilities.textCGPointGetDistance(to: point, p2: TextUtilities.textCGRectGetCenter(endRect))
            if distEnd > distStart {
                return false
            }
        }
        return endRect.contains(point)
    }
    
    @objc(isCaretContainsPoint:)
    public func isCaretContains(_ point: CGPoint) -> Bool {
        if caretVisible {
            let rect: CGRect = caretRect.insetBy(dx: -kTouchTestExtend, dy: -kTouchTestExtend)
            return rect.contains(point)
        }
        return false
    }
    
    @objc(isSelectionRectsContainsPoint:)
    public func isSelectionRectsContains(_ point: CGPoint) -> Bool {
        guard let s = selectionRects, s.count > 0 else {
            return false
        }
        for r in s {
            if r.rect.contains(point) {
                return true
            }
        }
        return false
    }
}
