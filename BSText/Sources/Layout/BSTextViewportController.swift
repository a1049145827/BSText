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
/// - Only visible fragments are fully laid out
/// - Adjacent fragments are prefetched for smooth scrolling
/// - Off-screen fragments can be recycled to reduce memory
///
/// This approach enables BSText to handle very large documents (100k+ lines)
/// while maintaining smooth 60/120 FPS scrolling.
///
@objcMembers
open class BSTextViewportController: NSObject {

    // MARK: - Properties

    /// The layout manager this controller operates on.
    public weak var layoutManager: BSTextLayoutManager?

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

    // MARK: - Initialization

    public override init() {
        super.init()
    }

    // MARK: - Attachment

    /// Attach a layout manager to this controller.
    ///
    /// - Parameter layoutManager: The layout manager to control.
    open func attachLayoutManager(_ layoutManager: BSTextLayoutManager) {
        self.layoutManager = layoutManager
        layoutManager.viewportController = self
    }

    // MARK: - Viewport Management

    /// Update the viewport and trigger layout for visible fragments.
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
        updateVisibleTextRange(for: rect)

        // Trigger layout for visible and prefetched area
        layoutManager.layoutViewport(prefetchRect) { [weak self] in
            self?.delegate?.viewportControllerDidUpdateViewport?(self!)
        }

        // Recycle fragments that are far outside the visible area
        if significantChange {
            recycleOffScreenFragments()
        }
    }

    /// Updates the visible text range based on the given rect.
    ///
    /// - Parameter rect: The visible rect.
    private func updateVisibleTextRange(for rect: CGRect) {
        guard let layoutManager = layoutManager else { return }

        // Find the text range for the visible rect
        if let startFragment = layoutManager.textLayoutFragment(for: rect.origin),
           let startLocation = startFragment.rangeInElement.location {
            let endPoint = CGPoint(x: rect.maxX, y: rect.maxY)
            if let endFragment = layoutManager.textLayoutFragment(for: endPoint),
               let endLocation = endFragment.rangeInElement.endLocation {
                visibleTextRange = NSTextRange(location: startLocation, end: endLocation)
            }
        }
    }

    /// Recycles fragments that are far outside the visible area.
    private func recycleOffScreenFragments() {
        // TODO: Implement fragment recycling
        // This would involve:
        // 1. Identifying fragments outside the prefetch rect
        // 2. Moving them to a recycle pool
        // 3. Reusing them when new fragments are needed
    }

    // MARK: - Invalidation

    /// Invalidate layout for a specific range.
    ///
    /// - Parameter range: The text range to invalidate.
    open func invalidateRange(_ range: NSRange) {
        guard enabled else { return }

        // Check if the invalidated range intersects with visible range
        if let visibleRange = visibleTextRange,
           let layoutManager = layoutManager,
           let invalidatedRange = NSTextRange(range, in: layoutManager.textContentManager),
           invalidatedRange.overlaps(visibleRange) {
            // Re-layout visible area
            layoutManager.layoutViewport(visibleRect)
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
        return visibleRange.overlaps(range)
    }

    /// Returns the estimated number of visible fragments.
    ///
    /// - Returns: The estimated count of visible fragments.
    public func estimatedVisibleFragmentCount() -> Int {
        guard let layoutManager = layoutManager else { return 0 }
        return layoutManager.visibleFragmentCount()
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
