//
//  TextDebugOption.swift
//  BSText
//
//  Created by BlueSky on 2018/12/10.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

/**
 The TextDebugTarget protocol defines the method a debug target should implement.
 A debug target can be add to the global container to receive the shared debug
 option changed notification.
 */
@objc public protocol TextDebugTarget: NSObjectProtocol {
    /**
     When the shared debug option changed, this method would be called on main thread.
     It should return as quickly as possible. The option's property should not be changed
     in this method.
     
     Setter: The shared debug option.
     */
    var debugOption: TextDebugOption? { get set }
}


fileprivate var sharedDebugLock = DispatchSemaphore(value: 1)

/// A List Of TextDebugOption (Unsafe Unretain)
fileprivate var sharedDebugTargets = NSPointerArray()

@objc public class TextDebugOption: NSObject, NSCopying {
    
    private static let _shared = TextDebugOption()
    private static var sharedOption: TextDebugOption?
    
    @objc public static var shared: TextDebugOption {
        get {
            if let s = sharedOption {
                return s
            }
            return _shared
        }
        set {
            sharedOption = newValue
        }
    }
    
    /*/< baseline color */
    @objc public var baselineColor: UIColor?
    /*/< CTFrame path border color */
    @objc public var ctFrameBorderColor: UIColor?
    /*/< CTFrame path fill color */
    @objc public var ctFrameFillColor: UIColor?
    /*/< CTLine bounds border color */
    @objc public var ctLineBorderColor: UIColor?
    /*/< CTLine bounds fill color */
    @objc public var ctLineFillColor: UIColor?
    /*/< CTLine line number color */
    @objc public var ctLineNumberColor: UIColor?
    /*/< CTRun bounds border color */
    @objc public var ctRunBorderColor: UIColor?
    /*/< CTRun bounds fill color */
    @objc public var ctRunFillColor: UIColor?
    /*/< CTRun number color */
    @objc public var ctRunNumberColor: UIColor?
    /*/< CGGlyph bounds border color */
    @objc public var cgGlyphBorderColor: UIColor?
    ///< CGGlyph bounds fill color
    @objc public var cgGlyphFillColor: UIColor?
    
    public override init() {
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let op = TextDebugOption()
        op.baselineColor = baselineColor
        op.ctFrameBorderColor = ctFrameBorderColor
        op.ctFrameFillColor = ctFrameFillColor
        op.ctLineBorderColor = ctLineBorderColor
        op.ctLineFillColor = ctLineFillColor
        op.ctLineNumberColor = ctLineNumberColor
        op.ctRunBorderColor = ctRunBorderColor
        op.ctRunFillColor = ctRunFillColor
        op.ctRunNumberColor = ctRunNumberColor
        op.cgGlyphBorderColor = cgGlyphBorderColor
        op.cgGlyphFillColor = cgGlyphFillColor
        return op
    }
    
    ///< `YES`: at least one debug color is visible. `NO`: all debug color is invisible/nil.
    @objc public var needDrawDebug: Bool {
        
        if ((self.baselineColor != nil) ||
            (self.ctFrameBorderColor != nil) ||
            (self.ctFrameFillColor != nil) ||
            (self.ctLineBorderColor != nil) ||
            (self.ctLineFillColor != nil) ||
            (self.ctLineNumberColor != nil) ||
            (self.ctRunBorderColor != nil) ||
            (self.ctRunFillColor != nil) ||
            (self.ctRunNumberColor != nil) ||
            (self.cgGlyphBorderColor != nil) ||
            (self.cgGlyphFillColor != nil)) {
            
            return true
        }
        
        return false
    }

    ///< Set all debug color to nil.
    @objc public func clear() {
        self.baselineColor = nil;
        self.ctFrameBorderColor = nil;
        self.ctFrameFillColor = nil;
        self.ctLineBorderColor = nil;
        self.ctLineFillColor = nil;
        self.ctLineNumberColor = nil;
        self.ctRunBorderColor = nil;
        self.ctRunFillColor = nil;
        self.ctRunNumberColor = nil;
        self.cgGlyphBorderColor = nil;
        self.cgGlyphFillColor = nil;
    }
    
    /**
     Add a debug target.
     
     @discussion When `setSharedDebugOption:` is called, all added debug target will
     receive `setDebugOption:` in main thread. It maintains an unsafe_unretained
     reference to this target. The target must to removed before dealloc.
     
     @param target A debug target.
     */
    @objc(addDebugTarget:)
    public class func add(_ target: TextDebugTarget?) {
        
        sharedDebugLock.wait()
        sharedDebugTargets.addObject(target)
        sharedDebugLock.signal()
    }
    
    /**
     Remove a debug target which is added by `addDebugTarget:`.
     
     @param target A debug target.
     */
    @objc(removeDebugTarget:)
    public class func remove(_ target: TextDebugTarget?) {
        
        sharedDebugLock.wait()
        sharedDebugTargets.addObject(target)
        sharedDebugLock.signal()
    }
    
    /**
     Returns the shared debug option.
     
     @return The shared debug option, default is nil.
     */
    @objc public class func sharedDebugOption() -> TextDebugOption? {
        
        sharedDebugLock.wait()
        let op = TextDebugOption.shared
        sharedDebugLock.signal()
        
        return op
    }
    
    /**
     Set a debug option as shared debug option.
     This method must be called on main thread.
     
     @discussion When call this method, the new option will set to all debug target
     which is added by `addDebugTarget:`.
     
     @param option  A new debug option (nil is valid).
     */
    @objc public class func setSharedDebugOption(_ option: TextDebugOption) {
        assert(Thread.isMainThread, "This method must be called on the main thread")
        
        sharedDebugLock.wait()
        TextDebugOption.shared = option
        for target in sharedDebugTargets.allObjects {
            (target as? TextDebugTarget)?.debugOption = TextDebugOption.shared
        }
        sharedDebugLock.signal()
    }
}

extension NSPointerArray {
    
    func addObject(_ object: AnyObject?) {
        guard let strongObject = object else { return }
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }
    
    func insertObject(_ object: AnyObject?, at index: Int) {
        guard index < count, let strongObject = object else { return }
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        insertPointer(pointer, at: index)
    }
    
    func replaceObject(at index: Int, withObject object: AnyObject?) {
        guard index < count, let strongObject = object else { return }
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        replacePointer(at: index, withPointer: pointer)
    }
    
    func object(at index: Int) -> AnyObject? {
        guard index < count, let pointer = self.pointer(at: index) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    func removeObject(at index: Int) {
        guard index < count else { return }
        removePointer(at: index)
    }
    
//    如果想清理这个数组,把其中的对象都置为 nil ,你可以调用 compact() 方法:
}
