//
//  UIGestureRecognizerExtension.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/22.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

extension UIGestureRecognizer {
    /**
     Initializes an allocated gesture-recognizer object with a action block.
     
     @param block  An action block that to handle the gesture recognized by the
     receiver. nil is invalid. It is retained by the gesture.
     
     @return An initialized instance of a concrete UIGestureRecognizer subclass or
     nil if an error occurred in the attempt to initialize the object.
     */
    convenience init(actionBlock block: @escaping (_ sender: Any?) -> Void) {
        self.init()
        addActionBlock(block)
    }
    
    /**
     Adds an action block to a gesture-recognizer object. It is retained by the
     gesture.
     
     @param block A block invoked by the action message. nil is not a valid value.
     */
    func addActionBlock(_ block: @escaping (_ sender: Any?) -> Void) {
        let target = BSUIGestureRecognizerBlockTarget(block: block)
        addTarget(target, action: #selector(target.invoke(_:)))
        
        let targets = _bs_allUIGestureRecognizerBlockTargets()
        targets.add(target)
    }
    
    /**
     Remove all action blocks.
     */
    func removeAllActionBlocks() {
        let targets = _bs_allUIGestureRecognizerBlockTargets()
        targets.enumerateObjects({ target, idx, stop in
            guard let target = target as? BSUIGestureRecognizerBlockTarget else {
                return
            }
            self.removeTarget(target, action: #selector(target.invoke(_:)))
        })
        targets.removeAllObjects()
    }
    
    private func _bs_allUIGestureRecognizerBlockTargets() -> NSMutableArray {
        var targets = objc_getAssociatedObject(self, &block_key) as? NSMutableArray
        
        if targets == nil {
            targets = NSMutableArray()
            objc_setAssociatedObject(self, &block_key, targets, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        return targets!
    }
}

private var block_key: Int = 0

private class BSUIGestureRecognizerBlockTarget: NSObject {
    var block: ((_ sender: Any?) -> Void)?
    
    init(block: @escaping (_ sender: Any?) -> Void) {
        super.init()
        
        self.block = block
    }
    
    @objc func invoke(_ sender: Any?) {
        block?(sender)
    }
}
