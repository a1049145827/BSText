//
//  BSTextTypes.swift
//  BSText 3.0
//
//  Common types and protocols used throughout BSText 3.
//  Defines attachment types, loading protocols, and shared enums.
//

import UIKit
import SwiftUI

// MARK: - Attachment Types

/// Represents the type of content a text attachment can display.
/// Used by BSTextAttachment to determine rendering and loading behavior.
@objc public enum BSTextAttachmentType: Int {
    /// A static image attachment.
    case image
    /// An animated image attachment (e.g., GIF, APNG).
    case animatedImage
    /// A video attachment with playback support.
    case video
    /// A custom UIView embedded as an attachment.
    case view
    /// A SwiftUI view embedded as an attachment.
    case swiftUI
    /// An asynchronously loaded attachment (e.g., remote image).
    case async
}

// MARK: - Attachment Loading Protocol

/// A protocol for text attachments that support asynchronous loading.
///
/// Conforming types should implement `load()` to begin fetching or
/// decoding their content. The text view will call this method when
/// the attachment becomes visible in the viewport.
@objc public protocol BSTextAttachmentLoading: AnyObject {

    /// Begins loading the attachment content.
    /// Implementations should handle caching and error states internally.
    func load()
}

// MARK: - Viewport Controller Placeholder

/// Manages visible range tracking and viewport-based layout optimization.
/// Works in conjunction with BSTextLayoutManager to only lay out
/// text fragments that are currently visible on screen.
@objcMembers
public class BSTextViewportController: NSObject {

    /// The layout manager this viewport controller is attached to.
    private weak var attachedLayoutManager: BSTextLayoutManager?

    // MARK: - Initialization

    /// Creates a viewport controller with default settings.
    public override init() {
        super.init()
    }

    // MARK: - Attachment

    /// Attaches the viewport controller to the given layout manager.
    ///
    /// - Parameter layoutManager: The layout manager to track viewport for.
    public func attachLayoutManager(_ layoutManager: BSTextLayoutManager) {
        self.attachedLayoutManager = layoutManager
    }

    // MARK: - Viewport Management

    /// Updates the visible viewport rectangle.
    ///
    /// - Parameter rect: The visible rectangle in the text view's coordinate space.
    public func updateViewport(_ rect: CGRect) {
        // TODO: Implement viewport tracking and trigger layout for visible range
    }
}
