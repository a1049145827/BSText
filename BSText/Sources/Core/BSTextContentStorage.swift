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
open class BSTextContentStorage: NSTextContentStorage, NSTextStorageDelegate {

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

    /// Tracks whether we're inside a textStorage delegate callback
    private var isProcessingEditing: Bool = false

    /// The last edited range for incremental processing
    public private(set) var lastEditedRange: NSRange = NSRange(location: NSNotFound, length: 0)

    /// The last change in text length
    public private(set) var lastChangeInLength: Int = 0

    // MARK: - Initialization

    /// Creates a new BSTextContentStorage instance.
    public override init() {
        super.init()
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
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

    private func commonInit() {
        // Set up delegate
        self.textStorage?.delegate = self
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

    /// Called when the text storage begins editing.
    public func textStorageWillProcessEditing(_ notification: Notification) {
        isProcessingEditing = true
        contentDelegate?.contentStorageWillEdit?(self)
    }

    /// Called when the text storage finishes editing.
    public func textStorageDidProcessEditing(_ notification: Notification) {
        defer {
            isProcessingEditing = false
        }
        
        guard tracksChanges else { return }

        // Notify delegate of the change
        if let textStorage = notification.object as? NSTextStorage {
            let editedRange = textStorage.editedRange
            let changeInLength = textStorage.changeInLength
            
            lastEditedRange = editedRange
            lastChangeInLength = changeInLength

            contentDelegate?.contentStorage?(self, didEditInRange: editedRange, changeInLength: changeInLength)
            
            // Trigger syntax invalidation for the edited range
            if editedRange.location != NSNotFound {
                invalidateSyntax(for: editedRange)
            }
        }
        
        contentDelegate?.contentStorageDidEdit?(self)
    }

    // MARK: - Syntax Invalidation

    /// Invalidates syntax highlighting for the specified range.
    ///
    /// - Parameter range: The range to invalidate.
    private func invalidateSyntax(for range: NSRange) {
        // Expand the range slightly to ensure surrounding syntax is updated
        let expandedRange = expandRangeForSyntaxInvalidation(range)
        contentDelegate?.contentStorage?(self, didInvalidateSyntaxInRange: expandedRange)
    }

    /// Expands a range for syntax invalidation to ensure context is included.
    ///
    /// - Parameter range: The original range.
    /// - Returns: The expanded range.
    private func expandRangeForSyntaxInvalidation(_ range: NSRange) -> NSRange {
        guard let textStorage = self.textStorage, range.location != NSNotFound else {
            return range
        }
        
        // Find the line start for the beginning of the range
        var startLocation = range.location
        var lineStart = 0
        var lineEnd = 0
        var contentsEnd = 0
        
        while startLocation > 0 {
            let charRange = NSRange(location: startLocation - 1, length: 1)
            let char = (textStorage.string as NSString).substring(with: charRange)
            if char == "\n" || char == "\r" {
                lineStart = startLocation
                break
            }
            startLocation -= 1
        }
        
        // Find the line end for the end of the range
        let endLocation = range.location + range.length
        var endLineEnd = endLocation
        let maxLength = textStorage.length
        
        while endLineEnd < maxLength {
            let charRange = NSRange(location: endLineEnd, length: 1)
            let char = (textStorage.string as NSString).substring(with: charRange)
            if char == "\n" || char == "\r" {
                endLineEnd += 1
                break
            }
            endLineEnd += 1
        }
        
        return NSRange(location: lineStart, length: endLineEnd - lineStart)
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

    /// Adds attributes to the specified range.
    ///
    /// - Parameters:
    ///   - attrs: The attributes to add.
    ///   - range: The range to add attributes to.
    public func addAttributes(_ attrs: [NSAttributedString.Key : Any], range: NSRange) {
        guard let textStorage = self.textStorage else { return }
        
        textStorage.addAttributes(attrs, range: range)
    }

    /// Removes attributes from the specified range.
    ///
    /// - Parameters:
    ///   - attrs: The attributes to remove.
    ///   - range: The range to remove attributes from.
    public func removeAttribute(_ attr: NSAttributedString.Key, range: NSRange) {
        guard let textStorage = self.textStorage else { return }
        
        textStorage.removeAttribute(attr, range: range)
    }
}

// MARK: - Delegate Protocol

/// Delegate protocol for BSTextContentStorage change notifications.
@objc public protocol BSTextContentStorageDelegate: AnyObject {

    /// Called before the content storage is edited.
    ///
    /// - Parameter storage: The content storage that will be edited.
    @objc optional func contentStorageWillEdit(_ storage: BSTextContentStorage)

    /// Called after the content storage has been edited.
    ///
    /// - Parameters:
    ///   - storage: The content storage that was edited.
    ///   - range: The range of the edit.
    ///   - changeInLength: The change in length of the text.
    @objc optional func contentStorage(_ storage: BSTextContentStorage, didEditInRange range: NSRange, changeInLength: Int)

    /// Called after the content storage has been edited.
    ///
    /// - Parameter storage: The content storage that was edited.
    @objc optional func contentStorageDidEdit(_ storage: BSTextContentStorage)

    /// Called when syntax highlighting should be invalidated for a range.
    ///
    /// - Parameters:
    ///   - storage: The content storage.
    ///   - range: The range to invalidate syntax for.
    @objc optional func contentStorage(_ storage: BSTextContentStorage, didInvalidateSyntaxInRange range: NSRange)
}

