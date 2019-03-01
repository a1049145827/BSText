//
//  CALayerExtension.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/22.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

extension CALayer {
    
    /**
     Take snapshot without transform, image's size equals to bounds.
     */
    func snapshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, _: isOpaque, _: 0)
        let context = UIGraphicsGetCurrentContext()
        if let context = context {
            render(in: context)
        }
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /**
     Take snapshot without transform, PDF's page size equals to bounds.
     */
    func snapshotPDF() -> Data? {
        var bounds: CGRect = self.bounds
        let data = Data()
        let consumer = CGDataConsumer(data: data as! CFMutableData)
        
        guard let context = CGContext(consumer: consumer!, mediaBox: &bounds, nil) else {
            return nil
        }
        
        context.beginPDFPage(nil)
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1, y: -1)
        render(in: context)
        context.endPDFPage()
        context.closePDF()
        
        return data
    }
    
    /**
     Shortcut to set the layer's shadow
     
     @param color  Shadow Color
     @param offset Shadow offset
     @param radius Shadow radius
     */
    func setLayerShadow(_ color: UIColor?, offset: CGSize, radius: CGFloat) {
        if let CGColor = color?.cgColor {
            shadowColor = CGColor
        }
        shadowOffset = offset
        shadowRadius = radius
        shadowOpacity = 1
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
    }
    
    /**
     Remove all sublayers.
     */
    func removeAllSublayers() {
        while sublayers?.count ?? 0 > 0 {
            sublayers?.last?.removeFromSuperlayer()
        }
    }
    
    ///< Shortcut for frame.origin.x.
    var left: CGFloat {
        set(x) {
            var frame: CGRect = self.frame
            frame.origin.x = x
            self.frame = frame
        }
        get {
            return frame.origin.x
        }
    }
    
    ///< Shortcut for frame.origin.y
    var top: CGFloat {
        set(y) {
            var frame: CGRect = self.frame
            frame.origin.y = y
            self.frame = frame
        }
        get {
            return frame.origin.y
        }
    }
    
    ///< Shortcut for frame.origin.x + frame.size.width
    var right: CGFloat {
        set(`right`) {
            var frame: CGRect = self.frame
            frame.origin.x = `right` - frame.size.width
            self.frame = frame
        }
        get {
            return frame.origin.x + frame.size.width
        }
    }
    
    ///< Shortcut for frame.origin.y + frame.size.height
    var bottom: CGFloat {
        set(bottom) {
            var frame: CGRect = self.frame
            frame.origin.y = bottom - frame.size.height
            self.frame = frame
        }
        get {
            return frame.origin.y + frame.size.height
        }
    }
    
    ///< Shortcut for frame.size.width.
    var width: CGFloat {
        set(width) {
            var frame: CGRect = self.frame
            frame.size.width = width
            self.frame = frame
        }
        get {
            return frame.size.width
        }
    }
    
    ///< Shortcut for frame.size.height.
    var height: CGFloat {
        set(height) {
            var frame: CGRect = self.frame
            frame.size.height = height
            self.frame = frame
        }
        get {
            return frame.size.height
        }
    }
    
    ///< Shortcut for center.
    var center: CGPoint {
        set(center) {
            var frame: CGRect = self.frame
            frame.origin.x = center.x - frame.size.width * 0.5
            frame.origin.y = center.y - frame.size.height * 0.5
            self.frame = frame
        }
        get {
            return CGPoint(x: frame.origin.x + frame.size.width * 0.5, y: frame.origin.y + frame.size.height * 0.5)
        }
    }
    
    ///< Shortcut for center.x
    var centerX: CGFloat {
        set(centerX) {
            var frame: CGRect = self.frame
            frame.origin.x = centerX - frame.size.width * 0.5
            self.frame = frame
        }
        get {
            return frame.origin.x + frame.size.width * 0.5
        }
    }
    
    ///< Shortcut for center.y
    var centerY: CGFloat {
        set(centerY) {
            var frame: CGRect = self.frame
            frame.origin.y = centerY - frame.size.height * 0.5
            self.frame = frame
        }
        get {
            return frame.origin.y + frame.size.height * 0.5
        }
    }
    
    ///< Shortcut for frame.origin.
    var origin: CGPoint {
        set(origin) {
            var frame: CGRect = self.frame
            frame.origin = origin
            self.frame = frame
        }
        get {
            return frame.origin
        }
    }
    
    ///< Shortcut for frame.size.
    var size: CGSize {
        set(size) {
            var frame: CGRect = self.frame
            frame.size = size
            self.frame = frame
        }
        get {
            return frame.size
        }
    }
    
    ///< key path "tranform.rotation"
    var transformRotation: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.rotation")
        }
        get {
            let v = value(forKeyPath: "transform.rotation") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    ///< key path "tranform.rotation.x"
    var transformRotationX: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.rotation.x")
        }
        get {
            let v = value(forKeyPath: "transform.rotation.x") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    ///< key path "tranform.rotation.y"
    var transformRotationY: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.rotation.y")
        }
        get {
            let v = value(forKeyPath: "transform.rotation.y") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    ///< key path "tranform.rotation.z"
    var transformRotationZ: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.rotation.z")
        }
        get {
            let v = value(forKeyPath: "transform.rotation.z") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    ///< key path "tranform.scale"
    var transformScale: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.scale")
        }
        get {
            let v = value(forKeyPath: "transform.scale") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    ///< key path "tranform.scale.x"
    var transformScaleX: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.scale.x")
        }
        get {
            let v = value(forKeyPath: "transform.scale.x") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    ///< key path "tranform.scale.y"
    var transformScaleY: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.scale.y")
        }
        get {
            let v = value(forKeyPath: "transform.scale.y") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    ///< key path "tranform.scale.z"
    var transformScaleZ: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.scale.z")
        }
        get {
            let v = value(forKeyPath: "transform.scale.z") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    
    ///< key path "tranform.translation.x"
    var transformTranslationX: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.translation.x")
        }
        get {
            let v = value(forKeyPath: "transform.translation.x") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    ///< key path "tranform.translation.y"
    var transformTranslationY: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.translation.y")
        }
        get {
            let v = value(forKeyPath: "transform.translation.y") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    ///< key path "tranform.translation.z"
    var transformTranslationZ: CGFloat {
        set(v) {
            setValue(NSNumber(value: Float(v)), forKeyPath: "transform.translation.z")
        }
        get {
            let v = value(forKeyPath: "transform.translation.z") as? NSNumber
            return CGFloat(v?.doubleValue ?? 0)
        }
    }
    
    /**
     Shortcut for transform.m34, -1/1000 is a good value.
     It should be set before other transform shortcut.
     */
    var transformDepth: CGFloat {
        set(v) {
            var d: CATransform3D = transform
            d.m34 = v
            transform = d
        }
        get {
            return transform.m34
        }
    }
    
    /**
     Add a fade animation to layer's contents when the contents is changed.
     
     @param duration Animation duration
     @param curve    Animation curve.
     */
    func addFadeAnimation(withDuration duration: TimeInterval, curve: UIView.AnimationCurve) {
        if duration <= 0 {
            return
        }
        
        var mediaFunction: CAMediaTimingFunctionName
        switch curve {
        case .easeInOut:
            mediaFunction = CAMediaTimingFunctionName.easeOut
        case .easeIn:
            mediaFunction = CAMediaTimingFunctionName.easeIn
        case .easeOut:
            mediaFunction = CAMediaTimingFunctionName.easeInEaseOut
        case .linear:
            mediaFunction = CAMediaTimingFunctionName.linear
        default:
            mediaFunction = CAMediaTimingFunctionName.linear
        }
        
        let transition = CATransition()
        transition.duration = CFTimeInterval(duration)
        transition.timingFunction = CAMediaTimingFunction(name: mediaFunction)
        transition.type = .fade
        add(transition, forKey: "bstext.fade")
    }
    
    /**
     Cancel fade animation which is added with "-addFadeAnimationWithDuration:curve:".
     */
    func removePreviousFadeAnimation() {
        removeAnimation(forKey: "bstext.fade")
    }
}
