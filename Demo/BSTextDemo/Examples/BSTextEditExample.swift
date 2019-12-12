//
//  BSTextEditExample.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText
import YYImage

class BSTextEditExample: UIViewController, TextViewDelegate, TextKeyboardObserver {
    
    private var textView = BSTextView()
    private var imageView: UIImageView?
    private var verticalSwitch = UISwitch()
    private var debugSwitch = UISwitch()
    private var exclusionSwitch = UISwitch()
    private var textViewInsets = UIEdgeInsets.zero

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            textView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        initImageView()
        
        let toolbar = UIView()
        toolbar.backgroundColor = UIColor.white
        toolbar.size = CGSize(width: Screen.width, height: 40)
        toolbar.top = kNavHeight
        view.addSubview(toolbar)
        
        let text = NSMutableAttributedString(string: "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the season of light, it was the season of darkness, it was the spring of hope, it was the winter of despair, we had everything before us, we had nothing before us. We were all going direct to heaven, we were all going direct the other way.\n\n这是最好的时代，这是最坏的时代；这是智慧的时代，这是愚蠢的时代；这是信仰的时期，这是怀疑的时期；这是光明的季节，这是黑暗的季节；这是希望之春，这是失望之冬；人们面前有着各样事物，人们面前一无所有；人们正在直登天堂，人们正在直下地狱。")
        text.bs_font = UIFont(name: "Times New Roman", size: 20)
        text.bs_lineSpacing = 4
        text.bs_firstLineHeadIndent = 20
        
        
        textView.attributedText = text
        textView.size = view.size
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self
        textView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
        
        textViewInsets = UIEdgeInsets(top: toolbar.bottom, left: 0, bottom: 0, right: 0)
        textView.contentInset = textViewInsets
        textView.scrollIndicatorInsets = textView.contentInset
        textView.selectedRange = NSRange(location: text.length, length: 0)
        view.insertSubview(textView, belowSubview: toolbar)
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.textView.becomeFirstResponder()
        })
        
        
        //------------------------------ Toolbar ---------------------------------
        var label: UILabel
        label = UILabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Vertical:"
        label.size = CGSize(width: label.text!.width(for: label.font) + 2, height: toolbar.height)
        label.left = 10
        
        toolbar.addSubview(label)
        
        
        verticalSwitch.sizeToFit()
        verticalSwitch.centerY = toolbar.height / 2
        verticalSwitch.left = label.right - 5
        verticalSwitch.layer.transformScale = 0.8
        
        weak var _self = self
        verticalSwitch.addBlock(forControlEvents: UIControl.Event.valueChanged, block: { switcher in
            guard let switcher = switcher as? UISwitch else {
                return
            }
            _self?.textView.endEditing(true)
            if switcher.isOn {
                _self?.exclusionPathEnabled = false
                _self?.exclusionSwitch.isOn = false
            }
            _self?.exclusionSwitch.isEnabled = !switcher.isOn
            _self?.textView.isVerticalForm = switcher.isOn /// Set vertical form
        })
        toolbar.addSubview(verticalSwitch)
        
        label = UILabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Debug:"
        label.size = CGSize(width: label.text!.width(for: label.font) + 2, height: toolbar.height)
        label.left = verticalSwitch.right + 5
        toolbar.addSubview(label)
        
        
        debugSwitch.sizeToFit()
        debugSwitch.isOn = BSTextExampleHelper.isDebug()
        debugSwitch.centerY = toolbar.height / 2
        debugSwitch.left = label.right - 5
        debugSwitch.layer.transformScale = 0.8
        debugSwitch.addBlock(forControlEvents: UIControl.Event.valueChanged, block: { switcher in
            BSTextExampleHelper.setDebug((switcher as! UISwitch).isOn)
        })
        toolbar.addSubview(debugSwitch)
        
        label = UILabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Exclusion:"
        label.size = CGSize(width: label.text!.width(for: label.font) + 2, height: toolbar.height)
        label.left = debugSwitch.right + 5
        toolbar.addSubview(label)
        
        
        exclusionSwitch.sizeToFit()
        exclusionSwitch.centerY = toolbar.height / 2
        exclusionSwitch.left = label.right - 5
        exclusionSwitch.layer.transformScale = 0.8
        exclusionSwitch.addBlock(forControlEvents: UIControl.Event.valueChanged, block: { switcher in
            self.exclusionPathEnabled = (switcher as! UISwitch).isOn
        })
        toolbar.addSubview(exclusionSwitch)
        
        TextKeyboardManager.default.add(observer: self)
    }
    
    override func viewWillLayoutSubviews() {
        textView.size = view.size
    }
    
    private var exclusionPathEnabled: Bool {
        set(enabled) {
            if enabled {
                if let imageView = imageView {
                    textView.addSubview(imageView)
                }
                let path = UIBezierPath(roundedRect: imageView?.frame ?? CGRect.zero, cornerRadius: imageView?.layer.cornerRadius ?? 0.0)
                textView.exclusionPaths = [path] /// Set exclusion paths
            } else {
                imageView?.removeFromSuperview()
                textView.exclusionPaths = nil
            }
        }
        get {
            return false
        }
    }
    
    private func initImageView() {
        let data = Data.dataNamed("dribbble256_imageio.png")
        let image = YYImage(data: data!, scale: 2)
        imageView = YYAnimatedImageView(image: image)
        
        imageView?.clipsToBounds = true
        imageView?.isUserInteractionEnabled = true
        imageView?.layer.cornerRadius = imageView!.height / 2.0
        imageView?.center = CGPoint(x: Screen.width / 2.0, y: Screen.width / 2.0)
        
        
        weak var _self = self
        let g = UIPanGestureRecognizer(actionBlock: { g in
            guard let `self` = _self, let g = g as? UIPanGestureRecognizer else {
                return
            }
            
            let p = g.location(in: self.textView)
            self.imageView?.center = p
            let path = UIBezierPath(roundedRect: self.imageView?.frame ?? CGRect.zero, cornerRadius: self.imageView!.layer.cornerRadius)
            self.textView.exclusionPaths = [path]
        })
        imageView?.addGestureRecognizer(g)
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
    }
    
    func textViewDidEndEditing(_ textView: BSTextView) {
        navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - keyboard
    
    func keyboardChanged(with transition: TextKeyboardTransition) {
        var clipped = false
        if textView.isVerticalForm && transition.toVisible {
            let rect = TextKeyboardManager.default.convert(transition.toFrame, to: view)
            if rect.maxY == view.height {
                var textFrame: CGRect = view.bounds
                textFrame.size.height -= rect.size.height
                textView.frame = textFrame
                clipped = true
            }
        }
        
        if !clipped {
            textView.frame = view.bounds
        }
        textView.contentInset = textViewInsets
    }
}
