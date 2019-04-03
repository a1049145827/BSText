//
//  BSFPSLabel.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

private let kSize = CGSize(width: 55, height: 20)

/**
 Show Screen FPS...
 
 The maxmium fps is 60.0.
 */
class BSFPSLabel: UILabel {
    
    private var link: CADisplayLink?
    private var count: Int = 0
    private var lastTime: TimeInterval = 0.0
    private var _font: UIFont?
    override var font: UIFont? {
        set {
            _font = newValue
        }
        get {
            return _font
        }
    }
    private var subFont: UIFont?
    
    public convenience init() {
        self.init(frame: .zero)
    }

    override required init(frame: CGRect) {
        var frame = frame
        if frame.size.width == 0 && frame.size.height == 0 {
            frame.size = kSize
        }
        super.init(frame: frame)
        
        layer.cornerRadius = 5
        clipsToBounds = true
        textAlignment = .center
        isUserInteractionEnabled = false
        backgroundColor = UIColor(white: 0.000, alpha: 0.700)
        
        font = UIFont(name: "Menlo", size: 14)
        if (font != nil) {
            subFont = UIFont(name: "Menlo", size: 4)
        } else {
            font = UIFont(name: "Courier", size: 14)
            subFont = UIFont(name: "Courier", size: 4)
        }
        
        link = CADisplayLink.bs_displayLink(with: self, selector: #selector(self.tick))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        link?.invalidate()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return kSize
    }
    
    @objc private func tick() {
        if lastTime == 0 {
            lastTime = link!.timestamp
            return
        }
        
        count += 1
        let delta: TimeInterval = link!.timestamp - lastTime
        if delta < 1 {
            return
        }
        lastTime = link!.timestamp
        let fps = Double(count) / delta
        count = 0
        
        let progress = CGFloat(fps / 60.0)
        let color = UIColor(hue: 0.27 * (progress - 0.2), saturation: 1, brightness: 0.9, alpha: 1)
        
        let text = NSMutableAttributedString(string: "\(Int(round(fps))) FPS")
        text.bs_set(color: color, range: NSRange(location: 0, length: text.length - 3))
        text.bs_set(color: UIColor.white, range: NSRange(location: text.length - 3, length: 3))
        text.bs_font = font
        text.bs_set(font: subFont, range: NSRange(location: text.length - 4, length: 1))
        
        attributedText = text
    }
}
