//
//  TextAsyncLayer.swift
//  BSText
//
//  Created by Bruce on 2018/10/28.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

fileprivate var k_queueCount: Int = 1
fileprivate var k_counter: Int32 = 0
fileprivate var k_AsyncLayerGetDisplayQueues: [DispatchQueue] = {
    
    var arr = [DispatchQueue]()
    let maxQueueCount = 16
    k_queueCount = ProcessInfo.processInfo.activeProcessorCount
    k_queueCount = k_queueCount < 1 ? 1 : k_queueCount > maxQueueCount ? maxQueueCount : k_queueCount
    for _ in 0..<k_queueCount {
        arr.append(DispatchQueue(label: "com.BlueSky.text.render", qos: .userInitiated))
    }
    
    return arr
}()

/// Global display queue, used for content rendering.
fileprivate func TextAsyncLayerGetDisplayQueue() -> DispatchQueue {
    
    let cur = Int(OSAtomicIncrement32(&k_counter))
    return k_AsyncLayerGetDisplayQueues[cur % k_queueCount]
}

/**
 The TextAsyncLayer's delegate protocol. The delegate of the TextAsyncLayer (typically a UIView)
 must implements the method in this protocol.
 */
@objc public protocol TextAsyncLayerDelegate: NSObjectProtocol {
    
    /// This method is called to return a new display task when the layer's contents need update.
    func newAsyncDisplayTask() -> TextAsyncLayerDisplayTask?
}

/**
 The TextAsyncLayer class is a subclass of CALayer used for render contents asynchronously.
 
 @discussion When the layer need update it's contents, it will ask the delegate
 for a async display task to render the contents in a background queue.
 */
public class TextAsyncLayer: CALayer {
    
    /// Whether the render code is executed in background. Default is YES.
    @objc public var displaysAsynchronously = false
    
    private var sentinel = TextSentinel()
    
    // MARK: - Override
    override public class func defaultValue(forKey key: String) -> Any? {
        if (key == "displaysAsynchronously") {
            return true
        } else {
            return super.defaultValue(forKey: key)
        }
    }
    
    override public init() {
        
        displaysAsynchronously = true
        
        super.init()
        
        self.contentsScale = UIScreen.main.scale
    }
    
    override public init(layer: Any) {
        
        displaysAsynchronously = true
        
        super.init(layer: layer)
        
        self.contentsScale = UIScreen.main.scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        sentinel.increase()
    }
    
    override public func setNeedsDisplay() {
        _cancelAsyncDisplay()
        super.setNeedsDisplay()
    }
    
    override public func display() {
        super.contents = super.contents
        _displayAsync(displaysAsynchronously)
    }
    
    private func _displayAsync(_ async: Bool) -> Void {
        
        weak var tmpdelegate = self.delegate as? TextAsyncLayerDelegate
        let task: TextAsyncLayerDisplayTask? = tmpdelegate?.newAsyncDisplayTask()
        if task?.display == nil {
            if task?.willDisplay != nil {
                task?.willDisplay!(self)
            }
            contents = nil
            if task?.didDisplay != nil {
                task?.didDisplay!(self, true)
            }
            return
        }
        
        if async {
            if task?.willDisplay != nil {
                task?.willDisplay!(self)
            }
            let tmpsentinel = self.sentinel
            let value = tmpsentinel.value
            let isCancelled: (() -> Bool) = {
                return value != tmpsentinel.value
            }
            let size: CGSize = bounds.size
            let tmpopaque: Bool = self.isOpaque
            let scale: CGFloat = contentsScale
            let tmpbackgroundColor = (tmpopaque && self.backgroundColor != nil) ? self.backgroundColor! : nil
            if size.width < 1 || size.height < 1 {
                _ = self.contents
                self.contents = nil
                
                if ((task?.didDisplay) != nil) {
                    task?.didDisplay!(self, true)
                }
                
                return
            }
            
            TextAsyncLayerGetDisplayQueue().async(execute: {
                if isCancelled() {
                    return
                }
                UIGraphicsBeginImageContextWithOptions(size, _: tmpopaque, _: scale)
                let context = UIGraphicsGetCurrentContext()
                if tmpopaque && context != nil {
                    context?.saveGState()
                    do {
                        if tmpbackgroundColor != nil || tmpbackgroundColor!.alpha < 1 {
                            context?.setFillColor(UIColor.white.cgColor)
                            context?.addRect(CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale))
                            context?.fillPath()
                        }
                        if tmpbackgroundColor != nil {
                            context?.setFillColor(tmpbackgroundColor!)
                            context?.addRect(CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale))
                            context?.fillPath()
                        }
                    }
                    context?.restoreGState()
                }
                task?.display!(context, size, isCancelled)
                if isCancelled() {
                    UIGraphicsEndImageContext()
                    DispatchQueue.main.async(execute: {
                        if ((task?.didDisplay) != nil) {
                            task?.didDisplay!(self, false)
                        }
                    })
                    return
                }
                let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                if isCancelled() {
                    DispatchQueue.main.async(execute: {
                        if ((task?.didDisplay) != nil) {
                            task?.didDisplay!(self, false)
                        }
                    })
                    return
                }
                DispatchQueue.main.async(execute: {
                    if isCancelled() {
                        if ((task?.didDisplay) != nil) {
                            task?.didDisplay!(self, false)
                        }
                    } else {
                        self.contents = image?.cgImage
                        if ((task?.didDisplay) != nil) {
                            task?.didDisplay!(self, true)
                        }
                    }
                })
            })
        } else {
            sentinel.increase()
            if task?.willDisplay != nil {
                task?.willDisplay!(self)
            }
            UIGraphicsBeginImageContextWithOptions(bounds.size, _: self.isOpaque, _: contentsScale)
            let context = UIGraphicsGetCurrentContext()
            if self.isOpaque && context != nil {
                var size: CGSize = bounds.size
                size.width *= contentsScale
                size.height *= contentsScale
                context?.saveGState()
                do {
                    if self.backgroundColor == nil || self.backgroundColor!.alpha < 1 {
                        context?.setFillColor(UIColor.white.cgColor)
                        context?.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                        context?.fillPath()
                    }
                    if self.backgroundColor != nil {
                        context?.setFillColor(self.backgroundColor!)
                        context?.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                        context?.fillPath()
                    }
                }
                context?.restoreGState()
            }
            task?.display!(context, bounds.size, {
                return false
            })
            
            let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            contents = image?.cgImage
            if task?.didDisplay != nil {
                task?.didDisplay!(self, true)
            }
        }
    }
    
    private func _cancelAsyncDisplay() {
        sentinel.increase()
    }
}

/**
 A display task used by TextAsyncLayer to render the contents in background queue.
 */
public class TextAsyncLayerDisplayTask: NSObject {
    
    /**
     This block will be called before the asynchronous drawing begins.
     It will be called on the main thread.
     
     block param layer: The layer.
     */
    @objc public var willDisplay: ((_ layer: CALayer?) -> Void)?
    
    /**
     This block is called to draw the layer's contents.
     
     @discussion This block may be called on main thread or background thread,
     so is should be thread-safe.
     
     block param context:      A new bitmap content created by layer.
     block param size:         The content size (typically same as layer's bound size).
     block param isCancelled:  If this block returns `YES`, the method should cancel the
     drawing process and return as quickly as possible.
     */
    @objc public var display: ((_ context: CGContext?, _ size: CGSize, _ isCancelled: @escaping () -> Bool) -> Void)?
    
    
    /**
     This block will be called after the asynchronous drawing finished.
     It will be called on the main thread.
     
     block param layer:  The layer.
     block param finished:  If the draw process is cancelled, it's `NO`, otherwise it's `YES`;
     */
    @objc public var didDisplay: ((_ layer: CALayer, _ finished: Bool) -> Void)?
}

/// a thread safe incrementing counter.
fileprivate struct TextSentinel {
    /// Returns the current value of the counter.
    private(set) var value: Int32 = 0
    
    /// Increase the value atomically. @return The new value.
    @discardableResult mutating func increase() -> Int32 {
        
        return OSAtomicIncrement32(&value)
    }
}
