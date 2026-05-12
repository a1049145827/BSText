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
///                         ↓
///               BSTextViewportController
/// ```
///
@objcMembers
open class BSTextView: UITextView {

    // MARK: - TextKit 2 Components

    /// The content storage that manages the attributed text content.
    /// Wraps the system's `textContentStorage` with BSText enhancements.
    public var bsContentStorage: BSTextContentStorage? {
        return _contentStorage
    }

    /// The layout manager responsible for laying out text fragments.
    /// Wraps the system's `textLayoutManager` with BSText enhancements.
    public var bsLayoutManager: BSTextLayoutManager? {
        return _layoutManager
    }

    /// The viewport controller that manages visible fragment layout
    /// and viewport-based layout optimization.
    public let viewportController: BSTextViewportController

    // MARK: - Private Properties

    /// Internal storage wrapper.
    private var _contentStorage: BSTextContentStorage?

    /// Internal layout manager wrapper.
    private var _layoutManager: BSTextLayoutManager?

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

    /// Debug options for visual debugging.
    public var debugOptions: BSTextDebugOptions = []

    // MARK: - Initialization

    /// Initializes a text view with the specified frame.
    public override init(frame: CGRect, textContainer: NSTextContainer? = nil) {
        // Create viewport controller first
        viewportController = BSTextViewportController()

        // Initialize with TextKit 2 components if needed
        let container = textContainer ?? NSTextContainer(size: frame.size)
        container.widthTracksTextView = true
        container.heightTracksTextView = false

        // Initialize UITextView
        super.init(frame: frame, textContainer: container)

        // Set up BSText components
        setupBSText()
    }

    /// Initializes a text view from Interface Builder / Storyboard.
    public required init?(coder: NSCoder) {
        viewportController = BSTextViewportController()
        super.init(coder: coder)
        setupBSText()
    }

    // MARK: - Setup

    /// Sets up BSText enhancements.
    private func setupBSText() {
        guard !isBSTextConfigured else { return }
        isBSTextConfigured = true

        // Attach viewport controller to system layout manager if available
        if #available(iOS 17.0, *) {
            if let layoutManager = self.textLayoutManager {
                viewportController.attachLayoutManager(layoutManager)
            }
        }

        // Configure text container
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
    }

    // MARK: - View Lifecycle

    open override func layoutSubviews() {
        super.layoutSubviews()

        // Update viewport controller with current visible rect
        if viewportLayoutEnabled {
            let visibleRect = CGRect(
                x: contentOffset.x,
                y: contentOffset.y,
                width: bounds.width,
                height: bounds.height
            )
            viewportController.updateViewport(visibleRect)
        }
    }

    // MARK: - Drawing

    open override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Draw debug overlays if enabled
        if debugOptions.contains(.showFragments) {
            drawDebugFragments(in: rect)
        }
    }

    /// Draw debug overlay for fragments.
    private func drawDebugFragments(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()

        // Draw fragment bounds using system's layout manager if available
        if #available(iOS 17.0, *), let layoutManager = self.textLayoutManager {
            var fragmentCount = 0
            layoutManager.enumerateTextLayoutFragments(
                from: layoutManager.documentRange.location,
                options: []
            ) { fragment in
                let fragmentFrame = fragment.layoutFragmentFrame
                
                // Only draw if the fragment intersects the current rect
                guard fragmentFrame.intersects(rect) else { return true }

                // Draw fragment border
                UIColor.systemBlue.setStroke()
                context.setLineWidth(1)
                context.stroke(fragmentFrame)

                // Draw fragment label
                let labelText = "Fragment (\(Int(fragmentFrame.origin.x)), \(Int(fragmentFrame.origin.y)), \(Int(fragmentFrame.size.width)), \(Int(fragmentFrame.size.height)))"
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 8),
                    .foregroundColor: UIColor.systemBlue
                ]
                labelText.draw(at: CGPoint(x: fragmentFrame.minX + 2, y: fragmentFrame.minY + 2), withAttributes: attributes)
                
                fragmentCount += 1
                return true
            }
            
            // Draw fragment count
            let countLabel = "Fragments: \(fragmentCount)"
            let countAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 10),
                .foregroundColor: UIColor.red
            ]
            countLabel.draw(at: CGPoint(x: rect.minX + 5, y: rect.minY + 5), withAttributes: countAttributes)
        }

        context.restoreGState()
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
                textStorage.beginEditing()
                textStorage.replaceCharacters(in: NSRange(location: 0, length: textStorage.length), with: newValue ?? NSAttributedString())
                textStorage.endEditing()
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
                textStorage.beginEditing()
                textStorage.replaceCharacters(in: NSRange(location: 0, length: textStorage.length), with: attrString)
                textStorage.endEditing()
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
        // If there's an active IME composition, we need to be careful
        if markedTextRange != nil {
            // Let the composition finish first
            unmarkText()
        }

        textStorage.beginEditing()
        transform(textStorage)
        textStorage.endEditing()
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

        textStorage.beginEditing()
        textStorage.replaceCharacters(in: range, with: attachmentString)
        textStorage.endEditing()

        // Move cursor after the attachment
        selectedRange = NSRange(location: range.location + 1, length: 0)
    }

    /// Applies attributes to the selected range or typing attributes.
    ///
    /// - Parameter attributes: The attributes to apply.
    public func applyAttributes(_ attributes: [NSAttributedString.Key: Any]) {
        if selectedRange.length > 0 {
            textStorage.addAttributes(attributes, range: selectedRange)
        } else {
            // Apply to typing attributes
            typingAttributes.merge(attributes) { (_, new) in new }
        }
    }
    
    // MARK: - Viewport Helper
    
    /// Returns the number of visible fragments for debugging purposes.
    public var visibleFragmentCount: Int {
        return viewportController.estimatedVisibleFragmentCount()
    }
}

