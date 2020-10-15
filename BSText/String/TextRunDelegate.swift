//
//  TextRunDelegate.swift
//  BSTextDemo
//
//  Created by BlueSky on 2018/10/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import CoreText

public class TextRunDelegate: NSObject, NSCopying, NSCoding, NSSecureCoding {
    
    var userInfo: NSMutableDictionary?
    @objc public var ascent: CGFloat = 0
    @objc public var descent: CGFloat = 0
    @objc public var width: CGFloat = 0
    
    @objc public var ctRunDelegate: CTRunDelegate {
        
        get {
            // MARK: - 此处要使用本类对象，否则之后需要取出 Delegate 的 ConRef 的时候会出问题
            let extentBuffer = UnsafeMutablePointer<TextRunDelegate>.allocate(capacity: 1)
            extentBuffer.initialize(to: self)
            
            var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { (pointer) in
                
                pointer.deallocate()
                
            }, getAscent: { (pointer) -> CGFloat in
                
                let p = pointer.assumingMemoryBound(to: TextRunDelegate.self)
                return p.pointee.ascent
                
            }, getDescent: { (pointer) -> CGFloat in
                
                let p = pointer.assumingMemoryBound(to: TextRunDelegate.self)
                return p.pointee.descent
                
            }, getWidth: { (pointer) -> CGFloat in
                
                let p = pointer.assumingMemoryBound(to: TextRunDelegate.self)
                return p.pointee.width
            })
            
            return CTRunDelegateCreate(&callbacks, extentBuffer)!
        }
    }
    
    @objc public override init() {
        super.init()
    }
    
    // MARK: - NSCoding
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(Float(ascent), forKey: "ascent")
        aCoder.encode(Float(descent), forKey: "descent")
        aCoder.encode(Float(width), forKey: "width")
        aCoder.encode(userInfo, forKey: "userInfo")
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        super.init()
        ascent = CGFloat(aDecoder.decodeFloat(forKey: "ascent"))
        descent = CGFloat(aDecoder.decodeFloat(forKey: "descent"))
        width = CGFloat(aDecoder.decodeFloat(forKey: "width"))
        userInfo = aDecoder.decodeObject(forKey: "userInfo") as? NSMutableDictionary
    }
    
    // MARK: - NSCopying
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let one = TextRunDelegate()
        one.ascent = ascent
        one.descent = descent
        one.width = width
        one.userInfo = userInfo
        return one
    }
    
    // MARK: - NSSecureCoding
    @objc public static var supportsSecureCoding: Bool {
        return true
    }
}
