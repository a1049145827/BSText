//
//  UIPasteboardExtension.swift
//  BSText
//
//  Created by BlueSky on 2018/11/8.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import MobileCoreServices

#if canImport(YYImage)
import YYImage
#endif

/**
 Extend UIPasteboard to support image and attributed string.
 */
extension UIPasteboard {
    
    @objc public static let UTTypeAttributedString = "com.BlueSky.PasteboardAttributedString"
    @objc public static let UTTypeWEBP = "com.google.webp"
    
    /*/< PNG file data */
    @objc public var bs_PNGData: Data? {
        set {
            if let aData = newValue {
                setData(aData, forPasteboardType: kUTTypePNG as String)
            }
        }
        get {
            return data(forPasteboardType: kUTTypePNG as String)
        }
    }
    
    /*/< JPEG file data */
    @objc public var bs_JPEGData: Data? {
        set {
            if let aData = newValue {
                setData(aData, forPasteboardType: kUTTypeJPEG as String)
            }
        }
        get {
            return data(forPasteboardType: kUTTypeJPEG as String)
        }
    }
    
    /*/< GIF file data */
    @objc public var bs_GIFData: Data? {
        set {
            if let aData = newValue {
                setData(aData, forPasteboardType: kUTTypeGIF as String)
            }
        }
        get {
            return data(forPasteboardType: kUTTypeGIF as String)
        }
    }
    
    /*/< WebP file data */
    @objc public var bs_WEBPData: Data? {
        set {
            if let aData = newValue {
                setData(aData, forPasteboardType: UIPasteboard.UTTypeWEBP)
            }
        }
        get {
            return data(forPasteboardType: UIPasteboard.UTTypeWEBP)
        }
    }
    
    /*/< image file data */
    @objc public var bs_ImageData: Data? {
        set {
            if let aData = newValue {
                setData(aData, forPasteboardType: kUTTypeImage as String)
            }
        }
        get {
            return data(forPasteboardType: kUTTypeImage as String)
        }
    }
    
    /// Attributed string,
    /// Set this attributed will also set the string property which is copy from the attributed string.
    /// If the attributed string contains one or more image, it will also set the `images` property.
    @objc public var bs_AttributedString: NSAttributedString? {
        
        set {
            string = newValue?.bs_plainText(for: NSRange(location: 0, length: newValue!.length))
            
            if let data = newValue?.bs_archiveToData() {
                
                let item = [UIPasteboard.UTTypeAttributedString: data]
                
                self.addItems([item])
            }
            
            newValue?.enumerateAttribute(NSAttributedString.Key(rawValue: TextAttribute.textAttachmentAttributeName), in: NSRange(location: 0, length: newValue!.length), options: .longestEffectiveRangeNotRequired, using: { atta, range, stop in
                
                guard let attachment = atta as? TextAttachment else {
                    return
                }
                
                // save image
                var simpleImage: UIImage? = nil
                if (attachment.content is UIImage) {
                    simpleImage = attachment.content as? UIImage
                } else if (attachment.content is UIImageView) {
                    simpleImage = (attachment.content as? UIImageView)?.image
                }

                if let anImage = simpleImage {
                    let item = ["com.apple.uikit.image": anImage]
                    self.addItems([item])
                }
                
                #if canImport(YYImage)
                // save animated image
                if (attachment.content is UIImageView) {
                    let imageView = attachment.content as! UIImageView
                    
                    let image: UIImage? = imageView.image
                    if (image is YYImage) {
                        
                        if let data = image?.value(forKey: "animatedImageData") as? Data {
                            let type = image?.value(forKey: "animatedImageType") as? UInt ?? 0
                            switch type {
                            case YYImageType.GIF.rawValue:
                                let s = kUTTypeGIF as String
                                let item = [s: data]
                                addItems([item])
                            case YYImageType.PNG.rawValue:
                                // APNG
                                let s = kUTTypePNG as String
                                let item = [s: data]
                                addItems([item])
                            case YYImageType.webP.rawValue:
                                let s = UIPasteboard.UTTypeWEBP as String
                                let item = [s: data]
                                addItems([item])
                            default:
                                break
                            }
                        }
                    }
                }
                #endif
            })
        }
        get {
            for item in items {
                if let data = item[UIPasteboard.UTTypeAttributedString] as? Data {
                    return NSAttributedString.bs_unarchive(from: data)
                }
            }
            return nil
        }
    }
}
