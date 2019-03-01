//
//  BSTextRubyExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText
import YYImage

class BSTextRubyExample: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        
        let text = NSMutableAttributedString()
        
        var one = NSMutableAttributedString(string: "这是用汉语写的一段文字。")
        one.bs_font = UIFont.boldSystemFont(ofSize: 30)
        
        var ruby: TextRubyAnnotation
        ruby = TextRubyAnnotation()
        ruby.textBefore = "hàn yŭ"
        one.bs_set(textRubyAnnotation: ruby, range: (one.string as NSString).range(of: "汉语"))
        
        ruby = TextRubyAnnotation()
        ruby.textBefore = "wén"
        one.bs_set(textRubyAnnotation: ruby, range: (one.string as NSString).range(of: "文"))
        
        ruby = TextRubyAnnotation()
        ruby.textBefore = "zì"
        ruby.alignment = CTRubyAlignment.center
        one.bs_set(textRubyAnnotation: ruby, range: (one.string as NSString).range(of: "字"))
        
        text.append(one)
        text.append(padding())
        
        one = NSMutableAttributedString(string: "日本語で書いた作文です。")
        one.bs_font = UIFont.boldSystemFont(ofSize: 30)
        
        ruby = TextRubyAnnotation()
        ruby.textBefore = "に"
        one.bs_set(textRubyAnnotation: ruby, range: (one.string as NSString).range(of: "日"))
        
        ruby = TextRubyAnnotation()
        ruby.textBefore = "ほん"
        one.bs_set(textRubyAnnotation: ruby, range: (one.string as NSString).range(of: "本"))
        
        ruby = TextRubyAnnotation()
        ruby.textBefore = "ご"
        one.bs_set(textRubyAnnotation: ruby, range: (one.string as NSString).range(of: "語"))
        
        ruby = TextRubyAnnotation()
        ruby.textBefore = "か"
        one.bs_set(textRubyAnnotation: ruby, range: (one.string as NSString).range(of: "書"))
        
        ruby = TextRubyAnnotation()
        ruby.textBefore = "さく"
        one.bs_set(textRubyAnnotation: ruby, range: (one.string as NSString).range(of: "作"))
        
        ruby = TextRubyAnnotation()
        ruby.textBefore = "ぶん"
        one.bs_set(textRubyAnnotation: ruby, range: (one.string as NSString).range(of: "文"))
        
        text.append(one)
        
        
        let label = BSLabel()
        label.attributedText = text
        label.width = view.width - 60
        label.centerX = view.width / 2
        label.height = view.height - kNavHeight - 60
        label.top = kNavHeight + 30
        label.textAlignment = NSTextAlignment.center
        label.textVerticalAlignment = TextVerticalAlignment.center
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.933, alpha: 1.000)
        view.addSubview(label)
    }

    func padding() -> NSAttributedString {
        let pad = NSMutableAttributedString(string: "\n\n")
        pad.bs_font = UIFont.systemFont(ofSize: 30)
        return pad
    }
}
