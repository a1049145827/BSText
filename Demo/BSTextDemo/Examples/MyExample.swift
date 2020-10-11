//
//  MyExample.swift
//  BSTextDemo
//
//  Created by BruceLiu on 2020/6/20.
//  Copyright © 2020 GeekBruce. All rights reserved.
//

import UIKit
import BSText

class MyExample: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        let text = NSMutableAttributedString()
        
        let one = NSMutableAttributedString(string: "Inner Shadow")
        one.bs_font = .boldSystemFont(ofSize: 30)
        one.bs_color = .black
        let shadow = TextShadow()
        shadow.color = UIColor(white: 0, alpha: 0.4)
        shadow.offset = CGSize(width: 0, height: 1)
        shadow.radius = 1
        one.bs_textInnerShadow = shadow
        
        one.bs_set(textStrikethrough: TextDecoration.decoration(with: .single, width: 2, color: .red), range: one.bs_rangeOfAll)
        
        text.append(one)
        
        
        let label = BSLabel()
        label.attributedText = text
        label.width = view.width
        label.height = view.height - kNavHeight
        label.top = kNavHeight
        label.textAlignment = NSTextAlignment.center
        label.textVerticalAlignment = TextVerticalAlignment.center
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.933, alpha: 1)
        view.addSubview(label)
    }
}
