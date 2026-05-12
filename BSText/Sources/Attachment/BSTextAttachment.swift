//
//  BSTextAttachment.swift
//  BSText 3.0
//
//  Modern attachment system supporting images, videos, views, and async loading.
//

import UIKit

/// A modern text attachment supporting multiple content types with
/// placeholder, async loading, and caching lifecycle.
@objcMembers
open class BSTextAttachment: NSTextAttachment {

    /// The type of attachment content.
    public var attachmentType: BSTextAttachmentType = .image

    /// The display size of the attachment.
    public var displaySize: CGSize = CGSize(width: 0, height: 0)

    /// The loading state of the attachment.
    public private(set) var state: State = .placeholder

    /// The attachment's identifier for caching.
    public var cacheKey: String?

    /// Loading states for an attachment.
    @objc public enum State: Int {
        /// Showing placeholder while loading.
        case placeholder = 0
        /// Currently loading content.
        case loading = 1
        /// Content loaded and ready to display.
        case loaded = 2
        /// Failed to load content.
        case failed = 3
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public convenience init(type: BSTextAttachmentType, size: CGSize) {
        self.init()
        self.attachmentType = type
        self.displaySize = size
    }
    
    public override init() {
        super.init()
    }

    /// Load the attachment content asynchronously.
    open func load() {
        state = .loading
        // TODO: Implement async loading based on attachmentType
        // TODO: Decode image/video
        // TODO: Update state to .loaded or .failed
    }

    /// Cancel any in-progress loading.
    open func cancelLoad() {
        // TODO: Cancel ongoing loading operations
    }
}
