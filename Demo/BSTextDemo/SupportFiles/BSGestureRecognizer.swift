//
//  BSGestureRecognizer.swift
//  BSTextDemo
//
//  Created by BlueSky on 2019/1/22.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import UIKit

/// State of the gesture

enum BSGestureRecognizerState : Int {
    ///< gesture start
    case began
    ///< gesture moved
    case moved
    ///< gesture end
    case ended
    ///< gesture cancel
    case cancelled
}

/**
 A simple UIGestureRecognizer subclass for receive touch events.
 */
class BSGestureRecognizer: UIGestureRecognizer {
    
    private weak var _targetView: UIView?
    /// calculate point current location in with this view, defuat is self.view
    public weak var targetView: UIView? {
        set {
            _targetView = newValue
        }
        get {
            if (_targetView != nil) {
                return _targetView
            }
            return view
        }
    }
    
    ///< start point relative to self.targetView
    public private(set) var startPoint = CGPoint.zero
    
    ///< last move point relative to self.targetView
    public private(set) var lastPoint = CGPoint.zero
    
    ///< current move point relative to self.targetView
    public private(set) var currentPoint = CGPoint.zero
    
    /// The action block invoked by every gesture event.
    public var action: ((_ gesture: BSGestureRecognizer?, _ state: BSGestureRecognizerState) -> Void)?
    
    /// Cancel the gesture for current touch.
    public func cancel() {
        if state == .began || state == .changed {
            state = UIGestureRecognizer.State.cancelled
            if let action = action {
                action(self, .cancelled)
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        state = UIGestureRecognizer.State.began
        startPoint = touches.first?.location(in: targetView) ?? .zero
        lastPoint = currentPoint
        currentPoint = startPoint
        if let action = action {
            action(self, .began)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        
        let currentPoint = touches.first?.location(in: targetView) ?? .zero
        state = UIGestureRecognizer.State.changed
        self.currentPoint = currentPoint
        if let action = action {
            action(self, .moved)
        }
        lastPoint = self.currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = UIGestureRecognizer.State.ended
        if let action = action {
            action(self, .ended)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = UIGestureRecognizer.State.cancelled
        if let action = action {
            action(self, .cancelled)
        }
    }
    
    override func reset() {
        state = UIGestureRecognizer.State.possible
    }
}

