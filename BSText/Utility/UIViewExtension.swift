//
//  UIViewExtension.swift
//  BSText
//
//  Created by BlueSky on 2018/10/22.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

public extension UIView {
    
    @objc var bs_viewController: UIViewController? {
        get {
            var view: UIView? = self
            while (view != nil) {
                let nextResponder = view?.next
                if (nextResponder is UIViewController) {
                    return nextResponder as? UIViewController
                }
                view = view?.superview
            }
            return nil
        }
    }
    
    @objc var bs_visibleAlpha: CGFloat {
        get {
            if (self is UIWindow) {
                if isHidden {
                    return 0
                }
                return self.alpha
            }
            if !(window != nil) {
                return 0
            }
            var alpha: CGFloat = 1
            var v: UIView? = self
            while v != nil {
                if v!.isHidden {
                    alpha = 0
                    break
                }
                alpha *= v!.alpha
                v = v!.superview
            }
            return alpha
        }
    }
    
    @objc func bs_convertPoint(_ point: CGPoint, toViewOrWindow view: UIView?) -> CGPoint {
        var point = point
        if view == nil {
            if (self is UIWindow) {
                return (self as? UIWindow)?.convert(point, to: nil) ?? CGPoint.zero
            } else {
                return convert(point, to: nil)
            }
        }
        let from: UIWindow? = (self is UIWindow) ? (self as! UIWindow) : window
        let to = (view is UIWindow) ? (view as? UIWindow) : view?.window
        if (from == nil || to == nil) || (from == to) {
            return convert(point, to: view)
        }
        point = convert(point, to: from)
        point = to?.convert(point, from: from) ?? CGPoint.zero
        point = view?.convert(point, from: to) ?? CGPoint.zero
        return point
    }
    
    @objc func bs_convertPoint(_ point: CGPoint, fromViewOrWindow view: UIView?) -> CGPoint {
        var point = point
        if view == nil {
            if (self is UIWindow) {
                return (self as? UIWindow)?.convert(point, from: nil) ?? CGPoint.zero
            } else {
                return convert(point, from: nil)
            }
        }
        let from = (view is UIWindow) ? (view as? UIWindow) : view?.window
        let to: UIWindow? = (self is UIWindow) ? (self as! UIWindow) : window
        if (from == nil || to == nil) || (from == to) {
            return convert(point, from: view)
        }
        point = from?.convert(point, from: view) ?? CGPoint.zero
        point = to?.convert(point, from: from) ?? CGPoint.zero
        point = convert(point, from: to)
        return point
    }
    
    @objc func bs_convertRect(_ rect: CGRect, toViewOrWindow view: UIView?) -> CGRect {
        var rect = rect
        if view == nil {
            if (self is UIWindow) {
                return (self as? UIWindow)?.convert(rect, to: nil) ?? CGRect.zero
            } else {
                return convert(rect, to: nil)
            }
        }
        let from: UIWindow? = (self is UIWindow) ? (self as! UIWindow) : window
        let to = (view is UIWindow) ? (view as? UIWindow) : view?.window
        if from == nil || to == nil {
            return convert(rect, to: view)
        }
        if from == to {
            return convert(rect, to: view)
        }
        rect = convert(rect, to: from)
        rect = to?.convert(rect, from: from) ?? CGRect.zero
        rect = view?.convert(rect, from: to) ?? CGRect.zero
        return rect
    }
    
    @objc func bs_convertRect(_ rect: CGRect, fromViewOrWindow view: UIView?) -> CGRect {
        var rect = rect
        if view == nil {
            if (self is UIWindow) {
                return (self as? UIWindow)?.convert(rect, from: nil) ?? CGRect.zero
            } else {
                return convert(rect, from: nil)
            }
        }
        let from = (view is UIWindow) ? (view as? UIWindow) : view?.window
        let to: UIWindow? = (self is UIWindow) ? (self as! UIWindow) : window
        if (from == nil || to == nil) || (from == to) {
            return convert(rect, from: view)
        }
        rect = from?.convert(rect, from: view) ?? CGRect.zero
        rect = to?.convert(rect, from: from) ?? CGRect.zero
        rect = convert(rect, from: to)
        return rect
    }
}
