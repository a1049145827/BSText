//
//  BSTextAttachmentExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText
import YYImage

class BSTextAttachmentExample: UIViewController, UIGestureRecognizerDelegate {
    
    private let label = MyLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        BSTextExampleHelper.addDebugOption(to: self)
        
        
        let text = NSMutableAttributedString()
        let font = UIFont.systemFont(ofSize: 16)
        
        do {
            let title = "This is UIImage attachment:"
            text.append(NSAttributedString(string: title, attributes: nil))
            
            var image = UIImage(named: "dribbble64_imageio")
            if let CGImage = image?.cgImage {
                image = UIImage(cgImage: CGImage, scale: 2, orientation: .up)
            }
            let attachText = NSMutableAttributedString.bs_attachmentString(with: image, contentMode: UIView.ContentMode.center, attachmentSize: image!.size, alignTo: font, alignment: TextVerticalAlignment.center)
            text.append(attachText!)
            text.append(NSAttributedString(string: "\n", attributes: nil))
        }
        
        do {
            let title = "This is UIView attachment: "
            text.append(NSAttributedString(string: title, attributes: nil))
            
            let switcher = UISwitch()
            switcher.sizeToFit()
            
            let attachText = NSMutableAttributedString.bs_attachmentString(with: switcher, contentMode: UIView.ContentMode.center, attachmentSize: switcher.size, alignTo: font, alignment: TextVerticalAlignment.center)
            text.append(attachText!)
            text.append(NSAttributedString(string: "\n", attributes: nil))
        }
        
        do {
            
            let title = "This is Animated Image attachment:"
            text.append(NSAttributedString(string: title, attributes: nil))
            
            let names = ["001@2x", "022@2x", "019@2x", "056@2x", "085@2x"]
            for name: String in names {
                let path = Bundle.main.path(forResource: name, ofType: "gif", inDirectory: "EmoticonQQ.bundle")
                let data = NSData(contentsOfFile: path!) as Data?
                var image: YYImage? = nil
                if let data = data {
                    image = YYImage(data: data, scale: 2)
                }
                image?.preloadAllAnimatedImageFrames = true
                var imageView: YYAnimatedImageView? = nil
                if let image = image {
                    imageView = YYAnimatedImageView(image: image)
                }
                
                let attachText = NSMutableAttributedString.bs_attachmentString(with: imageView, contentMode: UIView.ContentMode.center, attachmentSize: imageView!.size, alignTo: font, alignment: TextVerticalAlignment.center)
                text.append(attachText!)
            }
            
            let image = YYImage(named: "pia")
            image?.preloadAllAnimatedImageFrames = true
            var imageView: YYAnimatedImageView? = nil
            if let image = image {
                imageView = YYAnimatedImageView(image: image)
            }
            imageView?.autoPlayAnimatedImage = false
            imageView?.startAnimating()
            
            let attachText = NSMutableAttributedString.bs_attachmentString(with: imageView, contentMode: UIView.ContentMode.center, attachmentSize: imageView!.size, alignTo: font, alignment: TextVerticalAlignment.bottom)
            text.append(attachText!)
            
            text.append(NSAttributedString(string: "\n", attributes: nil))
        }
        
        
        text.bs_font = font
        
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        label.textVerticalAlignment = TextVerticalAlignment.top
        label.size = CGSize(width: 260, height: 260)
        label.center = CGPoint(x: view.width / 2, y: view.height / 2)
        label.attributedText = text
        addSeeMoreButton()
        view.addSubview(label)
        
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor(red: 0.000, green: 0.463, blue: 1.000, alpha: 1.000).cgColor
        
        
        weak var wlabel = label
        let dot: UIView? = newDotView()
        dot?.center = CGPoint(x: label.width, y: label.height)
        dot?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        if let dot = dot {
            label.addSubview(dot)
        }
        let gesture = BSGestureRecognizer()
        gesture.targetView = label
        gesture.action = { gesture, state in
            if state != BSGestureRecognizerState.moved {
                return
            }
            let width = gesture!.currentPoint.x
            let height = gesture!.currentPoint.y
            wlabel?.width = width < 30 ? 30 : width
            wlabel?.height = height < 30 ? 30 : height
        }
        gesture.delegate = self
        
        dot?.addGestureRecognizer(gesture)
    }
    
    func addSeeMoreButton() {
        weak var _self = self
        let text = NSMutableAttributedString(string: "...more")
        
        let hi = TextHighlight()
        hi.color = UIColor(red: 0.578, green: 0.790, blue: 1.000, alpha: 1.000)
        hi.tapAction = { containerView, text, range, rect in
            _self?.label.sizeToFit()
        }
        
        text.bs_set(color: UIColor(red: 0.000, green: 0.449, blue: 1.000, alpha: 1.000), range: ((text.string as NSString?)?.range(of: "more"))!)
        text.bs_set(textHighlight: hi, range: ((text.string as NSString?)?.range(of: "more"))!)
        text.bs_font = self.label.font
        
        let seeMore = BSLabel()
        seeMore.attributedText = text
        seeMore.sizeToFit()
        
        let truncationToken = NSAttributedString.bs_attachmentString(with: seeMore, contentMode: UIView.ContentMode.center, attachmentSize: seeMore.size, alignTo: text.bs_font, alignment: TextVerticalAlignment.center)
        self.label.truncationToken = truncationToken
    }
    
    func newDotView() -> UIView? {
        let view = UIView()
        view.size = CGSize(width: 50, height: 50)
        
        let dot = UIView()
        dot.size = CGSize(width: 10, height: 10)
        dot.backgroundColor = UIColor(red: 0.000, green: 0.463, blue: 1.000, alpha: 1.000)
        dot.clipsToBounds = true
        dot.layer.cornerRadius = dot.height / 2
        dot.center = CGPoint(x: view.width / 2, y: view.height / 2)
        view.addSubview(dot)
        
        return view
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let p: CGPoint = gestureRecognizer.location(in: label)
        if p.x < label.width - 20 {
            return false
        }
        if p.y < label.height - 20 {
            return false
        }
        return true
    }
}
