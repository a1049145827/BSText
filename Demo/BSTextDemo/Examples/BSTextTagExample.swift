//
//  BSTextTagExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText

class BSTextTagExample: UIViewController, TextViewDelegate {
    
    private let textView = BSTextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            textView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let text = NSMutableAttributedString()
        let tags = [
            "◉red",
            "◉orange",
            "◉yellow",
            "◉green",
            "◉blue",
            "◉purple",
            "◉gray"
        ]
        let tagStrokeColors: [UIColor] = [
            UIColor(hex: 0xfa3f39),
            UIColor(hex: 0xf48f25),
            UIColor(hex: 0xf1c02c),
            UIColor(hex: 0x54bc2e),
            UIColor(hex: 0x29a9ee),
            UIColor(hex: 0xc171d8),
            UIColor(hex: 0x818e91)
        ]
        let tagFillColors: [UIColor] = [
            UIColor(hex: 0xfb6560),
            UIColor(hex: 0xf6a550),
            UIColor(hex: 0xf3cc56),
            UIColor(hex: 0x76c957),
            UIColor(hex: 0x53baf1),
            UIColor(hex: 0xcd8ddf),
            UIColor(hex: 0xa4a4a7)
        ]
        let font = UIFont.boldSystemFont(ofSize: 16)
        for i in 0..<tags.count {
            let tag = tags[i]
            let tagStrokeColor: UIColor? = tagStrokeColors[i]
            let tagFillColor: UIColor? = tagFillColors[i]
            let tagText = NSMutableAttributedString(string: tag)
            tagText.bs_insert(string: "   ", at: 0)
            tagText.bs_append(string: "   ")
            tagText.bs_font = font
            tagText.bs_color = UIColor.white
            tagText.bs_set(textBinding: TextBinding.binding(with: false), range: tagText.bs_rangeOfAll)
            
            let border = TextBorder()
            border.strokeWidth = 1.5
            border.strokeColor = tagStrokeColor
            border.fillColor = tagFillColor
            border.cornerRadius = 100 // a huge value
            border.lineJoin = CGLineJoin.bevel
            
            border.insets = UIEdgeInsets(top: -2, left: -5.5, bottom: -2, right: -8)
            tagText.bs_set(textBackgroundBorder: border, range: (tagText.string as NSString).range(of: tag))
            
            text.append(tagText)
        }
        text.bs_lineSpacing = 10
        text.bs_lineBreakMode = NSLineBreakMode.byWordWrapping
        
        text.bs_append(string: "\n")
        text.append(text) // repeat for test
        
        
        textView.attributedText = text
        textView.size = view.size
        textView.textContainerInset = UIEdgeInsets(top: 10 + kNavHeight, left: 10, bottom: 10, right: 10)
        textView.allowsCopyAttributedString = true
        textView.allowsPasteAttributedString = true
        textView.delegate = self
        textView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        
        textView.scrollIndicatorInsets = textView.contentInset
        textView.selectedRange = NSRange(location: text.length, length: 0)
        view.addSubview(textView)
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.textView.becomeFirstResponder()
        })
    }
    
    @objc private func edit(_ item: UIBarButtonItem?) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    // MARK: BSTextViewDelegate
    
    func textViewDidBeginEditing(_ textView: BSTextView) {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.edit(_:)))
        navigationItem.rightBarButtonItem = buttonItem
    }
    
    func textViewDidEndEditing(_ textView: BSTextView) {
        navigationItem.rightBarButtonItem = nil
    }
}
