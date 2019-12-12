//
//  BSTextEmoticonExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText
import YYImage

class BSTextEmoticonExample: UIViewController, TextViewDelegate {
    
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
        
        var mapper = [String : UIImage]()
        mapper[":smile:"] = image(withName: "002")
        mapper[":cool:"] = image(withName: "013")
        mapper[":biggrin:"] = image(withName: "047")
        mapper[":arrow:"] = image(withName: "007")
        mapper[":confused:"] = image(withName: "041")
        mapper[":cry:"] = image(withName: "010")
        mapper[":wink:"] = image(withName: "085")
        
        let parser = TextSimpleEmoticonParser()
        parser.emoticonMapper = mapper
        
        let mod = TextLinePositionSimpleModifier()
        mod.fixedLineHeight = 22
        
        textView.text = "Hahahah:smile:, it\'s emoticons::cool::arrow::cry::wink:\n\nYou can input \":\" + \"smile\" + \":\" to display smile emoticon, or you can copy and paste these emoticons.\n"
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textParser = parser
        textView.size = view.size
        textView.linePositionModifier = mod
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self
        textView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        
        textViewInsets = UIEdgeInsets(top: kNavHeight, left: 0, bottom: 0, right: 0)
        textView.contentInset = textViewInsets
        textView.scrollIndicatorInsets = textView.contentInset
        view.addSubview(textView)
        
        textView.becomeFirstResponder()
    }

    func image(withName name: String?) -> UIImage? {
        let bundle = Bundle(path: Bundle.main.path(forResource: "EmoticonQQ", ofType: "bundle") ?? "")
        let path = bundle?.path(forScaledResource: name, ofType: "gif")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path ?? ""))
        let image = YYImage(data: data!, scale: 2)
        
        image?.preloadAllAnimatedImageFrames = true
        return image
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
