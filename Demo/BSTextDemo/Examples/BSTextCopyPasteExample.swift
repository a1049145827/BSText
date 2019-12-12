//
//  BSTextCopyPasteExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText
import YYImage

class BSTextCopyPasteExample: UIViewController, TextViewDelegate {
    
    private var textView = BSTextView()
    private var textViewInsets = UIEdgeInsets.zero

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            textView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let text = "You can copy image from browser or photo album and paste it to here. It support animated GIF and APNG. \n\nYou can also copy attributed string from other BSTextView.\n"
        
        let parser = TextSimpleMarkdownParser()
        parser.setColorWithDarkTheme()
        
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.size = view.size
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self
        textView.allowsPasteImage = true /// Pasts image
        textView.allowsPasteAttributedString = true /// Paste attributed string
        textView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        
        textViewInsets = UIEdgeInsets(top: kNavHeight, left: 0, bottom: 0, right: 0)
        textView.contentInset = textViewInsets
        textView.scrollIndicatorInsets = textView.contentInset
        view.addSubview(textView)
        
        textView.selectedRange = NSRange(location: text.length, length: 0)
        textView.becomeFirstResponder()
    }
    
    @objc private func edit(_ item: UIBarButtonItem?) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    // MARK: - TextViewDelegate
    
    func textViewDidBeginEditing(_ textView: BSTextView) {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.edit(_:)))
        navigationItem.rightBarButtonItem = buttonItem

        textView.contentInset = textViewInsets
    }
    
    func textViewDidEndEditing(_ textView: BSTextView) {
        navigationItem.rightBarButtonItem = nil
        
        textView.contentInset = textViewInsets
    }
}
