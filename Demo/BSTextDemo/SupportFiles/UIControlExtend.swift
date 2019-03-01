//
//  UIControlExtend.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/19.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

extension UIControl {
    
    /**
     Removes all targets and actions for a particular event (or events)
     from an internal dispatch table.
     */
    @objc
    func removeAllTargets() {
        for object in allTargets {
            self.removeTarget(object, action: nil, for: .allEvents)
        }
    }
    
    /**
     Adds or replaces a target and action for a particular event (or events)
     to an internal dispatch table.
     
     @param target         The target object—that is, the object to which the
     action message is sent. If this is nil, the responder
     chain is searched for an object willing to respond to the
     action message.
     
     @param action         A selector identifying an action message. It cannot be NULL.
     
     @param controlEvents  A bitmask specifying the control events for which the
     action message is sent.
     */
    @objc
    func setTarget(_ target: Any?, action: Selector, forControlEvents controlEvents: UIControl.Event) {
        let targets = allTargets
        for currentTarget: Any? in targets {
            let actions = self.actions(forTarget: currentTarget, forControlEvent: controlEvents)
            for currentAction in actions ?? [] {
                removeTarget(currentTarget, action: NSSelectorFromString(currentAction), for: controlEvents)
            }
        }
        addTarget(target, action: action, for: controlEvents)
    }
    
    /**
     Adds a block for a particular event (or events) to an internal dispatch table.
     It will cause a strong reference to @a block.
     
     @param block          The block which is invoked then the action message is
     sent  (cannot be nil). The block is retained.
     
     @param controlEvents  A bitmask specifying the control events for which the
     action message is sent.
     */
    @objc(addBlockForControlEvents:block:)
    func addBlock(forControlEvents controlEvents: UIControl.Event, block: @escaping (_ sender: Any?) -> Void) {
        let target = BSUIControlBlockTarget(block: block, events: controlEvents)
        addTarget(target, action: #selector(target.invoke(_:)), for: controlEvents)
        
        let targets = bs_allUIControlBlockTargets()
        targets.add(target)
    }
    
    /**
     Adds or replaces a block for a particular event (or events) to an internal
     dispatch table. It will cause a strong reference to @a block.
     
     @param block          The block which is invoked then the action message is
     sent (cannot be nil). The block is retained.
     
     @param controlEvents  A bitmask specifying the control events for which the
     action message is sent.
     */
    @objc
    func setBlockForControlEvents(_ controlEvents: UIControl.Event, block: @escaping (_ sender: Any?) -> Void) {
        removeAllBlocks(forControlEvents: controlEvents)
        addBlock(forControlEvents: controlEvents, block: block)
    }
    
    /**
     Removes all blocks for a particular event (or events) from an internal
     dispatch table.
     
     @param controlEvents  A bitmask specifying the control events for which the
     action message is sent.
     */
    func removeAllBlocks(forControlEvents controlEvents: UIControl.Event) {
        
        let targets = bs_allUIControlBlockTargets()
        var removes: [AnyHashable] = []
        (targets as NSArray?)?.enumerateObjects({ obj, idx, stop in
            
            if let target = obj as? BSUIControlBlockTarget, target.events == controlEvents {
                removes.append(target)
                self.removeTarget(target, action: #selector(target.invoke(_:)), for: controlEvents)
            }
        })
        
        targets.removeObjects(in: removes)
    }
    
    private func bs_allUIControlBlockTargets() -> NSMutableArray {
        var targets = objc_getAssociatedObject(self, &block_key) as? NSMutableArray
        
        if targets == nil {
            targets = NSMutableArray()
            objc_setAssociatedObject(self, &block_key, targets, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        return targets!
    }
}

private var block_key: Int = 0

private class BSUIControlBlockTarget: NSObject {
    
    var block: ((_ sender: Any?) -> Void)?
    var events: UIControl.Event?
    
    init(block: @escaping (_ sender: Any?) -> Void, events: UIControl.Event) {
        super.init()
        
        self.block = block
        self.events = events
    }
    
    @objc func invoke(_ sender: Any?) {
        block?(sender)
    }
}
