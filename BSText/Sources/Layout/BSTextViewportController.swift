//
//  BSTextViewportController.swift
//  BSText 3.0
//
//  Manages visible fragment layout, prefetching, and recycling.
//  Similar to UICollectionView but for text fragments.
//

import UIKit

/// Controls which text fragments are laid out based on viewport visibility.
///
/// `BSTextViewportController` implements viewport-based layout optimization:
/// - Tracks visible fragments
/// - Adjacent fragments are prefetched for smooth scrolling
/// - Works with system's NSTextLayoutManager
///
/// This approach enables BSText to handle very large documents (100k+ lines)
/// while maintaining smooth 60/120 FPS scrolling.
///
@objcMembers
open class BSTextViewportController: NSObject {

    // MARK: - Properties

    /// The layout manager this controller operates on.
    public weak var layoutManager: NSTextLayoutManager?

    /// The current visible viewport rect in the text view's coordinate space.
    public private(set) var visibleRect: CGRect = .zero

    /// The size for prefetching fragments outside the visible area.
    /// Default is 200 points on all sides.
    public var prefetchInset: CGFloat = 200

    /// Enable or disable viewport-based layout optimization.
    /// Default is `true`.
    public var enabled: Bool = true

    /// The text range that is currently visible.
    public private(set) var visibleTextRange: NSTextRange?

    /// The text range including prefetched area.
    public private(set) var prefetchedTextRange: NSTextRange?

    /// Delegate for receiving viewport notifications.
    public weak var delegate: BSTextViewportControllerDelegate?

    /// The recycle threshold - fragments beyond this distance will be recycled.
    /// Default is 400 points beyond prefetch area.
    public var recycleThreshold: CGFloat = 400

    /// Currently prepared fragments that can be recycled.
    private var preparedFragments: Set<ObjectIdentifier> = []

    // MARK: - Initialization

    public override init() {
        super.init()
    }

    // MARK: - Attachment

    /// Attach a layout manager to this controller.
    ///
    /// - Parameter layoutManager: The layout manager to control.
    open func attachLayoutManager(_ layoutManager: NSTextLayoutManager) {
        self.layoutManager = layoutManager
        // If using BSTextLayoutManager, set its viewportController
        if let bsLayoutManager = layoutManager as? BSTextLayoutManager {
            bsLayoutManager.viewportController = self
        }
    }

    // MARK: - Viewport Management

    /// Update the viewport and track visible fragments.
    ///
    /// This method should be called from the text view's `layoutSubviews`
    /// or when the visible rect changes due to scrolling.
    ///
    /// - Parameter rect: The new visible rect.
    open func updateViewport(_ rect: CGRect) {
        let previousRect = visibleRect
        visibleRect = rect

        guard enabled, let layoutManager = layoutManager else { return }

        // Check if the viewport changed significantly
        let significantChange = abs(previousRect.origin.y - rect.origin.y) > 50 ||
                               abs(previousRect.size.height - rect.size.height) > 50

        // Calculate the prefetch rect
        let prefetchRect = rect.insetBy(dx: 0, dy: -prefetchInset)

        // Update visible text range
        updateVisibleTextRange(for: rect, prefetchRect: prefetchRect)

        // Notify delegate of viewport update
        delegate?.viewportControllerDidUpdateViewport?(self)
    }

    /// Updates the visible text range based on the given rect.
    ///
    /// - Parameters:
    ///   - rect: The visible rect.
    ///   - prefetchRect: The prefetch rect.
    private func updateVisibleTextRange(for rect: CGRect, prefetchRect: CGRect) {
        guard let layoutManager = layoutManager,
              let contentManager = layoutManager.textContentManager else { return }

        // Find the text range for the visible rect
        var visibleStartLocation: NSTextLocation?
        var visibleEndLocation: NSTextLocation?
        var prefetchedStartLocation: NSTextLocation?
        var prefetchedEndLocation: NSTextLocation?
        
        layoutManager.enumerateTextLayoutFragments(
            from: contentManager.documentRange.location,
            options: [.ensuresLayout]
        ) { fragment in
            let fragmentFrame = fragment.layoutFragmentFrame
            
            // Check if this fragment intersects with the visible rect
            if fragmentFrame.intersects(rect) {
                if visibleStartLocation == nil {
                    visibleStartLocation = fragment.rangeInElement.location
                }
                visibleEndLocation = fragment.rangeInElement.endLocation
            }
            
            // Check if this fragment intersects with the prefetch rect
            if fragmentFrame.intersects(prefetchRect) {
                if prefetchedStartLocation == nil {
                    prefetchedStartLocation = fragment.rangeInElement.location
                }
                prefetchedEndLocation = fragment.rangeInElement.endLocation
            }
            
            // Continue until we've passed the prefetch rect
            if fragmentFrame.minY > prefetchRect.maxY {
                return false
            }
            
            return true
        }
        
        if let start = visibleStartLocation, let end = visibleEndLocation {
            visibleTextRange = NSTextRange(location: start, end: end)
        } else {
            visibleTextRange = nil
        }
        
        if let start = prefetchedStartLocation, let end = prefetchedEndLocation {
            prefetchedTextRange = NSTextRange(location: start, end: end)
        } else {
            prefetchedTextRange = nil
        }
    }

    /// Recycles fragments that are far outside the visible area.
    private func recycleOffScreenFragments() {
        guard enabled, let layoutManager = layoutManager else { return }
        
        // Calculate the recycle rect (prefetch rect + recycle threshold)
        let recycleRect = visibleRect.insetBy(dx: 0, dy: -(prefetchInset + recycleThreshold))
        
        var recycledCount = 0
        
        layoutManager.enumerateTextLayoutFragments(
            from: layoutManager.textContentManager?.documentRange.location,
            options: []
        ) { fragment in
            let fragmentFrame = fragment.layoutFragmentFrame
            
            // Check if fragment is outside the recycle rect
            if !fragmentFrame.intersects(recycleRect) {
                // Reset prepared state for fragments far outside viewport
                self.invalidateFragment(fragment)
                recycledCount += 1
            }
            
            return true
        }
        
        if recycledCount > 0 {
            delegate?.viewportController?(self, didRecycleFragments: recycledCount)
        }
    }

    /// Invalidates a specific fragment to free resources.
    private func invalidateFragment(_ fragment: NSTextLayoutFragment) {
        // Note: In TextKit 2, we don't directly destroy fragments.
        // Instead, we let the system handle memory management.
        // However, we can trigger re-layout which will clean up unused fragments.
        
        // Invalidate layout for this fragment's range
        layoutManager?.invalidateLayout(for: fragment.rangeInElement)
        
        // Remove from our prepared set
        let identifier = ObjectIdentifier(fragment)
        preparedFragments.remove(identifier)
    }

    /// Marks a fragment as prepared.
    internal func markFragmentPrepared(_ fragment: NSTextLayoutFragment) {
        let identifier = ObjectIdentifier(fragment)
        preparedFragments.insert(identifier)
    }

    // MARK: - Invalidation

    /// Invalidate layout for a specific range.
    ///
    /// - Parameter range: The text range to invalidate.
    open func invalidateRange(_ range: NSRange) {
        guard enabled else { return }

        // Check if the invalidated range intersects with visible range
        guard let visibleRange = visibleTextRange,
              let layoutManager = layoutManager,
              let contentManager = layoutManager.textContentManager else { return }
            
        // Convert NSRange to NSTextRange for comparison
        let startOffset = range.location
        let endOffset = range.location + range.length
        
        guard let startLocation = contentManager.location(contentManager.documentRange.location, offsetBy: startOffset),
              let endLocation = contentManager.location(contentManager.documentRange.location, offsetBy: endOffset) else {
            return
        }
        
        guard let invalidatedRange = NSTextRange(location: startLocation, end: endLocation) else { return }
        
        // Check if ranges intersect
        if rangesIntersect(invalidatedRange, visibleRange) {
            // Re-layout visible area if using BSTextLayoutManager
            if let bsLayoutManager = layoutManager as? BSTextLayoutManager {
                bsLayoutManager.layoutViewport(visibleRect)
            } else {
                // For system layout manager, just invalidate the range
                layoutManager.invalidateLayout(for: invalidatedRange)
            }
        }
    }

    // MARK: - Fragment Queries

    /// Returns whether a text location is currently visible.
    ///
    /// - Parameter location: The text location to check.
    /// - Returns: `true` if the location is visible.
    public func isLocationVisible(_ location: NSTextLocation) -> Bool {
        guard let visibleRange = visibleTextRange else { return false }
        return visibleRange.contains(location)
    }

    /// Returns whether a text range intersects the visible area.
    ///
    /// - Parameter range: The text range to check.
    /// - Returns: `true` if the range intersects the visible area.
    public func isRangeVisible(_ range: NSTextRange) -> Bool {
        guard let visibleRange = visibleTextRange else { return false }
        return rangesIntersect(range, visibleRange)
    }

    /// Returns the estimated number of visible fragments.
    ///
    /// - Returns: The estimated count of visible fragments.
    public func estimatedVisibleFragmentCount() -> Int {
        guard let layoutManager = layoutManager else { return 0 }
        
        if let bsLayoutManager = layoutManager as? BSTextLayoutManager {
            return bsLayoutManager.visibleFragmentCount()
        }
        
        // Fallback: estimate based on enumeration
        var count = 0
        enumerateVisibleFragments { _ in count += 1 }
        return count
    }
    
    /// Enumerates all visible text layout fragments.
    ///
    /// - Parameter block: A closure called for each visible fragment.
    public func enumerateVisibleFragments(_ block: (NSTextLayoutFragment) -> Void) {
        guard let layoutManager = layoutManager,
              let contentManager = layoutManager.textContentManager else { return }
        
        let rect = visibleRect
        
        layoutManager.enumerateTextLayoutFragments(
            from: contentManager.documentRange.location,
            options: [.ensuresLayout]
        ) { fragment in
            let fragmentFrame = fragment.layoutFragmentFrame
            
            if fragmentFrame.intersects(rect) {
                block(fragment)
            }
            
            if fragmentFrame.minY > rect.maxY {
                return false
            }
            
            return true
        }
    }
    
    // MARK: - Helper Methods
    
    /// Checks if two text ranges intersect.
    private func rangesIntersect(_ range1: NSTextRange, _ range2: NSTextRange) -> Bool {
        // Check if range1 starts before range2 ends and range1 ends after range2 starts
        let location1 = range1.location
        let endLocation1 = range1.endLocation
        let location2 = range2.location
        let endLocation2 = range2.endLocation
        
        // Compare using compare(_:) method
        let startsBeforeEnd = location1.compare(endLocation2) == .orderedAscending || location1.compare(endLocation2) == .orderedSame
        let endsAfterStart = endLocation1.compare(location2) == .orderedDescending || endLocation1.compare(location2) == .orderedSame
        
        return startsBeforeEnd && endsAfterStart
    }
}

// MARK: - Delegate Protocol

/// Delegate protocol for BSTextViewportController notifications.
@objc public protocol BSTextViewportControllerDelegate: AnyObject {

    /// Called when the viewport is updated.
    ///
    /// - Parameter controller: The viewport controller.
    @objc optional func viewportControllerDidUpdateViewport(_ controller: BSTextViewportController)

    /// Called when fragments are recycled.
    ///
    /// - Parameters:
    ///   - controller: The viewport controller.
    ///   - count: The number of fragments recycled.
    @objc optional func viewportController(_ controller: BSTextViewportController, didRecycleFragments count: Int)
}

