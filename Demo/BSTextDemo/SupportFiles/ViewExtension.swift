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
    
    /// 屏幕高度（竖向）
    @objc static let height = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    /// 屏幕宽度（竖向）
    @objc static let width = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    /// 屏幕尺寸（竖向）
    @objc static let size = CGSize(width: width, height: height)
    /// iOS系统版本号
    @objc static let deviceSystemVersion = Double(UIDevice.current.systemVersion) ?? 0
}

@inline(__always) fileprivate func hexStrToInt(str: String?) -> Int {
    
    guard let input = str else {
        return 0
    }
    
    // Int(_, radix: ) can't deal with the '0x' prefix. NSScanner can handle hex
    // with or without the '0x' prefix
    let scanner = Scanner(string: input)
    var value: Int = 0
    
    if scanner.scanInt(&value) {
        print("Decimal: \(value)")
        print("Hex: 0x\(String(value, radix: 16))")
        return value
    }
    
    return 0
}

fileprivate func hexStrToRGBA(str: String?, r: UnsafeMutablePointer<CGFloat>?, g: UnsafeMutablePointer<CGFloat>?, b: UnsafeMutablePointer<CGFloat>?, a: UnsafeMutablePointer<CGFloat>?) -> Bool {
    
    var r = r?.pointee
    var g = g?.pointee
    var b = b?.pointee
    var a = a?.pointee
    
    print("\(String(describing: r)), \(String(describing: g)), \(String(describing: b)), \(String(describing: a))")
    
    // 不符合条件，直接返回黑色
    guard var s = str?.uppercased(), s.count > 3 else {
        return false
    }
    
    let len = s.count
    
    if s.hasPrefix("#") {
        
        s = String(s[s.range(from: NSRange(1...len))!])
    } else if s.hasPrefix("0X") {
        s = String(s[s.range(from: NSRange(2...len))!])
    }
    
    let length = s.count
    
    // 不符合条件，直接返回黑色
    // RGB, RGBA, RRGGBB, RRGGBBAA
    if length != 3 && length != 4 && length != 6 && length != 8 {
        return false
    }
    
    // RGB, RGBA, RRGGBB, RRGGBBAA
    if length < 5 {
        r = CGFloat(hexStrToInt(str: String(s[s.range(from: NSRange(0...1))!]))) / 255.0
        g = CGFloat(hexStrToInt(str: String(s[s.range(from: NSRange(1...2))!]))) / 255.0
        b = CGFloat(hexStrToInt(str: String(s[s.range(from: NSRange(2...3))!]))) / 255.0
        if length == 4 {
            a = CGFloat(hexStrToInt(str: String(s[s.range(from: NSRange(3...4))!]))) / 255.0
        } else {
            a = 1
        }
    } else {
        r = CGFloat(hexStrToInt(str: String(s[s.range(from: NSRange(0...2))!]))) / 255.0
        g = CGFloat(hexStrToInt(str: String(s[s.range(from: NSRange(2...4))!]))) / 255.0
        b = CGFloat(hexStrToInt(str: String(s[s.range(from: NSRange(4...6))!]))) / 255.0
        if length == 8 {
            a = CGFloat(hexStrToInt(str: String(s[s.range(from: NSRange(6...8))!]))) / 255.0
        } else {
            a = 1
        }
    }
    return true
}

extension UIColor {
    
    @objc public class func colorWithHexString(hexString hexStr: String?) -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if hexStrToRGBA(str: hexStr, r: &r, g: &g, b: &b, a: &a) {
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
    
    @objc(colorWithHex:)
    public class func color(with hex: Int) -> UIColor {
        return UIColor(red: CGFloat((Float((hex & 0xff0000) >> 16)) / 255.0), green: CGFloat((Float((hex & 0xff00) >> 8)) / 255.0), blue: CGFloat((Float(hex & 0xff)) / 255.0), alpha: 1.0)
    }
    
    public convenience init(hex: Int) {
        self.init(red: CGFloat((Float((hex & 0xff0000) >> 16)) / 255.0), green: CGFloat((Float((hex & 0xff00) >> 8)) / 255.0), blue: CGFloat((Float(hex & 0xff)) / 255.0), alpha: 1.0)
    }
}
