//
//  BSTextExampleHelper.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import BSText

@inline(__always) private func wl_safeAreaInset() -> UIEdgeInsets {
    if #available(iOS 11.0, *) {
        let window: UIView? = UIApplication.shared.windows.first
        return (window?.safeAreaInsets)!
    }
    return .zero
}

extension UIViewController {
    
    @objc var kNavHeight: CGFloat {
        return wl_safeAreaInset().top + (navigationController?.navigationBar.height ?? 0)
    }
}

private var kDebugEnabled = false

class BSTextExampleHelper: NSObject {
    
    @objc(addDebugOptionToViewController:)
    class func addDebugOption(to vc: UIViewController?) {
        let switcher = UISwitch()
        switcher.layer.setValue(NSNumber(value: 0.8), forKeyPath: "transform.scale")
        
        switcher.isOn = kDebugEnabled
        switcher.addBlock(forControlEvents: UIControl.Event.valueChanged, block: { sender in
            self.setDebug((sender as! UISwitch).isOn)
        })
        
        let view = UIView()
        view.size = CGSize(width: 40, height: 44)
        view.addSubview(switcher)
        switcher.centerX = view.width / 2
        switcher.centerY = view.height / 2
        
        let item = UIBarButtonItem(customView: view)
        vc?.navigationItem.rightBarButtonItem = item
    }
    
    @objc class func setDebug(_ debug: Bool) {
        let debugOptions = TextDebugOption()
        if debug {
            debugOptions.baselineColor = UIColor.red
            debugOptions.ctFrameBorderColor = UIColor.red
            debugOptions.ctLineFillColor = UIColor(red: 0.000, green: 0.463, blue: 1.000, alpha: 0.180)
            debugOptions.cgGlyphBorderColor = UIColor(red: 1.000, green: 0.524, blue: 0.000, alpha: 0.200)
        } else {
            debugOptions.clear()
        }
        TextDebugOption.setSharedDebugOption(debugOptions)
        kDebugEnabled = debug
    }
    
    @objc class func isDebug() -> Bool {
        return kDebugEnabled
    }
}
