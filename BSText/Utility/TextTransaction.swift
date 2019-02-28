//
//  TextTransaction.swift
//  BSText
//
//  Created by BlueSky on 2018/10/22.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit
import CoreFoundation

fileprivate var transactionSet = Set<TextTransaction>()

private let kRunLoopObserverCallBack: CFRunLoopObserverCallBack = { _, _, _ in
    if transactionSet.count == 0 {
        return
    }
    let currentSet = transactionSet
    transactionSet = Set<TextTransaction>()
    
    for transaction in currentSet {
        let _ = transaction.target.perform(transaction.selector)
    }
}

private let kTextTransactionSetup: Int = {
    
    let runloop = CFRunLoopGetMain()
    
    let observer = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue | CFRunLoopActivity.exit.rawValue, true,  0, kRunLoopObserverCallBack, nil)
    CFRunLoopAddObserver(runloop, observer, .commonModes)
    
    return 0
}()

public class TextTransaction: NSObject {
    
    fileprivate var target: AnyObject
    fileprivate var selector: Selector
    
    @objc(transactionWithTarget:selector:)
    public class func transaction(with target: AnyObject, selector: Selector) -> TextTransaction {
        
        let t = TextTransaction(target: target, selector: selector)
        return t
    }
    
    public init(target: AnyObject, selector: Selector) {
        
        self.target = target
        self.selector = selector
        
        super.init()
    }
    
    @objc public func commit() {
        
        let _ = kTextTransactionSetup
        transactionSet.insert(self)
    }
    
    override public var hash: Int {
        get {
            let v1 = selector.hashValue
            let v2 = target.hash!
            return v1 ^ v2
        }
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        
        guard let other = (object as? TextTransaction) else {
            return false
        }
        if self === other {
            return true
        }

        return other.selector == selector && other.target === self.target
    }
}
