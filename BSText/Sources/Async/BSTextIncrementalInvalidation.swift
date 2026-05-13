import UIKit

@objc public protocol BSTextIncrementalInvalidationDelegate: AnyObject {
    @objc optional func invalidationManager(_ manager: BSTextIncrementalInvalidation, didInvalidate ranges: [NSRange])
    @objc optional func invalidationManager(_ manager: BSTextIncrementalInvalidation, didCompleteInvalidation affectedRanges: [NSRange])
}

@objcMembers
open class BSTextIncrementalInvalidation: NSObject {
    
    public weak var delegate: BSTextIncrementalInvalidationDelegate?
    
    public var maxInvalidationBatchSize: Int = 1000
    
    public var coalescingInterval: TimeInterval = 0.1
    
    private var pendingInvalidations: [NSRange] = []
    private var coalescingTimer: Timer?
    private let queue = DispatchQueue(label: "com.bstext.invalidation")
    
    public func invalidate(_ ranges: [NSRange]) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            for range in ranges {
                self.pendingInvalidations.append(range)
            }
            
            self.pendingInvalidations = self.mergeRanges(self.pendingInvalidations)
            
            if self.pendingInvalidations.count > self.maxInvalidationBatchSize {
                self.processPendingInvalidations()
            } else {
                self.scheduleCoalescing()
            }
        }
    }
    
    private func scheduleCoalescing() {
        coalescingTimer?.invalidate()
        
        coalescingTimer = Timer.scheduledTimer(withTimeInterval: coalescingInterval, repeats: false) { [weak self] _ in
            self?.processPendingInvalidations()
        }
    }
    
    private func processPendingInvalidations() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let invalidations = self.pendingInvalidations
            self.pendingInvalidations = []
            
            DispatchQueue.main.async {
                if let delegate = self.delegate {
                    delegate.invalidationManager?(self, didInvalidate: invalidations)
                    
                    let affectedRanges = self.calculateAffectedRanges(invalidations)
                    delegate.invalidationManager?(self, didCompleteInvalidation: affectedRanges)
                }
            }
        }
    }
    
    private func mergeRanges(_ ranges: [NSRange]) -> [NSRange] {
        guard !ranges.isEmpty else { return [] }
        
        let sorted = ranges.sorted { $0.location < $1.location }
        var merged: [NSRange] = [sorted[0]]
        
        for i in 1..<sorted.count {
            let last = merged.last!
            let current = sorted[i]
            
            if current.location <= last.location + last.length {
                let newLocation = min(last.location, current.location)
                let newLength = max(last.location + last.length, current.location + current.length) - newLocation
                merged[merged.count - 1] = NSRange(location: newLocation, length: newLength)
            } else {
                merged.append(current)
            }
        }
        
        return merged
    }
    
    private func calculateAffectedRanges(_ ranges: [NSRange]) -> [NSRange] {
        var affected: [NSRange] = []
        
        for range in ranges {
            let expandedRange = NSRange(
                location: max(0, range.location - 1),
                length: range.length + 2
            )
            affected.append(expandedRange)
        }
        
        return mergeRanges(affected)
    }
    
    public func clearPending() {
        queue.async { [weak self] in
            self?.pendingInvalidations.removeAll()
            self?.coalescingTimer?.invalidate()
        }
    }
    
    deinit {
        coalescingTimer?.invalidate()
    }
}

public extension BSTextIncrementalInvalidation {
    static func invalidate(_ ranges: [NSRange], in textStorage: NSTextStorage) {
        let manager = BSTextIncrementalInvalidation()
        manager.delegate = InvalidationHandler(textStorage: textStorage)
        manager.invalidate(ranges)
    }
}

private class InvalidationHandler: NSObject, BSTextIncrementalInvalidationDelegate {
    private weak var textStorage: NSTextStorage?
    
    init(textStorage: NSTextStorage) {
        self.textStorage = textStorage
        super.init()
    }
    
    func invalidationManager(_ manager: BSTextIncrementalInvalidation, didInvalidate ranges: [NSRange]) {
        for range in ranges {
            textStorage?.processEditing()
        }
    }
    
    func invalidationManager(_ manager: BSTextIncrementalInvalidation, didCompleteInvalidation affectedRanges: [NSRange]) {
        // No additional action needed
    }
}
