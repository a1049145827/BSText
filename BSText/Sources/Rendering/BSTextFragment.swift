//
//  BSTextFragment.swift
//  BSText
//
//  Custom text layout fragment with caching and async preparation support.
//

import UIKit

/// A custom text layout fragment that supports caching, async preparation,
/// and decoration rendering for viewport-based text display.
@objcMembers
open class BSTextFragment: NSTextLayoutFragment {

    /// Whether this fragment has been fully prepared for display.
    public private(set) var isPrepared: Bool = false

    /// Cached glyph layout data for this fragment.
    public private(set) var cachedLayout: NSTextLayoutFragment.Layout?

    /// Decoration renderers attached to this fragment.
    public var decorations: [BSTextDecoration] = []

    public override init(
        textElement: NSTextElement,
        range: NSRange
    ) {
        super.init(textElement: textElement, range: range)
    }

    /// Asynchronously prepare this fragment for display.
    open func prepareAsync() {
        // TODO: Implement async glyph layout
        // TODO: Decode attachments
        // TODO: Prepare decorations
    }

    /// Render decorations into the given context.
    /// - Parameter context: The graphics context to render into.
    open func renderDecorations(in context: CGContext) {
        for decoration in decorations {
            decoration.render(in: context, fragment: self)
        }
    }
}

/// Protocol for fragment decoration renderers.
@objc public protocol BSTextDecoration: AnyObject {
    /// Render the decoration into the given context.
    /// - Parameters:
    ///   - context: The graphics context.
    ///   - fragment: The fragment being decorated.
    func render(in context: CGContext, fragment: BSTextFragment)
}
