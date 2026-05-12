//
//  BSTextView.swift
//  BSText 3.0
//
//  The main text view class built on top of UITextView with TextKit 2.
//  BSText enhances UITextView with rich text capabilities, custom attachments,
//  and performance optimizations while relying on the system for IME, selection,
//  and input handling.
//

import UIKit

// BSTextView is built on top of UITextView with TextKit 2.
// System handles IME, selection, and input. BSText enhances with
// rich text capabilities and performance.
@objcMembers
open class BSTextView: UITextView {

    // MARK: - TextKit 2 Components

    /// The content storage that manages the attributed text content.
    public let contentStorage: BSTextContentStorage

    /// The layout manager responsible for laying out text fragments.
    public let layoutManager: BSTextLayoutManager

    /// The text container that defines the region where text is laid out.
    public let textContainer: NSTextContainer

    /// The viewport controller that manages visible range tracking
    /// and viewport-based layout optimization.
    public let viewportController: BSTextViewportController

    // MARK: - Private State

    /// Tracks whether TextKit 2 has been fully configured.
    private var isTextKit2Configured: Bool = false

    // MARK: - Initialization

    /// Initializes a text view with the specified frame.
    public override init(frame: CGRect, textContainer: NSTextContainer? = nil) {
        // Create the TextKit 2 components
        let contentStorage = BSTextContentStorage()
        let layoutManager = BSTextLayoutManager()
        let container = NSTextContainer()
        let viewportController = BSTextViewportController()

        self.contentStorage = contentStorage
        self.layoutManager = layoutManager
        self.textContainer = container
        self.viewportController = viewportController

        super.init(frame: frame, textContainer: container)

        commonInit()
    }

    /// Initializes a text view from Interface Builder / Storyboard.
    public required init?(coder: NSCoder) {
        let contentStorage = BSTextContentStorage()
        let layoutManager = BSTextLayoutManager()
        let container = NSTextContainer()
        let viewportController = BSTextViewportController()

        self.contentStorage = contentStorage
        self.layoutManager = layoutManager
        self.textContainer = container
        self.viewportController = viewportController

        super.init(coder: coder)

        commonInit()
    }

    // MARK: - Setup

    /// Shared setup logic called from all initializers.
    private func commonInit() {
        // Defer full TextKit 2 setup to becomeFirstResponder
        // to ensure the view hierarchy is ready.
    }

    /// Configures the TextKit 2 pipeline by linking content storage,
    /// layout manager, and text container together.
    ///
    /// Pipeline: NSTextContentStorage -> NSTextLayoutManager -> NSTextContainer
    private func setupTextKit2() {
        guard !isTextKit2Configured else { return }
        isTextKit2Configured = true

        // Link the TextKit 2 pipeline:
        // 1. Add text container to the layout manager
        layoutManager.addTextContainer(textContainer)

        // 2. Attach the layout manager to the content storage
        contentStorage.addLayoutManager(layoutManager)

        // 3. Configure viewport controller with the layout manager
        viewportController.attachLayoutManager(layoutManager)
    }

    // MARK: - UIResponder

    /// Sets up TextKit 2 on first responder if not already configured.
    open override func becomeFirstResponder() -> Bool {
        if !isTextKit2Configured {
            setupTextKit2()
        }
        return super.becomeFirstResponder()
    }
}
