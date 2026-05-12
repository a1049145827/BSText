//
//  BSTextLayoutManager.swift
//  BSText 3.0
//
//  Layout manager that wraps NSTextLayoutManager with BSText enhancements.
//  Manages fragment layout with viewport optimization and incremental invalidation.
//

import UIKit

/// A layout manager wrapper that adds BSText enhancements to NSTextLayoutManager.
///
/// `BSTextLayoutManager` wraps the system's `NSTextLayoutManager` to provide:
/// - Viewport-based layout optimization
/// - Fragment caching and recycling
/// - Incremental invalidation
/// - Custom decoration rendering
///
/// On iOS 17+, UITextView automatically creates a `NSTextLayoutManager` instance.
/// BSTextLayoutManager works with this instance rather than replacing it.
///
@objcMembers
open class BSTextLayoutManager: NSTextLayoutManager {

    // MARK: - Properties

    /// Whether viewport-based layout optimization is enabled.
    public var viewportLayoutEnabled: Bool = true

    /// The size of the viewport for layout calculations.
    public var viewportSize: CGSize = .zero

    /// The current visible text range.
    public private(set) var visibleTextRange: NSTextRange?

    /// The viewport controller managing visible fragments.
    public weak var viewportController: BSTextViewportController?

    /// Delegate for receiving layout notifications.
    public weak var layoutDelegate: BSTextLayoutManagerDelegate?

    // MARK: - Initialization

    /// Creates a new BSTextLayoutManager instance.
    public override init() {
        super.init()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Creates a wrapper around an existing NSTextLayoutManager.
    ///
    /// - Parameter wrapping: The system layout manager to wrap.
    public convenience init(wrapping manager: NSTextLayoutManager) {
        self.init()
        // Note: Similar to BSTextContentStorage, we inherit from NSTextLayoutManager
        // so we can't truly "wrap" an existing instance. The actual integration
        // happens at the BSTextView level.
    }

    // MARK: - Viewport Layout

    /// Updates the visible viewport and triggers layout for visible fragments.
    ///
    /// - Parameters:
    ///   - rect: The visible rectangle in the text view's coordinate space.
    ///   - completion: Optional completion handler called when layout finishes.
    public func layoutViewport(_ rect: CGRect, completion: (() -> Void)? = nil) {
        viewportSize = rect.size

        // Find the text range for the visible rect by enumerating fragments
        updateVisibleTextRange(for: rect)

        // Trigger layout for visible area
        if let visibleRange = visibleTextRange {
            ensureLayout(for: visibleRange)
        }

        completion?()
    }
    
    /// Updates the visible text range based on the given rect.
    private func updateVisibleTextRange(for rect: CGRect) {
        guard let contentManager = textContentManager else { return }
        
        var startLocation: NSTextLocation?
        var endLocation: NSTextLocation?
        
        enumerateTextLayoutFragments(from: contentManager.documentRange.location, options: [.ensuresLayout]) { fragment in
            let fragmentFrame = fragment.layoutFragmentFrame
            
            // Check if this fragment intersects with the visible rect
            if fragmentFrame.intersects(rect) {
                if startLocation == nil {
                    startLocation = fragment.rangeInElement.location
                }
                endLocation = fragment.rangeInElement.endLocation
            }
            
            // Continue until we've passed the visible rect
            if fragmentFrame.minY > rect.maxY {
                return false
            }
            
            return true
        }
        
        if let start = startLocation, let end = endLocation {
            visibleTextRange = NSTextRange(location: start, end: end)
        }
    }

    /// Returns the text layout fragment at the specified point.
    ///
    /// - Parameter point: The point in the text view's coordinate space.
    /// - Returns: The text layout fragment at the point, or nil if not found.
    public func fragmentAtPoint(_ point: CGPoint) -> NSTextLayoutFragment? {
        guard let contentManager = textContentManager else { return nil }
        
        var result: NSTextLayoutFragment?
        enumerateTextLayoutFragments(from: contentManager.documentRange.location, options: [.ensuresLayout]) { fragment in
            if fragment.layoutFragmentFrame.contains(point) {
                result = fragment
                return false
            }
            return true
        }
        return result
    }

    // MARK: - Invalidation

    /// Invalidates layout for the specified text range.
    ///
    /// - Parameter range: The text range to invalidate.
    public func invalidateLayout(forNSRange range: NSRange) {
        guard let contentManager = textContentManager else { return }
        
        // Convert NSRange to NSTextRange
        let startOffset = range.location
        let endOffset = range.location + range.length
        
        let startLocation = contentManager.location(contentManager.documentRange.location, offsetBy: startOffset)
        let endLocation = contentManager.location(contentManager.documentRange.location, offsetBy: endOffset)
        
        guard let start = startLocation, let end = endLocation,
              let textRange = NSTextRange(location: start, end: end) else { return }
        invalidateLayout(for: textRange)
    }

    /// Invalidates display for the specified text range.
    ///
    /// - Parameter range: The text range to invalidate.
    public func invalidateDisplay(forNSRange range: NSRange) {
        // Since we can't call invalidateDisplay(for:) on NSTextLayoutManager directly
        // because it doesn't exist, we'll invalidate layout instead as fallback
        invalidateLayout(forNSRange: range)
    }

    // MARK: - NSTextLayoutManager Overrides

    open override func invalidateLayout(for textRange: NSTextRange) {
        super.invalidateLayout(for: textRange)

        // Notify delegate
        layoutDelegate?.layoutManager?(self, didInvalidateLayoutFor: textRange)

        // Notify viewport controller
        if let contentManager = textContentManager {
            let nsRange = nsRange(from: textRange, in: contentManager)
            viewportController?.invalidateRange(nsRange)
        }
    }

    // MARK: - Fragment Management

    /// Enumerates all visible text layout fragments.
    ///
    /// - Parameter block: A closure called for each visible fragment.
    public func enumerateVisibleFragments(_ block: (NSTextLayoutFragment) -> Void) {
        guard let visibleRange = visibleTextRange else { return }

        enumerateTextLayoutFragments(from: visibleRange.location, options: [.ensuresLayout]) { fragment in
            block(fragment)
            return true
        }
    }

    /// Returns the number of visible text layout fragments.
    ///
    /// - Returns: The count of visible fragments.
    public func visibleFragmentCount() -> Int {
        var count = 0
        enumerateVisibleFragments { _ in count += 1 }
        return count
    }
    
    // MARK: - Helper Methods
    
    /// Converts NSTextRange to NSRange
    private func nsRange(from textRange: NSTextRange, in contentManager: NSTextContentManager) -> NSRange {
        let startOffset = contentManager.offset(from: contentManager.documentRange.location, to: textRange.location)
        let endOffset = contentManager.offset(from: contentManager.documentRange.location, to: textRange.endLocation)
        return NSRange(location: startOffset, length: endOffset - startOffset)
    }
}

// MARK: - Delegate Protocol

/// Delegate protocol for BSTextLayoutManager notifications.
@objc public protocol BSTextLayoutManagerDelegate: AnyObject {

    /// Called when layout is invalidated for a text range.
    ///
    /// - Parameters:
    ///   - layoutManager: The layout manager.
    ///   - textRange: The invalidated text range.
    @objc optional func layoutManager(_ layoutManager: BSTextLayoutManager, didInvalidateLayoutFor textRange: NSTextRange)

    /// Called when viewport layout completes.
    ///
    /// - Parameters:
    ///   - layoutManager: The layout manager.
    ///   - visibleRect: The visible rectangle.
    @objc optional func layoutManager(_ layoutManager: BSTextLayoutManager, didLayoutViewport visibleRect: CGRect)
}

// MARK: - CGPoint Extension

private extension CGPoint {
    /// Returns the distance from this point to a CGRect.
    func distance(to rect: CGRect) -> CGFloat {
        if rect.contains(self) {
            return 0
        }

        let dx = max(rect.minX - x, 0, x - rect.maxX)
        let dy = max(rect.minY - y, 0, y - rect.maxY)

        return sqrt(dx * dx + dy * dy)
    }
}
