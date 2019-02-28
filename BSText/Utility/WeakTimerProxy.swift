//
//  WeakTimerProxy.swift
//  BSText
//
//  Created by Bruce on 2018/10/21.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 目前没有找到 Swift 下基于 NSProxy 的好的解决方案
/// 处理 NSTimer、CADisplayLink 引用循环的代理类
public class WeakTimerProxy: NSObject {
    
    weak var target: NSObjectProtocol?
    // MARK: - 目前的处理 方法中还不能带参数，否则会崩溃
    var sel: Selector?
    /// required，实例化timer之后需要将timer赋值给proxy，否则就算target释放了，timer本身依然会继续运行
    public weak var timer: Timer?
    public weak var displayLink: CADisplayLink?
    
    public required init(target: NSObjectProtocol?, sel: Selector?) {
        self.target = target
        self.sel = sel
        super.init()
        // 加强安全保护
        guard target?.responds(to: sel) == true else {
            return
        }
        // 将target的selector替换为redirectionMethod，该方法会重新处理事件
        let method = class_getInstanceMethod(self.classForCoder, #selector(WeakTimerProxy.redirectionMethod))!
        class_replaceMethod(self.classForCoder, sel!, method_getImplementation(method), method_getTypeEncoding(method))
    }
    
    @objc func redirectionMethod () {
        // 如果target未被释放，则调用target方法，否则释放timer
        if self.target != nil {
            self.target!.perform(self.sel)
        } else {
            self.timer?.invalidate()
            self.displayLink?.invalidate()
            print("WeakProxy: invalidate timer.")
        }
    }
    
    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        
        if self.target?.responds(to: aSelector) == true {
            return self.target
        } else {
            self.timer?.invalidate()
            self.displayLink?.invalidate()
            return self
        }
    }
}

// 使用案例
// 外部调用target直接传 self 就行，有代理类，可以放心直接使用，不用担心循环引用
//self.timer = Timer.bs_scheduledTimer(timeInterval: 3, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
public extension Timer {
    
    @objc(bs_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)
    class func bs_scheduledTimer(with timeInterval: TimeInterval, target: NSObjectProtocol, selector: Selector, userInfo aInfo: Any?, repeats yesOrNo: Bool) -> Timer {
        
        let proxy = WeakTimerProxy.init(target: target, sel: selector)
        let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: proxy, selector: selector, userInfo:aInfo, repeats: yesOrNo)
        proxy.timer = timer
        
        return timer
    }
}

public extension CADisplayLink {
    
    @objc(bs_displayLinkWithTarget:selector:)
    class func bs_displayLink(with target: NSObjectProtocol, selector: Selector) -> CADisplayLink {
        
        let proxy = WeakTimerProxy.init(target: target, sel: selector)
        let displayLink = CADisplayLink.init(target: proxy, selector: selector)
        displayLink.add(to: RunLoop.main, forMode: .common)
        proxy.displayLink = displayLink

        return displayLink
    }
}
