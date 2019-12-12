//
//  BSTextBindingExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText
import YYImage

class BSTextBindingExample: UIViewController, TextViewDelegate {
    
    private var textView = BSTextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            textView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let text = NSMutableAttributedString(string: "sjobs@apple.com, apple@apple.com, banana@banana.com, pear@pear.com ")
        text.bs_font = UIFont.systemFont(ofSize: 17)
        text.bs_lineSpacing = 5
        text.bs_color = UIColor.black
        
        
        textView.attributedText = text
        textView.textParser = BSTextExampleEmailBindingParser()
        textView.size = view.size
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self
        textView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        
        textView.contentInset = UIEdgeInsets(top: kNavHeight, left: 0, bottom: 0, right: 0)
        textView.scrollIndicatorInsets = textView.contentInset
        view.addSubview(textView)
        
        textView.becomeFirstResponder()
    }
    
    @objc private func edit(_ item: UIBarButtonItem?) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    // MARK: - BSTextViewDelegate
    
    func textViewDidChange(_ textView: BSTextView) {
        if textView.text.length == 0 {
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidBeginEditing(_ textView: BSTextView) {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.edit(_:)))
        navigationItem.rightBarButtonItem = buttonItem
    }
    
    func textViewDidEndEditing(_ textView: BSTextView) {
        navigationItem.rightBarButtonItem = nil
    }
}

private class BSTextExampleEmailBindingParser: NSObject, TextParser {
    
    var regex: NSRegularExpression?
    
    override init() {
        super.init()
        
        let pattern = "[-_a-zA-Z@\\.]+[ ,\\n]"
        regex = try? NSRegularExpression(pattern: pattern, options: [])
    }
    
    func parseText(_ text: NSMutableAttributedString?, selectedRange range: NSRangePointer?) -> Bool {
        let text = text
        var changed = false
        if let bs_rangeOfAll = text?.bs_rangeOfAll {
            regex?.enumerateMatches(in: text?.string ?? "", options: .withoutAnchoringBounds, range: bs_rangeOfAll, using: { result, flags, stop in
                if result == nil {
                    return
                }
                let range: NSRange? = result?.range
                if (range?.location ?? 0) == NSNotFound || (range?.length ?? 0) < 1 {
                    return
                }
                if text?.attribute(NSAttributedString.Key(rawValue: TextAttribute.textBindingAttributeName), at: (range?.location ?? 0), effectiveRange: nil) != nil {
                    return
                }
                
                let bindlingRange = NSRange(location: (range?.location ?? 0), length: (range?.length ?? 0) - 1)
                let binding = TextBinding.binding(with: true)
                text?.bs_set(textBinding: binding, range: bindlingRange) /// Text binding
                text?.bs_set(color: UIColor(red: 0.000, green: 0.519, blue: 1.000, alpha: 1.000), range: bindlingRange)
                changed = true
            })
        }
        return changed
    }
}
