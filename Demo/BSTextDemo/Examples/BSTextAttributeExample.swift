//
//  BSTextAttributeExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText
import YYImage
import YYWebImage

class BSTextAttributeExample: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        weak var _self = self
        BSTextExampleHelper.addDebugOption(to: self)
        
        let text = NSMutableAttributedString()
        
        do {
            let one = NSMutableAttributedString(string: "Shadow")
            one.bs_font = UIFont.boldSystemFont(ofSize: 30)
            one.bs_color = UIColor.white
            let shadow = TextShadow()
            shadow.color = UIColor(white: 0.000, alpha: 0.490)
            shadow.offset = CGSize(width: 0, height: 1)
            shadow.radius = 5
            one.bs_textShadow = shadow
            text.append(one)
            text.append(padding())
        }
        
        do {
            let one = NSMutableAttributedString(string: "Inner Shadow")
            one.bs_font = UIFont.boldSystemFont(ofSize: 30)
            one.bs_color = UIColor.white
            let shadow = TextShadow()
            shadow.color = UIColor(white: 0.000, alpha: 0.40)
            shadow.offset = CGSize(width: 0, height: 1)
            shadow.radius = 1
            one.bs_textInnerShadow = shadow
            text.append(one)
            text.append(padding())
        }
        
        do {
            let one = NSMutableAttributedString(string: "Multiple Shadows")
            one.bs_font = UIFont.boldSystemFont(ofSize: 30)
            one.bs_color = UIColor(red: 1.000, green: 0.795, blue: 0.014, alpha: 1.000)
            
            let shadow = TextShadow()
            shadow.color = UIColor(white: 0.000, alpha: 0.20)
            shadow.offset = CGSize(width: 0, height: -1)
            shadow.radius = 1.5
            let subShadow = TextShadow()
            subShadow.color = UIColor(white: 1, alpha: 0.99)
            subShadow.offset = CGSize(width: 0, height: 1)
            subShadow.radius = 1.5
            shadow.subShadow = subShadow
            one.bs_textShadow = shadow
            
            let innerShadow = TextShadow()
            innerShadow.color = UIColor(red: 0.851, green: 0.311, blue: 0.000, alpha: 0.780)
            innerShadow.offset = CGSize(width: 0, height: 1)
            innerShadow.radius = 1
            one.bs_textInnerShadow = innerShadow
            
            text.append(one)
            text.append(padding())
        }
        
        do {
            let one = NSMutableAttributedString(string: "Background Image")
            one.bs_font = UIFont.boldSystemFont(ofSize: 30)
            one.bs_color = UIColor(red: 1.000, green: 0.795, blue: 0.014, alpha: 1.000)
            
            let size = CGSize(width: 20, height: 20)
            let background = UIImage.yy_image(with: size, draw: { context in
                let c0 = UIColor(red: 0.054, green: 0.879, blue: 0.000, alpha: 1.000)
                let c1 = UIColor(red: 0.869, green: 1.000, blue: 0.030, alpha: 1.000)
                c0.setFill()
                context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                c1.setStroke()
                context.setLineWidth(2)
                var i: CGFloat = 0
                while i < size.width * 2 {
                    context.move(to: CGPoint(x: i, y: -2))
                    context.addLine(to: CGPoint(x: i - size.height, y: size.height + 2))
                    i += 4
                }
                context.strokePath()
            })
            one.bs_color = UIColor(patternImage: background!)
            
            text.append(one)
            text.append(padding())
        }
        
        do {
            let one = NSMutableAttributedString(string: "Border")
            one.bs_font = UIFont.boldSystemFont(ofSize: 30)
            one.bs_color = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)
            
            let border = TextBorder()
            border.strokeColor = UIColor(red: 1.000, green: 0.029, blue: 0.651, alpha: 1.000)
            border.strokeWidth = 3
            border.lineStyle = TextLineStyle.patternCircleDot
            border.cornerRadius = 3
            border.insets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -4)
            one.bs_textBackgroundBorder = border
            
            text.append(padding())
            text.append(one)
            text.append(padding())
            text.append(padding())
            text.append(padding())
            text.append(padding())
        }
        
        do {
            let one = NSMutableAttributedString(string: "Link")
            one.bs_font = UIFont.boldSystemFont(ofSize: 30)
            one.bs_underlineStyle = NSUnderlineStyle.single
            
            /// 1. you can set a highlight with these code
            /*
             one.bs_color = UIColor(red: 0.093, green: 0.492, blue: 1.000, alpha: 1.000)
             
             let border = TextBorder()
             border.cornerRadius = 3
             border.insets = UIEdgeInsets(top: -2, left: -1, bottom: -2, right: -1)
             border.fillColor = UIColor(white: 0, alpha: 0.22)
             
             let highlight = TextHighlight()
             highlight.border = border
             highlight.tapAction = { containerView, text, range, rect in
                _self?.showMessage("Tap: \((text?.string as NSString?)?.substring(with: range) ?? "")")
             }
             one.bs_set(textHighlight: highlight, range: one.bs_rangeOfAll)
             */
            
            /// 2. or you can use the convenience method
            one.bs_set(textHighlightRange: one.bs_rangeOfAll, color: UIColor(red: 0.093, green: 0.492, blue: 1.000, alpha: 1.000), backgroundColor: UIColor(white: 0.000, alpha: 0.220), tapAction: { containerView, text, range, rect in
                _self?.showMessage("Tap: \((text?.string as NSString?)?.substring(with: range) ?? "")")
            })
            
            text.append(one)
            text.append(padding())
        }
        
        do {
            let one = NSMutableAttributedString(string: "Another Link")
            one.bs_font = UIFont.boldSystemFont(ofSize: 30)
            one.bs_color = UIColor.red
            
            let border = TextBorder()
            border.cornerRadius = 50
            border.insets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: -10)
            border.strokeWidth = 0.5
            border.strokeColor = one.bs_color
            border.lineStyle = TextLineStyle.single
            one.bs_textBackgroundBorder = border
            
            let highlightBorder = border.copy() as! TextBorder
            highlightBorder.strokeWidth = 0
            highlightBorder.strokeColor = one.bs_color
            highlightBorder.fillColor = one.bs_color
            
            let highlight = TextHighlight()
            highlight.color = UIColor.white
            highlight.backgroundBorder = highlightBorder
            highlight.tapAction = { containerView, text, range, rect in
                _self?.showMessage("Tap: \((text?.string as NSString?)?.substring(with: range) ?? "")")
            }
            one.bs_set(textHighlight: highlight, range: one.bs_rangeOfAll)
            
            text.append(one)
            text.append(padding())
        }
        
        do {
            let one = NSMutableAttributedString(string: "Yet Another Link")
            one.bs_font = UIFont.boldSystemFont(ofSize: 30)
            one.bs_color = UIColor.white
            
            let shadow = TextShadow()
            shadow.color = UIColor(white: 0.000, alpha: 0.490)
            shadow.offset = CGSize(width: 0, height: 1)
            shadow.radius = 5
            one.bs_textShadow = shadow
            
            let shadow0 = TextShadow()
            shadow0.color = UIColor(white: 0.000, alpha: 0.20)
            shadow0.offset = CGSize(width: 0, height: -1)
            shadow0.radius = 1.5
            let shadow1 = TextShadow()
            shadow1.color = UIColor(white: 1, alpha: 0.99)
            shadow1.offset = CGSize(width: 0, height: 1)
            shadow1.radius = 1.5
            shadow0.subShadow = shadow1
            
            let innerShadow0 = TextShadow()
            innerShadow0.color = UIColor(red: 0.851, green: 0.311, blue: 0.000, alpha: 0.780)
            innerShadow0.offset = CGSize(width: 0, height: 1)
            innerShadow0.radius = 1
            
            let highlight = TextHighlight()
            highlight.color = UIColor(red: 1.000, green: 0.795, blue: 0.014, alpha: 1.000)
            highlight.shadow = shadow0
            highlight.innerShadow = innerShadow0
            one.bs_set(textHighlight: highlight, range: one.bs_rangeOfAll)
            
            text.append(one)
        }
        
        let label = BSLabel()
        label.attributedText = text
        label.width = view.width
        label.height = view.height - kNavHeight
        label.top = kNavHeight
        label.textAlignment = NSTextAlignment.center
        label.textVerticalAlignment = TextVerticalAlignment.center
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.933, alpha: 1.000)
        view.addSubview(label)
        
        /*
         If the 'highlight.tapAction' is not nil, the label will invoke 'highlight.tapAction'
         and ignore 'label.highlightTapAction'.
         
         If the 'highlight.tapAction' is nil, you can use 'highlightTapAction' to handle
         all tap action in this label.
         */
        label.highlightTapAction = { containerView, text, range, rect in
            _self?.showMessage("Tap: \((text?.string as NSString?)?.substring(with: range) ?? "")")
        }
    }
    
    func padding() -> NSAttributedString {
        let pad = NSMutableAttributedString(string: "\n\n")
        pad.bs_font = UIFont.systemFont(ofSize: 4)
        return pad
    }
    
    func showMessage(_ msg: String) {
        let padding: CGFloat = 10
        
        let label = BSLabel()
        label.text = msg
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(red: 0.033, green: 0.685, blue: 0.978, alpha: 0.730)
        label.width = view.width
        label.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        label.height = msg.height(for: label.font, width: label.width) + 2 * padding
        
        label.bottom = kNavHeight
        view.addSubview(label)
        UIView.animate(withDuration: 0.3, animations: {
            label.top = self.kNavHeight
        }) { finished in
            UIView.animate(withDuration: 0.2, delay: 2, options: .curveEaseInOut, animations: {
                label.bottom = self.kNavHeight
            }) { finished in
                label.removeFromSuperview()
            }
        }
    }
}
