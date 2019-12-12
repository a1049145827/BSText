//
//  BSTextMarkdownExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText

class BSTextMarkdownExample: UIViewController, TextViewDelegate {
    
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
        
        let text = "#Markdown Editor\nThis is a simple markdown editor based on `BSTextView`.\n\n*********************************************\nIt\'s *italic* style.\n\nIt\'s also _italic_ style.\n\nIt\'s **bold** style.\n\nIt\'s ***italic and bold*** style.\n\nIt\'s __underline__ style.\n\nIt\'s ~~deleteline~~ style.\n\n\nHere is a link: [github](https://github.com/)\n\nHere is some code:\n\n\tif(a){\n\t\tif(b){\n\t\t\tif(c){\n\t\t\t\tprintf(\"haha\");\n\t\t\t}\n\t\t}\n\t}\n"
        
        let parser = TextSimpleMarkdownParser()
        parser.setColorWithDarkTheme()
        
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textParser = parser
        textView.size = view.size
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self
        textView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        
        textView.backgroundColor = UIColor(white: 0.134, alpha: 1.000)
        textViewInsets = UIEdgeInsets(top: kNavHeight, left: 0, bottom: 0, right: 0)
        textView.contentInset = textViewInsets
        textView.scrollIndicatorInsets = textView.contentInset
        textView.selectedRange = NSRange(location: text.length, length: 0)
        view.addSubview(textView)
    }
    
    @objc private func edit(_ item: UIBarButtonItem?) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    // MARK: - BSTextViewDelegate
    
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
