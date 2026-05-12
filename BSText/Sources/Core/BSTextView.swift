//
//  BSTextView.swift
//  BSText 3.0
//
//  The main text view class built on top of UITextView with TextKit 2.
//  BSText enhances UITextView with rich text capabilities, custom attachments,
//  and performance optimizations while relying on the system for IME, selection,
//  and input handling.
//
//  Key principle: System handles IME, selection, and input.
//  BSText enhances with rich text capabilities and performance.
//

import UIKit

/// The main text view class for BSText 3.0.
///
/// `BSTextView` is built on top of `UITextView` with TextKit 2. It inherits all
/// system text editing capabilities including:
/// - IME (Input Method Editor) support for all languages (Korean, Japanese, Chinese, etc.)
/// - Selection management
/// - Keyboard input handling
/// - Accessibility support
/// - Apple Intelligence Writing Tools (iOS 18+)
///
/// BSText enhances the system text view with:
/// - Viewport-based layout optimization
/// - Fragment caching and recycling
/// - Async decoration rendering
/// - Rich text attachment system
/// - Markdown and syntax highlighting support
///
/// ## Usage
///
/// ```swift
/// let textView = BSTextView()
/// textView.text = "Hello, BSText 3.0!"
/// ```
///
/// ## TextKit 2 Pipeline
///
/// ```
/// NSTextContentStorage -> NSTextLayoutManager -> NSTextContainer
///         ↓                      ↓
///   BSTextContentStorage   BSTextLayoutManager
///                                ↓
///                       BSTextViewportController
/// ```
///
@objcMembers
open class BSTextView: UITextView {

    // MARK: - TextKit 2 Components

    /// The content storage that manages the attributed text content.
    /// Wraps the system's `textContentStorage` with BSText enhancements.
    public var bsContentStorage: BSTextContentStorage {
        return _contentStorage
    }

    /// The layout manager responsible for laying out text fragments.
    /// Wraps the system's `textLayoutManager` with BSText enhancements.
    public var bsLayoutManager: BSTextLayoutManager {
        return _layoutManager
    }

    /// The viewport controller that manages visible range tracking
    /// and viewport-based layout optimization.
    public let viewportController: BSTextViewportController

    // MARK: - Private Properties

    /// Internal storage wrapper.
    private var _contentStorage: BSTextContentStorage!

    /// Internal layout manager wrapper.
    private var _layoutManager: BSTextLayoutManager!

    /// Tracks whether custom TextKit 2 components have been configured.
    private var isBSTextConfigured: Bool = false

    // MARK: - Public Properties

    /// Whether viewport-based layout optimization is enabled.
    /// When enabled, only visible text fragments are laid out.
    /// Default is `true`.
    public var viewportLayoutEnabled: Bool = true {
        didSet {
            viewportController.enabled = viewportLayoutEnabled
        }
    }

    // MARK: - Initialization

    /// Initializes a text view with the specified frame.
    public override init(frame: CGRect, textContainer: NSTextContainer? = nil) {
        // Create viewport controller first
        viewportController = BSTextViewportController()

        // Initialize UITextView with a default text container
        // UITextView will create its own TextKit 2 pipeline on iOS 17+
        super.init(frame: frame, textContainer: textContainer)

        setupBSText()
    }

    /// Initializes a text view from Interface Builder / Storyboard.
    public required init?(coder: NSCoder) {
        viewportController = BSTextViewportController()
        super.init(coder: coder)
        setupBSText()
    }

    // MARK: - Setup

    /// Sets up BSText enhancements on top of the system TextKit 2 pipeline.
    ///
    /// On iOS 17+, UITextView uses TextKit 2 by default. We wrap the system's
    /// `textContentStorage` and `textLayoutManager` with BSText components
    /// to add our enhancements without breaking system functionality.
    private func setupBSText() {
        guard !isBSTextConfigured else { return }
        isBSTextConfigured = true

        // Get the system's TextKit 2 components
        // UITextView creates these automatically on iOS 17+
        guard let systemContentStorage = textContentStorage,
              let systemLayoutManager = textLayoutManager else {
            // Fallback: create our own if system didn't provide them
            setupCustomTextKit2()
            return
        }

        // Wrap system components with BSText enhancements
        _contentStorage = BSTextContentStorage(wrapping: systemContentStorage)
        _layoutManager = BSTextLayoutManager(wrapping: systemLayoutManager)

        // Attach viewport controller
        viewportController.attachLayoutManager(_layoutManager)

        // Configure text container
        if let container = textContainer {
            container.widthTracksTextView = true
            container.heightTracksTextView = false
        }
    }

    /// Sets up a custom TextKit 2 pipeline when system components are unavailable.
    ///
    /// This is a fallback path that should rarely be needed on iOS 17+.
    private func setupCustomTextKit2() {
        // Create custom TextKit 2 components
        let contentStorage = BSTextContentStorage()
        let layoutManager = BSTextLayoutManager()
        let container = NSTextContainer()

        // Configure text container
        container.widthTracksTextView = true
        container.heightTracksTextView = false

        // Link the pipeline: ContentStorage -> LayoutManager -> Container
        layoutManager.addTextContainer(container)
        contentStorage.addLayoutManager(layoutManager)

        // Store references
        _contentStorage = contentStorage
        _layoutManager = layoutManager

        // Attach viewport controller
        viewportController.attachLayoutManager(layoutManager)

        // Note: We cannot replace UITextView's internal components after initialization.
        // The system's textStorage will still be used for text content.
    }

    // MARK: - View Lifecycle

    open override func layoutSubviews() {
        super.layoutSubviews()

        // Update viewport controller with current visible rect
        if viewportLayoutEnabled {
            viewportController.updateViewport(visibleRect)
        }
    }

    // MARK: - Text Access

    /// The styled text content of the view.
    ///
    /// Setting this property replaces the entire text content.
    /// For incremental updates during IME composition, use the underlying
    /// `textStorage` methods directly.
    open override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            // During IME composition (markedTextRange != nil), avoid replacing
            // the entire attributed string as it breaks composition state.
            if markedTextRange != nil {
                // Use incremental update instead
                textStorage?.beginEditing()
                textStorage?.replaceCharacters(in: NSRange(location: 0, length: textStorage?.length ?? 0), with: newValue ?? NSAttributedString())
                textStorage?.endEditing()
            } else {
                super.attributedText = newValue
            }
        }
    }

    /// The plain text content of the view.
    open override var text: String! {
        get {
            return super.text
        }
        set {
            // During IME composition, use incremental update
            if markedTextRange != nil {
                let attrString = NSAttributedString(string: newValue ?? "", attributes: typingAttributes)
                textStorage?.beginEditing()
                textStorage?.replaceCharacters(in: NSRange(location: 0, length: textStorage?.length ?? 0), with: attrString)
                textStorage?.endEditing()
            } else {
                super.text = newValue
            }
        }
    }

    // MARK: - IME Safety

    /// Safely updates the text content without breaking IME composition.
    ///
    /// Use this method when you need to programmatically update text content
    /// while the user might be in the middle of an IME composition.
    ///
    /// - Parameter transform: A closure that transforms the current text storage.
    public func safeUpdateText(_ transform: (NSTextStorage) -> Void) {
        guard let storage = textStorage else { return }

        // If there's an active IME composition, we need to be careful
        if markedTextRange != nil {
            // Let the composition finish first
            unmarkText()
        }

        storage.beginEditing()
        transform(storage)
        storage.endEditing()
    }

    // MARK: - Rich Text Support

    /// Inserts an attachment at the current cursor position.
    ///
    /// - Parameters:
    ///   - attachment: The attachment to insert.
    ///   - attributes: Optional attributes to apply to the attachment.
    public func insertAttachment(_ attachment: BSTextAttachment, attributes: [NSAttributedString.Key: Any]? = nil) {
        let attachmentString = NSAttributedString(attachment: attachment)
        let range = selectedRange

        textStorage?.beginEditing()
        textStorage?.replaceCharacters(in: range, with: attachmentString)
        textStorage?.endEditing()

        // Move cursor after the attachment
        selectedRange = NSRange(location: range.location + 1, length: 0)
    }

    /// Applies attributes to the selected range or typing attributes.
    ///
    /// - Parameter attributes: The attributes to apply.
    public func applyAttributes(_ attributes: [NSAttributedString.Key: Any]) {
        guard let storage = textStorage else { return }

        if selectedRange.length > 0 {
            storage.addAttributes(attributes, range: selectedRange)
        } else {
            // Apply to typing attributes
            typingAttributes.merge(attributes) { (_, new) in new }
        }
    }
}
