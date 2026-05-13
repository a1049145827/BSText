//
//  BSTextFragment.swift
//  BSText 3.0
//
//  Custom text layout fragment with caching and async preparation support.
//

import UIKit

/// A custom text layout fragment that supports caching, async preparation,
/// and decoration rendering for viewport-based text display.
///
/// Note: This is a wrapper around NSTextLayoutFragment that adds additional
/// functionality without subclassing directly (since NSTextLayoutFragment has
/// restricted initialization).
@objcMembers
open class BSTextFragment: NSObject {

    // MARK: - Properties

    /// The underlying text layout fragment.
    public let textLayoutFragment: NSTextLayoutFragment

    /// Whether this fragment has been fully prepared for display.
    public private(set) var isPrepared: Bool = false

    /// Decoration renderers attached to this fragment.
    public var decorations: [BSTextDecoration] = []

    /// Cache identifier for this fragment.
    public var cacheIdentifier: String {
        guard let element = textLayoutFragment.textElement else {
            return "\(ObjectIdentifier(self))"
        }
        return "\(ObjectIdentifier(element))_\(textLayoutFragment.rangeInElement.location)"
    }

    /// The text range this fragment represents.
    public var nsRange: NSRange {
        guard let contentManager = textLayoutFragment.textLayoutManager?.textContentManager,
              let element = textLayoutFragment.textElement else {
            return NSRange(location: NSNotFound, length: 0)
        }
        let startOffset = contentManager.offset(from: contentManager.documentRange.location, to: textLayoutFragment.rangeInElement.location)
        let endOffset = contentManager.offset(from: contentManager.documentRange.location, to: textLayoutFragment.rangeInElement.endLocation)
        return NSRange(location: startOffset, length: endOffset - startOffset)
    }

    /// The layout fragment frame.
    public var layoutFragmentFrame: CGRect {
        return textLayoutFragment.layoutFragmentFrame
    }

    // MARK: - Initialization

    /// Creates a new BSTextFragment wrapping the given text layout fragment.
    ///
    /// - Parameter textLayoutFragment: The underlying text layout fragment.
    public init(textLayoutFragment: NSTextLayoutFragment) {
        self.textLayoutFragment = textLayoutFragment
        super.init()
    }

    public required init?(coder: NSCoder) {
        // Note: We don't support NSCoding for now
        return nil
    }

    // MARK: - Preparation

    /// Asynchronously prepares this fragment for display.
    open func prepareAsync() {
        // TODO: Implement async glyph layout
        // TODO: Decode attachments
        // TODO: Prepare decorations
        isPrepared = true
    }

    /// Synchronously prepares this fragment for display.
    open func prepare() {
        if !isPrepared {
            // TODO: Implement sync glyph layout
            // TODO: Prepare decorations
            isPrepared = true
        }
    }

    // MARK: - Rendering

    /// Renders decorations into the given context.
    ///
    /// - Parameter context: The graphics context to render into.
    open func renderDecorations(in context: CGContext) {
        guard !decorations.isEmpty else { return }

        context.saveGState()
        defer { context.restoreGState() }

        for decoration in decorations {
            decoration.render(in: context, fragment: self)
        }
    }

    // MARK: - Invalidations

    /// Invalidates the prepared state of this fragment.
    open func invalidate() {
        isPrepared = false
    }
}

// MARK: - Fragment Decoration

@objc public enum BSTextFragmentDecorationType: Int {
    case highlight = 0
    case underline = 1
    case strikethrough = 2
    case custom = 3
}

public struct BSTextFragmentDecoration {
    public let range: NSRange
    public let type: BSTextFragmentDecorationType
    public let color: UIColor?
    public let backgroundColor: UIColor?
    public let isUnderline: Bool
    public let baselineOffset: CGFloat
    public let font: UIFont?
    
    public init(range: NSRange, type: BSTextFragmentDecorationType, color: UIColor?, backgroundColor: UIColor?, isUnderline: Bool, baselineOffset: CGFloat, font: UIFont?) {
        self.range = range
        self.type = type
        self.color = color
        self.backgroundColor = backgroundColor
        self.isUnderline = isUnderline
        self.baselineOffset = baselineOffset
        self.font = font
    }
}

// MARK: - Delegate Protocol

/// Delegate protocol for fragment decoration renderers.
@objc public protocol BSTextDecoration: AnyObject {
    /// Renders the decoration into the given context.
    ///
    /// - Parameters:
    ///   - context: The graphics context.
    ///   - fragment: The fragment being decorated.
    func render(in context: CGContext, fragment: BSTextFragment)
}

// MARK: - Concrete Decorations

/// A simple background decoration for text fragments.
@objcMembers
open class BSTextBackgroundDecoration: NSObject, BSTextDecoration {
    /// The background color to render.
    public let color: UIColor

    public init(color: UIColor) {
        self.color = color
        super.init()
    }

    // MARK: - BSTextDecoration

    public func render(in context: CGContext, fragment: BSTextFragment) {
        let bounds = fragment.layoutFragmentFrame
        guard !bounds.isEmpty else { return }

        context.saveGState()
        defer { context.restoreGState() }

        context.setFillColor(color.cgColor)
        context.fill(bounds)
    }
}

/// A border decoration for text fragments.
@objcMembers
open class BSTextBorderDecoration: NSObject, BSTextDecoration {
    /// The border color.
    public let color: UIColor

    /// The border width.
    public let width: CGFloat

    /// The corner radius (if any).
    public let cornerRadius: CGFloat

    public init(color: UIColor, width: CGFloat = 1.0, cornerRadius: CGFloat = 0.0) {
        self.color = color
        self.width = width
        self.cornerRadius = cornerRadius
        super.init()
    }

    // MARK: - BSTextDecoration

    public func render(in context: CGContext, fragment: BSTextFragment) {
        var bounds = fragment.layoutFragmentFrame
        guard !bounds.isEmpty else { return }

        // Inset bounds to account for border width
        bounds = bounds.insetBy(dx: width / 2, dy: width / 2)

        context.saveGState()
        defer { context.restoreGState() }

        context.setStrokeColor(color.cgColor)
        context.setLineWidth(width)

        if cornerRadius > 0 {
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            path.stroke()
        } else {
            context.stroke(bounds)
        }
    }
}

