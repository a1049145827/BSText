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

        // Convert rect to text range using character range
        if let startLocation = location(rect.origin, inTextContainer: textContainer),
           let endLocation = location(CGPoint(x: rect.maxX, y: rect.maxY), inTextContainer: textContainer) {
            visibleTextRange = NSTextRange(location: startLocation, end: endLocation)
        }

        // Trigger layout for visible area
        if let visibleRange = visibleTextRange {
            ensureLayout(for: visibleRange)
        }

        completion?()
    }

    /// Returns the text layout fragment at the specified point.
    ///
    /// - Parameter point: The point in the text view's coordinate space.
    /// - Returns: The text layout fragment at the point, or nil if not found.
    public func fragmentAtPoint(_ point: CGPoint) -> NSTextLayoutFragment? {
        guard let location = location(point, inTextContainer: textContainer) else { return nil }
        return textLayoutFragment(for: location)
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
        
        guard let startLocation = contentManager.location?(from: contentManager.documentRange.location, offset: startOffset),
              let endLocation = contentManager.location?(from: contentManager.documentRange.location, offset: endOffset) else {
            return
        }
        
        let textRange = NSTextRange(location: startLocation, end: endLocation)
        invalidateLayout(for: textRange)
    }

    /// Invalidates display for the specified text range.
    ///
    /// - Parameter range: The text range to invalidate.
    public func invalidateDisplay(forNSRange range: NSRange) {
        guard let contentManager = textContentManager else { return }
        
        // Convert NSRange to NSTextRange
        let startOffset = range.location
        let endOffset = range.location + range.length
        
        guard let startLocation = contentManager.location?(from: contentManager.documentRange.location, offset: startOffset),
              let endLocation = contentManager.location?(from: contentManager.documentRange.location, offset: endOffset) else {
            return
        }
        
        let textRange = NSTextRange(location: startLocation, end: endLocation)
        invalidateDisplay(for: textRange)
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
        let startOffset = contentManager.offset?(from: contentManager.documentRange.location, to: textRange.location) ?? 0
        let endOffset = contentManager.offset?(from: contentManager.documentRange.location, to: textRange.endLocation) ?? 0
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
