//
//  TextKeyboardManager.swift
//  BSText
//
//  Created by BlueSky on 2018/11/12.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

fileprivate var _TextKeyboardViewFrameObserverKey: Int = 0

/// Observer for view's frame/bounds/center/transform
fileprivate class TextKeyboardViewFrameObserver: NSObject {
    
    private var keyboardView: UIView?
    @objc public var notifyBlock: ((_ keyboard: UIView?) -> Void)?
    
    @objc(addToKeyboardView:) public func addTo(keyboardView: UIView?) {
        if self.keyboardView == keyboardView {
            return
        }
        if let _ = self.keyboardView {
            removeFrameObserver()
            objc_setAssociatedObject(self.keyboardView!, &_TextKeyboardViewFrameObserverKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        self.keyboardView = keyboardView
        if keyboardView != nil {
            addFrameObserver()
        }
        objc_setAssociatedObject(keyboardView!, &_TextKeyboardViewFrameObserverKey, self, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func removeFrameObserver() {
        keyboardView?.removeObserver(self, forKeyPath: "frame")
        keyboardView?.removeObserver(self, forKeyPath: "center")
        keyboardView?.removeObserver(self, forKeyPath: "bounds")
        keyboardView?.removeObserver(self, forKeyPath: "transform")
        keyboardView = nil
    }
    
    func addFrameObserver() {
        if keyboardView == nil {
            return
        }
        keyboardView?.addObserver(self, forKeyPath: "frame", options: [], context: nil)
        keyboardView?.addObserver(self, forKeyPath: "center", options: [], context: nil)
        keyboardView?.addObserver(self, forKeyPath: "bounds", options: [], context: nil)
        keyboardView?.addObserver(self, forKeyPath: "transform", options: [], context: nil)
    }
    
    public class func observerForView(_ keyboardView: UIView?) -> TextKeyboardViewFrameObserver? {
        guard let k = keyboardView else {
            return nil
        }
        return objc_getAssociatedObject(k, &_TextKeyboardViewFrameObserverKey) as? TextKeyboardViewFrameObserver;
    }
    
    deinit {
        removeFrameObserver()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let isPrior: Bool = ((change?[.notificationIsPriorKey] as? Int) != 0)
        if isPrior {
            return
        }
        let changeKind = NSKeyValueChange(rawValue: UInt((change?[.kindKey] as? Int) ?? 0))
        if changeKind != .setting {
            return
        }
        var newVal = change?[.newKey]
        if (newVal as? NSNull) == NSNull() {
            newVal = nil
        }
        if (notifyBlock != nil) {
            notifyBlock!(keyboardView)
        }
    }
}

/**
 The TextKeyboardObserver protocol defines the method you can use
 to receive system keyboard change information.
 */
@objc public protocol TextKeyboardObserver: NSObjectProtocol {
    @objc optional func keyboardChanged(with transition: TextKeyboardTransition)
}

// TODO: - here should use struct in pure Swift
/**
 System keyboard transition information.
 Use -[TextKeyboardManager convertRect:toView:] to convert frame to specified view.
 */
public class TextKeyboardTransition: NSObject {
    
    ///< Keyboard visible before transition.
    @objc public var fromVisible = false
    
    ///< Keyboard visible after transition.
    @objc public var toVisible = false
    
    ///< Keyboard frame before transition.
    @objc public var fromFrame = CGRect.zero
    
    ///< Keyboard frame after transition.
    @objc public var toFrame = CGRect.zero
    
    ///< Keyboard transition animation duration.
    @objc public var animationDuration: TimeInterval = 0
    
    ///< Keyboard transition animation curve.
    @objc public var animationCurve = UIView.AnimationCurve.easeInOut
    
    ///< Keybaord transition animation option.
    @objc public var animationOption = UIView.AnimationOptions.layoutSubviews
}


/**
 A TextKeyboardManager object lets you get the system keyboard information,
 and track the keyboard visible/frame/transition.
 
 @discussion You should access this class in main thread.
 */
public class TextKeyboardManager: NSObject {
    
    /// Get the keyboard window. nil if there's no keyboard window.
    @objc public var keyboardWindow: UIWindow? {
        
        guard let app = TextUtilities.sharedApplication else {
            return nil
        }
        
        for window in app.windows {
            if (_getKeyboardView(from: window) != nil) {
                return window
            }
        }
        
        let window: UIWindow? = app.keyWindow
        if (_getKeyboardView(from: window) != nil) {
            return window
        }
        var kbWindows = [UIWindow]()
        for window in app.windows {
            let windowName = NSStringFromClass(type(of: window))
            if _systemVersion < 9 {
                // UITextEffectsWindow
                if windowName.length == 19 && windowName.hasPrefix("UI") && windowName.hasSuffix("TextEffectsWindow") {
                    
                    kbWindows.append(window)
                }
            } else {
                // UIRemoteKeyboardWindow
                if windowName.length == 22 && windowName.hasPrefix("UI") && windowName.hasSuffix("RemoteKeyboardWindow") {
                    
                    kbWindows.append(window)
                }
            }
        }
        if kbWindows.count == 1 {
            return kbWindows.first
        }
        return nil
    }
    
    /// Get the keyboard view. nil if there's no keyboard view.
    @objc public var keyboardView: UIView? {
        
        let app: UIApplication? = TextUtilities.sharedApplication
        if app == nil {
            return nil
        }
        var window: UIWindow? = nil
        var view: UIView? = nil
        for window in app?.windows ?? [] {
            view = _getKeyboardView(from: window)
            if view != nil {
                return view
            }
        }
        window = app?.keyWindow
        view = _getKeyboardView(from: window)
        if view != nil {
            return view
        }
        return nil
    }
    
    /// Whether the keyboard is visible.
    @objc public var keyboardVisible: Bool {
        
        guard let window = keyboardWindow else {
            return false
        }
        
        guard let view = keyboardView else {
            return false
        }
        let rect: CGRect = window.bounds.intersection(view.frame)
        if rect.isNull {
            return false
        }
        if rect.isInfinite {
            return false
        }
        return rect.size.width > 0 && rect.size.height > 0
    }
    
    /// Get the keyboard frame. CGRectNull if there's no keyboard view.
    /// Use convertRect:toView: to convert frame to specified view.
    @objc public var keyboardFrame: CGRect {
        
        guard let keyboard = keyboardView else {
            return CGRect.null
        }
        var frame = CGRect.null
        
        if let window = keyboard.window {
            frame = window.convert(keyboard.frame, to: nil)
        } else {
            frame = keyboard.frame
        }
        return frame
    }
    
    @objc public class func startManager() -> Void {
        let _ = `default`
    }
    
    /// Get the default manager (returns nil in App Extension).
    @objc(defaultManager)
    public static let `default` = TextKeyboardManager()
    
    override private init() {
        observers = NSHashTable(options: [.weakMemory, .objectPointerPersonality], capacity: 0)
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self._keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // for iPad (iOS 9)
        if _systemVersion >= 9 {
            NotificationCenter.default.addObserver(self, selector: #selector(self._keyboardFrameDidChange(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        }
    }
    
    func _initFrameObserver() {
        
        guard let keyboardView = self.keyboardView else {
            return
        }
        weak var _self = self
        var observer: TextKeyboardViewFrameObserver? = TextKeyboardViewFrameObserver.observerForView(keyboardView)
        if observer == nil {
            observer = TextKeyboardViewFrameObserver()
            observer?.notifyBlock = { keyboard in
                _self!._keyboardFrameChanged(keyboard)
            }
            observer?.addTo(keyboardView: keyboardView)
        }
    }
    
    /**
     Add an observer to manager to get keyboard change information.
     This method makes a weak reference to the observer.
     
     @param observer An observer.
     This method will do nothing if the observer is nil, or already added.
     */
    @objc(addObserver:)
    public func add(observer: TextKeyboardObserver?) {
        guard let observer = observer else {
            return
        }
        observers.add(observer)
    }
    
    /**
     Remove an observer from manager.
     
     @param observer An observer.
     This method will do nothing if the observer is nil, or not in manager.
     */
    @objc(removeObserver:)
    public func remove(observer: TextKeyboardObserver?) {
        guard let observer = observer else {
            return
        }
        observers.remove(observer)
    }
    
    
    private var observers: NSHashTable<TextKeyboardObserver>
    private var fromFrame = CGRect.zero
    private var fromVisible = false
    private var notificationFromFrame = CGRect.zero
    private var notificationToFrame = CGRect.zero
    private var notificationDuration: TimeInterval = 0
    private var notificationCurve = UIView.AnimationCurve.linear
    private var hasNotification = false
    private var observedToFrame = CGRect.zero
    private var hasObservedChange = false
    private var lastIsNotification = false
    
    // MARK: - private
    
    private let _systemVersion = Double(UIDevice.current.systemVersion) ?? 0
    
    private func _getKeyboardView(from window: UIWindow?) -> UIView? {
        /*
         iOS 8:
         UITextEffectsWindow
         UIInputSetContainerView
         UIInputSetHostView << keyboard
         
         iOS 9:
         UIRemoteKeyboardWindow
         UIInputSetContainerView
         UIInputSetHostView << keyboard
         */
        guard let window = window else {
            return nil
        }
        // Get the window
        let windowName = NSStringFromClass(type(of: window))
        if _systemVersion < 9 {
            // UITextEffectsWindow
            if windowName.length != 19 {
                return nil
            }
            if !windowName.hasPrefix("UI") {
                return nil
            }
            if !windowName.hasSuffix("TextEffectsWindow") {
                return nil
            }
        } else {
            // UIRemoteKeyboardWindow
            if windowName.length != 22 {
                return nil
            }
            if !windowName.hasPrefix("UI") {
                return nil
            }
            if !windowName.hasSuffix("RemoteKeyboardWindow") {
                return nil
            }
        }
        
        // Get the view
        // UIInputSetContainerView
        for view: UIView in window.subviews {
            let viewName = NSStringFromClass(type(of: view))
            if viewName.length != 23 {
                continue
            }
            if !viewName.hasPrefix("UI") {
                continue
            }
            if !viewName.hasSuffix("InputSetContainerView") {
                continue
            }
            // UIInputSetHostView
            for subView: UIView in view.subviews {
                let subViewName = NSStringFromClass(type(of: subView))
                if subViewName.length != 18 {
                    continue
                }
                if !subViewName.hasPrefix("UI") {
                    continue
                }
                if !subViewName.hasSuffix("InputSetHostView") {
                    continue
                }
                return subView
            }
        }
        return nil
    }
    
    @objc private func _keyboardFrameWillChange(_ notif: Notification?) {
        guard let notif = notif else {
            return
        }
        guard notif.name == UIResponder.keyboardWillChangeFrameNotification else {
            return
        }
        guard let info = notif.userInfo else {
            return
        }
        _initFrameObserver()
        let beforeValue = info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        let afterValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        let curveNumber = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
        let durationNumber = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let before: CGRect = beforeValue?.cgRectValue ?? .zero
        let after: CGRect = afterValue?.cgRectValue ?? .zero
        let curve: UIView.AnimationCurve = UIView.AnimationCurve(rawValue: curveNumber)!
        let duration = durationNumber
        // ignore zero end frame
        if (after.size.width <= 0) && (after.size.height <= 0) {
            return
        }
        notificationFromFrame = before
        notificationToFrame = after
        notificationCurve = curve
        notificationDuration = duration
        hasNotification = true
        lastIsNotification = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self._notifyAllObservers), object: nil)
        if duration == 0 {
            perform(#selector(self._notifyAllObservers), with: nil, afterDelay: 0, inModes: [.common])
        } else {
            _notifyAllObservers()
        }
    }
    
    @objc private func _keyboardFrameDidChange(_ notif: Notification?) {
        guard let notif = notif else {
            return
        }
        guard notif.name == UIResponder.keyboardDidChangeFrameNotification else {
            return
        }
        guard let info = notif.userInfo else {
            return
        }
        _initFrameObserver()
        let afterValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        let after: CGRect = afterValue?.cgRectValue ?? .zero
        // ignore zero end frame
        if (after.size.width <= 0) && (after.size.height <= 0) {
            return
        }
        notificationToFrame = after
        notificationCurve = UIView.AnimationCurve.easeInOut
        notificationDuration = 0
        hasNotification = true
        lastIsNotification = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self._notifyAllObservers), object: nil)
        perform(#selector(self._notifyAllObservers), with: nil, afterDelay: 0, inModes: [.common])
    }
    
    private func _keyboardFrameChanged(_ keyboard: UIView?) {
        if keyboard != keyboardView {
            return
        }
        
        if let window = keyboard?.window {
            observedToFrame = window.convert(keyboard?.frame ?? CGRect.zero, to: nil)
        } else {
            observedToFrame = (keyboard?.frame)!
        }
        hasObservedChange = true
        lastIsNotification = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self._notifyAllObservers), object: nil)
        perform(#selector(self._notifyAllObservers), with: nil, afterDelay: 0, inModes: [.common])
    }
    
    @objc private func _notifyAllObservers() {
        
        guard let app = TextUtilities.sharedApplication else {
            return
        }
        let keyboard: UIView? = keyboardView
        var window: UIWindow? = keyboard?.window
        if window == nil {
            window = app.keyWindow
        }
        if window == nil {
            window = app.windows.first
        }
        guard let w = window else {
            return
        }
        let trans = TextKeyboardTransition()
        // from
        if fromFrame.size.width == 0 && fromFrame.size.height == 0 {
            // first notify
            fromFrame.size.width = w.bounds.size.width
            fromFrame.size.height = trans.toFrame.size.height
            fromFrame.origin.x = trans.toFrame.origin.x
            fromFrame.origin.y = w.bounds.size.height
        }
        trans.fromFrame = fromFrame
        trans.fromVisible = fromVisible
        // to
        if lastIsNotification || (hasObservedChange && observedToFrame.equalTo(notificationToFrame)) {
            trans.toFrame = notificationToFrame
            trans.animationDuration = notificationDuration
            trans.animationCurve = notificationCurve
            trans.animationOption = UIView.AnimationOptions(rawValue: UInt(notificationCurve.rawValue << 16))
        } else {
            trans.toFrame = observedToFrame
        }
        if window != nil && trans.toFrame.size.width > 0 && trans.toFrame.size.height > 0 {
            let rect: CGRect = w.bounds.intersection(trans.toFrame)
            if !rect.isNull && !rect.isEmpty {
                trans.toVisible = true
            }
        }
        if !trans.toFrame.equalTo(fromFrame) {
            
            for (_, observer) in observers.objectEnumerator().enumerated() {
                guard let o = observer as? TextKeyboardObserver else {
                    return
                }
                if o.responds(to: #selector(TextKeyboardObserver.keyboardChanged(with:))) {
                    o.keyboardChanged!(with: trans)
                }
            }
        }
        hasNotification = false
        hasObservedChange = false
        fromFrame = trans.toFrame
        fromVisible = trans.toVisible
    }
    
    /**
     Convert rect to specified view or window.
     
     @param rect The frame rect.
     @param view A specified view or window (pass nil to convert for main window).
     @return The converted rect in specifeid view.
     */
    @objc(convertRect:toView:)
    public func convert(_ rect: CGRect, to view: UIView?) -> CGRect {
        var rect = rect
        
        guard let app = TextUtilities.sharedApplication else {
            return CGRect.zero
        }
        if rect.isNull {
            return rect
        }
        if rect.isInfinite {
            return rect
        }
        var mainWindow: UIWindow? = app.keyWindow
        if mainWindow == nil {
            mainWindow = app.windows.first
        }
        if mainWindow == nil {
            // no window ?!
            if view != nil {
                view?.convert(rect, from: nil)
            } else {
                return rect
            }
        }
        rect = mainWindow?.convert(rect, from: nil) ?? CGRect.zero
        if view == nil {
            return mainWindow?.convert(rect, to: nil) ?? CGRect.zero
        }
        if view == mainWindow {
            return rect
        }
        let toWindow = (view is UIWindow) ? (view as? UIWindow) : view?.window
        if mainWindow == nil || toWindow == nil {
            return mainWindow?.convert(rect, to: view) ?? CGRect.zero
        }
        if mainWindow == toWindow {
            return mainWindow?.convert(rect, to: view) ?? CGRect.zero
        }
        // in different window
        rect = mainWindow?.convert(rect, to: mainWindow) ?? CGRect.zero
        rect = toWindow?.convert(rect, from: mainWindow) ?? CGRect.zero
        rect = view?.convert(rect, from: toWindow) ?? CGRect.zero
        return rect
    }
}


extension UIApplication {
    
    private static let runOnce: Void = {
        TextKeyboardManager.startManager()
    }()
    
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }
}
