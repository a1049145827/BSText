//
//  ViewExtension.swift
//  BSText
//
//  Created by BlueSky on 2018/10/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

extension UIView {
    
    /**
     Shortcut to set the view.layer's shadow
     
     @param color  Shadow Color
     @param offset Shadow offset
     @param radius Shadow radius
     */
    @objc func setLayerShadow(_ color: UIColor?, offset: CGSize, radius: CGFloat) {
        if let aColor = color?.cgColor {
            layer.shadowColor = aColor
        }
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    /**
     Remove all subviews.
     
     @warning Never call this method inside your view's drawRect: method.
     */
    @objc func removeAllSubviews() {
        //[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        while subviews.count > 0 {
            subviews.last?.removeFromSuperview()
        }
    }
    
    /**
     Returns the view's view controller (may be nil).
     */
    @objc var viewController: UIViewController? {
        var view: UIView? = self
        while view != nil {
            let nextResponder = view?.next
            if (nextResponder is UIViewController) {
                return nextResponder as? UIViewController
            }
            view = view?.superview
        }
        return nil
    }
    
    ///< Shortcut for frame.origin.x.
    @objc var left: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return frame.origin.x
        }
    }
    
    ///< Shortcut for frame.origin.y
    @objc var top: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return frame.origin.y
        }
    }
    
    ///< Shortcut for frame.origin.x + frame.size.width
    @objc var right: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
        get {
            return frame.origin.x + frame.size.width
        }
    }
    
    ///< Shortcut for frame.origin.y + frame.size.height
    @objc var bottom: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
        get {
            return frame.origin.y + frame.size.height
        }
    }
    
    ///< Shortcut for frame.size.width.
    @objc var width: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return frame.size.width
        }
    }
    
    ///< Shortcut for frame.size.height.
    @objc var height: CGFloat {
        set {
            var frame: CGRect = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get {
            return frame.size.height
        }
    }
    
    ///< Shortcut for center.x
    @objc var centerX: CGFloat {
        set {
            center = CGPoint(x: newValue, y: center.y)
        }
        get {
            return center.x
        }
    }
    
    ///< Shortcut for center.y
    @objc var centerY: CGFloat {
        set {
            center = CGPoint(x: center.x, y: newValue)
        }
        get {
            return center.y
        }
    }
    
    ///< Shortcut for frame.origin.
    @objc var origin: CGPoint {
        set {
            var frame: CGRect = self.frame
            frame.origin = newValue
            self.frame = frame
        }
        get {
            return frame.origin
        }
    }
    
    ///< Shortcut for frame.size.
    @objc var size: CGSize {
        set {
            var frame: CGRect = self.frame
            frame.size = newValue
            self.frame = frame
        }
        get {
            return frame.size
        }
    }
}

class Screen: NSObject {
    
    /// Screen Height With Portrait
    @objc static let height = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    /// Screen Width With Portrait
    @objc static let width = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    /// Screen Size With Portrait
    @objc static let size = CGSize(width: width, height: height)
}

/// Parse Hex String To RGBA Value
///
/// - Parameters:
///   - str: Hex String
///   - r: Memory Address for a CGFloat variable to receive the red value
///   - g: Memory Address for a CGFloat variable to receive the green value
///   - b: Memory Address for a CGFloat variable to receive the blue value
///   - a: Memory Address for a CGFloat variable to receive the alpha value
/// - Returns: Parse is success or not
fileprivate func hexStrToRGBA(str: String?, r: UnsafeMutablePointer<CGFloat>?, g: UnsafeMutablePointer<CGFloat>?, b: UnsafeMutablePointer<CGFloat>?, a: UnsafeMutablePointer<CGFloat>?) -> Bool {
    
    guard var s = str?.uppercased(), s.length > 3 else {
        // Not a Hex String
        return false
    }
    
    if s.hasPrefix("#") {
        s = s.subString(start: 1, end: s.length)
    } else if s.hasPrefix("0X") {
        s = s.subString(start: 2, end: s.length)
    }
    
    let length = s.length
    
    // RGB, RGBA, RRGGBB, RRGGBBAA
    if length != 3 && length != 4 && length != 6 && length != 8 {
        // Not a Hex String
        return false
    }
    
    // RGB, RGBA, RRGGBB, RRGGBBAA
    if length < 5 {
        r?.pointee = CGFloat((s.subString(start: 0, end: 1) + s.subString(start: 0, end: 1)).hexToInt()) / 255.0
        g?.pointee = CGFloat((s.subString(start: 1, end: 2) + s.subString(start: 1, end: 2)).hexToInt()) / 255.0
        b?.pointee = CGFloat((s.subString(start: 2, end: 3) + s.subString(start: 2, end: 3)).hexToInt()) / 255.0
        if length == 4 {
            a?.pointee = CGFloat((s.subString(start: 3, end: 4) + s.subString(start: 3, end: 4)).hexToInt()) / 255.0
        } else {
            a?.pointee = 1
        }
    } else {
        r?.pointee = CGFloat(s.subString(start: 0, end: 2).hexToInt()) / 255.0
        g?.pointee = CGFloat(s.subString(start: 2, end: 4).hexToInt()) / 255.0
        b?.pointee = CGFloat(s.subString(start: 4, end: 6).hexToInt()) / 255.0
        if length == 8 {
            a?.pointee = CGFloat(s.subString(start: 6, end: 8).hexToInt()) / 255.0
        } else {
            a?.pointee = 1
        }
    }
    
    return true
}

extension UIColor {
    
    /// Hex String convert to UIColor
    ///
    /// - Parameter hexString: Hex String
    @objc(colorWithHexString:)
    public class func colorWith(hexString: String?) -> UIColor {
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        
        if hexStrToRGBA(str: hexString, r: &r, g: &g, b: &b, a: &a) {
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
        return UIColor.black
    }
    
    @objc func color(byAdd add: UIColor?, blendMode: CGBlendMode) -> UIColor? {
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        var pixel = [0]
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.setFillColor(self.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        context?.setBlendMode(blendMode)
        context?.setFillColor(self.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        
        return UIColor(red: CGFloat(pixel[0]) / 255.0, green: CGFloat(pixel[1]) / 255.0, blue: CGFloat(pixel[2]) / 255.0, alpha: CGFloat(pixel[3]) / 255.0)
    }
    
    /// Hex Value convert to UIColor
    ///
    /// - Parameter hex: Hex Value
    @objc(colorWithHex:)
    public class func color(with hex: Int) -> UIColor {
        return UIColor(red: CGFloat((Float((hex & 0xff0000) >> 16)) / 255.0), green: CGFloat((Float((hex & 0xff00) >> 8)) / 255.0), blue: CGFloat((Float(hex & 0xff)) / 255.0), alpha: 1.0)
    }
    
    /// Hex Value convert to UIColor
    ///
    /// - Parameter hex: Hex Value
    public convenience init(hex: Int) {
        self.init(red: CGFloat((Float((hex & 0xff0000) >> 16)) / 255.0), green: CGFloat((Float((hex & 0xff00) >> 8)) / 255.0), blue: CGFloat((Float(hex & 0xff)) / 255.0), alpha: 1.0)
    }
}
