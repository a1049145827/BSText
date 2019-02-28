//
//  TextArchiver.swift
//  BSText
//
//  Created by BlueSky on 2018/10/25.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import CoreImage

/**
 A subclass of `NSKeyedArchiver` which implement `NSKeyedArchiverDelegate` protocol.
 
 The archiver can encode the object which contains
 CGColor/CGImage/CTRunDelegate/.. (such as NSAttributedString).
 */
public class TextArchiver: NSKeyedArchiver, NSKeyedArchiverDelegate {
    
    override public class func archivedData(withRootObject rootObject: Any) -> Data {
        
        var data: Data
        
        if #available(iOS 11.0, *) {
            let archiver = TextArchiver(requiringSecureCoding: false)
            archiver.encodeRootObject(rootObject)

            data = archiver.encodedData
        } else {
            let d = NSMutableData()
            let archiver = TextArchiver(forWritingWith: d)
            archiver.encodeRootObject(rootObject)
            archiver.finishEncoding()
            
            data = d as Data
        }
        
        return data
    }
    
    override public class func archiveRootObject(_ rootObject: Any, toFile path: String) -> Bool {
        
        let data = self.archivedData(withRootObject: rootObject)
        
        var success = false
        
        do {
            try data.write(to: URL(fileURLWithPath: path), options: .atomicWrite)
            success = true
        } catch let err {
            print(err)
        }
        
        return success
    }
    
    @available(iOS, introduced: 10.0, deprecated: 12.0, message: "Use -initRequiringSecureCoding: instead")
    private override init() {
        super.init()
    }
    
    @available(iOS, introduced: 2.0, deprecated: 12.0, message: "Use -initRequiringSecureCoding: instead")
    private override init(forWritingWith data: NSMutableData) {
        super.init(forWritingWith: data)
        delegate = self
    }
    
    @available(iOS 11.0, *)
    private override init(requiringSecureCoding requiresSecureCoding: Bool) {
        super.init(requiringSecureCoding: requiresSecureCoding)
        delegate = self
    }
    
    // MARK: - NSKeyedArchiverDelegate
    public func archiver(_ archiver: NSKeyedArchiver, willEncode object: Any) -> Any? {
        
        let typeID = CFGetTypeID(object as CFTypeRef)
        
        if typeID == CTRunDelegateGetTypeID() {
            
            let runDelegate = object as! CTRunDelegate
            let ref = CTRunDelegateGetRefCon(runDelegate)
            
            // UnsafeMutableRawPointer 需要用 load 或 (用 assumingMemoryBound 将 UnsafeMutableRawPointer 转为 UnsafeMutablePointer 然后取其 pointee), 不能用 unsafeBitCast
            // 错误示例：unsafeBitCast(ref, to: TextRunDelegate.self) 会导致 Crash
//            let p = ref.assumingMemoryBound(to: TextRunDelegate.self)
//            return p.pointee
            return ref.load(as: TextRunDelegate.self)
            
        } else if typeID == CTRubyAnnotationGetTypeID() {
            
            let ctRuby = object as! CTRubyAnnotation
            let ruby = TextRubyAnnotation.ruby(with: ctRuby)
            
            return ruby
            
        } else if typeID == CGColor.typeID {
            
            let anObject = object as! CGColor
            return BSCGColor(cgColor: anObject)
            
        } else if typeID == CGImage.typeID {
            
            let anObject = object as! CGImage
            return BSCGImage(cgImage: anObject)
        }
        
        return object
    }
}

// MARK: - 临时用来解决粘贴gif图片的问题（rundelegate会提前释放），后续需要优化，如何保证CTRunDelegate的生命周期
var k_sharedDelegate = [Int: CTRunDelegate]()

/**
 A subclass of `NSKeyedUnarchiver` which implement `NSKeyedUnarchiverDelegate`
 protocol. The unarchiver can decode the data which is encoded by
 `TextArchiver` or `NSKeyedArchiver`.
 */
public class TextUnarchiver: NSKeyedUnarchiver, NSKeyedUnarchiverDelegate {
    
    override public class func unarchiveObject(with data: Data) -> Any? {
        if data.count == 0 {
            return nil
        }
        
        // MARK: - 临时修复 CTDelegate 的内存引用问题
        if k_sharedDelegate.count > 0 {
            TextUnarchiver.clearRef()
        }
        
        var unarchiver: TextUnarchiver? = nil
        
        if #available(iOS 11.0, *) {
            do {
                unarchiver = try TextUnarchiver.init(forReadingFrom: data)
                unarchiver?.requiresSecureCoding = false
            } catch let err {
                print(err)
            }
        } else {
            unarchiver = TextUnarchiver.init(forReadingWith: data)
        }
        
        return unarchiver?.decodeObject()
    }
    
    override public class func unarchiveObject(withFile path: String) -> Any? {
        let data = NSData(contentsOfFile: path) as Data?
        if let aData = data {
            return self.unarchiveObject(with: aData)
        }
        return nil
    }
    
    @available(iOS, introduced: 2.0, deprecated: 12.0, message: "Use -initForReadingFromData:error: instead")
    override private init() {
        super.init()
        delegate = self
    }
    
    @available(iOS, introduced: 2.0, deprecated: 12.0, message: "Use -initForReadingFromData:error: instead")
    override private init(forReadingWith data: Data) {
        super.init(forReadingWith: data)
        delegate = self
    }
    
    @available(iOS 11.0, *)
    override private init(forReadingFrom data: Data) throws {
        try super.init(forReadingFrom: data)
        
        delegate = self
    }
    
    // MARK: - NSKeyedUnarchiverDelegate
    public func unarchiver(_ unarchiver: NSKeyedUnarchiver, didDecode object: Any?) -> Any? {
        
        guard let obj = object else {
            return nil
        }
        
        if type(of: obj) == TextRunDelegate.self {
            
            let runDelegate = obj as! TextRunDelegate
            let ct = runDelegate.ctRunDelegate
            // MARK: - 这里有强引用，为什么不强引用它会提前释放？
            k_sharedDelegate[k_sharedDelegate.count] = ct
            
            return ct
            
        } else if type(of: obj) == TextRubyAnnotation.self {
            
            let ruby = object as! TextRubyAnnotation
            let ct = ruby.ctRubyAnnotation
            
            return ct
            
        } else if type(of: obj) == BSCGColor.self {
            
            let color = obj as! BSCGColor
            return color.cgColor
            
        } else if type(of: obj) == BSCGImage.self {
            
            let image = obj as! BSCGImage
            return image.cgImage
        }
        
        return object
    }
    
    private class func clearRef() -> Void {
        
        k_sharedDelegate = [Int: CTRunDelegate]()
    }
}

/**
 A wrapper for CGColorRef. Used for Archive/Unarchive/Copy.
 */
@objc(_TtC6BSTextP33_C72E39273DDC44DAA5EC7067D26023719BSCGColor)
fileprivate final class BSCGColor: NSObject, NSCopying, NSCoding, NSSecureCoding {
    
    var cgColor: CGColor?
    
    override init() {
        super.init()
    }
    
    @objc fileprivate convenience init(cgColor CGColor: CGColor?) {
        self.init()
        self.cgColor = CGColor
    }
    
    // MARK: - NSCopying
    @objc func copy(with zone: NSZone? = nil) -> Any {
        let c = BSCGColor(cgColor: cgColor)
        return c
    }
    
    // MARK: - NSCoding
    @objc func encode(with aCoder: NSCoder) {
        var color: UIColor? = nil
        if let aColor = cgColor {
            color = UIColor(cgColor: aColor)
        }
        aCoder.encode(color, forKey: "color")
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        super.init()
        let color = aDecoder.decodeObject(forKey: "color") as! UIColor?
        self.cgColor = color?.cgColor
    }
    
    // MARK: - NSSecureCoding
    @objc public static var supportsSecureCoding: Bool {
        return true
    }
}

/**
 A wrapper for CGImage. Used for Archive/Unarchive/Copy.
 */
@objc(_TtC6BSTextP33_C72E39273DDC44DAA5EC7067D26023719BSCGImage)
fileprivate final class BSCGImage: NSObject, NSCoding, NSCopying, NSSecureCoding {
    
    var cgImage: CGImage?
    
    override init() {
        super.init()
    }
    
    @objc fileprivate convenience init(cgImage: CGImage?) {
        self.init()
        self.cgImage = cgImage
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let image = BSCGImage()
        image.cgImage = cgImage
        return image
    }
    
    // MARK: - NSCoding
    public func encode(with aCoder: NSCoder) {
        var image: UIImage? = nil
        if let anImage = cgImage {
            image = UIImage(cgImage: anImage)
        }
        aCoder.encode(image, forKey: "image")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        let image = aDecoder.decodeObject(forKey: "image") as? UIImage
        self.cgImage = image?.cgImage
    }
    
    // MARK: - NSSecureCoding
    @objc public static var supportsSecureCoding: Bool {
        return true
    }
}
