//
//  TextContainerView.swift
//  BSText
//
//  Created by BlueSky on 2018/12/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

/**
 A simple view to diaplay `TextLayout`.
 
 @discussion This view can become first responder. If this view is first responder,
 all the action (such as UIMenu's action) would forward to the `hostView` property.
 Typically, you should not use this class directly.
 
 @warning All the methods in this class should be called on main thread.
 */
public class TextContainerView: UIView {
    
    /// First responder's aciton will forward to this view.
    @objc public weak var hostView: UIView?
    
    private var _debugOption: TextDebugOption?
    /// Debug option for layout debug. Set this property will let the view redraw it's contents.
    @objc public var debugOption: TextDebugOption? {
        set {
            let needDraw = _debugOption?.needDrawDebug ?? false
            _debugOption = newValue?.copy() as! TextDebugOption?
            if _debugOption?.needDrawDebug ?? false != needDraw {
                setNeedsDisplay()
            }
        }
        get {
            return _debugOption
        }
    }
    
    /// Text vertical alignment.
    @objc public var textVerticalAlignment: TextVerticalAlignment = .top {
        didSet {
            if textVerticalAlignment == oldValue {
                return
            }
            setNeedsDisplay()
        }
    }
    
    /// Text layout. Set this property will let the view redraw it's contents.
    @objc public var layout: TextLayout? {
        willSet {
            if self.layout == newValue {
                return
            }
            attachmentChanged = true
            setNeedsDisplay()
        }
    }
    
    /// The contents fade animation duration when the layout's contents changed. Default is 0 (no animation).
    @objc public var contentsFadeDuration: TimeInterval = 0 {
        didSet {
            if contentsFadeDuration == oldValue {
                return
            }
            if contentsFadeDuration <= 0 {
                layer.removeAnimation(forKey: "contents")
            }
        }
    }
    
    private var attachmentChanged = false
    private lazy var attachmentViews: [UIView] = []
    private lazy var attachmentLayers: [CALayer] = []
    
    /// Convenience method to set `layout` and `contentsFadeDuration`.
    /// @param layout  Same as `layout` property.
    /// @param fadeDuration  Same as `contentsFadeDuration` property.
    @objc(setLayout:withFadeDuration:)
    public func set(layout: TextLayout?, with fadeDuration: TimeInterval) {
        contentsFadeDuration = fadeDuration
        self.layout = layout
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override function
    public override func draw(_ rect: CGRect) {
        
        // fade content
        layer.removeAnimation(forKey: "contents")
        if contentsFadeDuration > 0 {
            let transition = CATransition()
            transition.duration = contentsFadeDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            transition.type = .fade
            layer.add(transition, forKey: "contents")
        }

        // update attachment
        if attachmentChanged {
            for view in attachmentViews {
                if view.superview == self {
                    view.removeFromSuperview()
                }
            }
            for layer in attachmentLayers {
                if layer.superlayer == layer {
                    layer.removeFromSuperlayer()
                }
            }
            attachmentViews.removeAll()
            attachmentLayers.removeAll()
        }

        // draw layout
        let boundingSize: CGSize = layout?.textBoundingSize ?? CGSize.zero
        var point = CGPoint.zero
        if textVerticalAlignment == TextVerticalAlignment.center {
            if layout?.container.isVerticalForm ?? false {
                point.x = -(bounds.size.width - boundingSize.width) * 0.5
            } else {
                point.y = (bounds.size.height - boundingSize.height) * 0.5
            }
        } else if textVerticalAlignment == TextVerticalAlignment.bottom {
            if layout?.container.isVerticalForm ?? false {
                point.x = -(bounds.size.width - boundingSize.width)
            } else {
                point.y = bounds.size.height - boundingSize.height
            }
        }
        layout?.draw(in: UIGraphicsGetCurrentContext(), size: bounds.size, point: point, view: self, layer: layer, debug: _debugOption, cancel: nil)
        
        // update attachment
        if attachmentChanged {
            attachmentChanged = false
            for a: TextAttachment in layout?.attachments ?? [] {
                if let aContent = a.content as? UIView {
                    attachmentViews.append(aContent)
                }
                if let aContent = a.content as? CALayer {
                    attachmentLayers.append(aContent)
                }
            }
        }
    }
    
    override public var frame: CGRect {
        set {
            let oldSize: CGSize = bounds.size
            super.frame = newValue
            if !oldSize.equalTo(bounds.size) {
                setNeedsLayout()
            }
        }
        get {
            return super.frame
        }
    }
    
    override public var bounds: CGRect {
        set {
            let oldSize: CGSize = self.bounds.size
            super.bounds = newValue
            if !oldSize.equalTo(self.bounds.size) {
                setNeedsLayout()
            }
        }
        get {
            return super.bounds
        }
    }

    // MARK: - UIResponder forward
    
    override public var canBecomeFirstResponder: Bool {
        return true
    }

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return hostView?.canPerformAction(action, withSender: sender) ?? false
    }

    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        return hostView
    }
}
