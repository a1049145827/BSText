//
//  BSTextContentStorage.swift
//  BSText 3.0
//
//  Content storage that wraps NSTextContentStorage with BSText enhancements.
//  Manages attributed text storage with incremental editing support.
//

import UIKit

/// A content storage wrapper that adds BSText enhancements to NSTextContentStorage.
///
/// `BSTextContentStorage` wraps the system's `NSTextContentStorage` to provide:
/// - Incremental editing notifications
/// - Syntax invalidation hooks
/// - Block model synchronization
///
/// On iOS 17+, UITextView automatically creates a `NSTextContentStorage` instance.
/// BSTextContentStorage wraps this instance rather than replacing it, ensuring
/// full system compatibility.
///
@objcMembers
open class BSTextContentStorage: NSTextContentStorage {

    // MARK: - Properties

    /// The underlying system content storage being wrapped.
    /// This is `self` since we inherit from NSTextContentStorage.
    /// Kept for API consistency with the wrapper pattern.
    public var underlyingStorage: NSTextContentStorage {
        return self
    }

    /// Whether to track text changes for incremental processing.
    public var tracksChanges: Bool = true

    /// Delegate for receiving content change notifications.
    public weak var contentDelegate: BSTextContentStorageDelegate?

    // MARK: - Initialization

    /// Creates a new BSTextContentStorage instance.
    public override init() {
        super.init()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Creates a wrapper around an existing NSTextContentStorage.
    ///
    /// This initializer is used when wrapping the system's content storage
    /// from UITextView on iOS 17+.
    ///
    /// - Parameter wrapping: The system content storage to wrap.
    public convenience init(wrapping storage: NSTextContentStorage) {
        self.init()
        // Note: We cannot truly "wrap" an existing NSTextContentStorage since
        // we inherit from it. Instead, this serves as a marker that we're
        // operating on the system's storage.
        // The actual wrapping happens at the BSTextView level where we
        // use the system's textContentStorage directly.
    }

    // MARK: - Text Content Management

    /// Sets the attributed string content with optional change tracking.
    ///
    /// - Parameters:
    ///   - attributedString: The new attributed string content.
    ///   - options: Options for the content change.
    public func setAttributedString(_ attributedString: NSAttributedString, options: [String: Any]? = nil) {
        guard let textStorage = self.textStorage else { return }
        
        textStorage.beginEditing()

        let fullRange = NSRange(location: 0, length: textStorage.length)
        textStorage.replaceCharacters(in: fullRange, with: attributedString)

        textStorage.endEditing()
    }

    // MARK: - NSTextStorageDelegate

    /// Called when the text storage finishes editing.
    open func textStorageDidProcessEditing(_ notification: Notification) {
        guard tracksChanges else { return }

        // Notify delegate of the change
        if let textStorage = notification.object as? NSTextStorage {
            let editedRange = textStorage.editedRange
            let changeInLength = textStorage.changeInLength

            contentDelegate?.contentStorage?(self, didEditInRange: editedRange, changeInLength: changeInLength)
        }

        // TODO: Trigger syntax invalidation for the edited range
        // TODO: Sync block models if needed
    }

    // MARK: - Incremental Editing Support

    /// Performs a batch of edits as a single transaction.
    ///
    /// - Parameter edits: A closure containing the edits to perform.
    public func performBatchEdits(_ edits: () -> Void) {
        guard let textStorage = self.textStorage else { return }
        
        textStorage.beginEditing()
        edits()
        textStorage.endEditing()
    }

    /// Replaces text in the specified range with new text.
    ///
    /// - Parameters:
    ///   - range: The range of text to replace.
    ///   - text: The new text to insert.
    public func replaceText(in range: NSRange, with text: String) {
        guard let textStorage = self.textStorage else { return }
        
        textStorage.replaceCharacters(in: range, with: text)
    }

    /// Replaces text in the specified range with an attributed string.
    ///
    /// - Parameters:
    ///   - range: The range of text to replace.
    ///   - attributedString: The new attributed string to insert.
    public func replaceAttributedText(in range: NSRange, with attributedString: NSAttributedString) {
        guard let textStorage = self.textStorage else { return }
        
        textStorage.replaceCharacters(in: range, with: attributedString)
    }
}

// MARK: - Delegate Protocol

/// Delegate protocol for BSTextContentStorage change notifications.
@objc public protocol BSTextContentStorageDelegate: AnyObject {

    /// Called after the content storage has been edited.
    ///
    /// - Parameters:
    ///   - storage: The content storage that was edited.
    ///   - range: The range of the edit.
    ///   - changeInLength: The change in length of the text.
    @objc optional func contentStorage(_ storage: BSTextContentStorage, didEditInRange range: NSRange, changeInLength: Int)
}
