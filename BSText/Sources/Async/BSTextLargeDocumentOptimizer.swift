import UIKit

@objc public protocol BSTextLargeDocumentOptimizerDelegate: AnyObject {
    @objc optional func optimizer(_ optimizer: BSTextLargeDocumentOptimizer, didUpdate visibleRange: NSRange)
    @objc optional func optimizer(_ optimizer: BSTextLargeDocumentOptimizer, didPrefetch ranges: [NSRange])
}

@objcMembers
open class BSTextLargeDocumentOptimizer: NSObject {
    
    public weak var delegate: BSTextLargeDocumentOptimizerDelegate?
    
    public var viewportSize: CGSize = CGSize(width: 320, height: 480)
    
    public var prefetchMargin: CGFloat = 200
    
    public var maxPrefetchLength: Int = 10000
    
    public var minVisibleLength: Int = 100
    
    private var currentVisibleRange = NSRange(location: 0, length: 0)
    private var isOptimizing = false
    
    public func updateVisibleRange(_ range: NSRange, in textStorage: NSTextStorage) {
        guard !isOptimizing else { return }
        
        isOptimizing = true
        
        defer { isOptimizing = false }
        
        currentVisibleRange = range
        
        if let delegate = self.delegate {
            delegate.optimizer?(self, didUpdate: range)
            
            let prefetchRanges = calculatePrefetchRanges(range, textStorage: textStorage)
            delegate.optimizer?(self, didPrefetch: prefetchRanges)
        }
    }
    
    private func calculatePrefetchRanges(_ visibleRange: NSRange, textStorage: NSTextStorage) -> [NSRange] {
        var prefetchRanges: [NSRange] = []
        
        let totalLength = textStorage.length
        
        let beforeRange = NSRange(
            location: max(0, visibleRange.location - maxPrefetchLength),
            length: min(maxPrefetchLength, visibleRange.location)
        )
        
        if beforeRange.length > minVisibleLength {
            prefetchRanges.append(beforeRange)
        }
        
        let afterRange = NSRange(
            location: visibleRange.location + visibleRange.length,
            length: min(maxPrefetchLength, totalLength - (visibleRange.location + visibleRange.length))
        )
        
        if afterRange.length > minVisibleLength {
            prefetchRanges.append(afterRange)
        }
        
        return prefetchRanges
    }
    
    public func optimizeLayout(for textView: UITextView) {
        let textContainer = textView.textContainer
        
        let visibleRect = textView.bounds
        let glyphRange = textView.layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let characterRange = textView.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        updateVisibleRange(characterRange, in: textView.textStorage)
    }
    
    public func reset() {
        currentVisibleRange = NSRange(location: 0, length: 0)
    }
}

public extension BSTextLargeDocumentOptimizer {
    static func optimize(_ textView: UITextView) {
        let optimizer = BSTextLargeDocumentOptimizer()
        optimizer.optimizeLayout(for: textView)
    }
}
