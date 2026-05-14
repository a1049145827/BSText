//
//  BSTextAccessibility.swift
//  BSText 3.0
//
//  Accessibility support for BSText components.
//

import UIKit

/// Accessibility extensions for BSTextView.
extension BSTextView {
    
    /// Configures accessibility settings for the text view.
    public func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = "Text editor"
        accessibilityHint = "Double tap to edit"
        accessibilityTraits = .staticText
    }
    
    /// Updates accessibility label with current text content.
    public func updateAccessibilityLabel() {
        let textLength = text.count
        if textLength > 0 {
            let preview = text.prefix(50) + (textLength > 50 ? "..." : "")
            accessibilityLabel = "\(preview) (\(textLength) characters)"
        } else {
            accessibilityLabel = "Empty text editor"
        }
    }
    
    /// Posts accessibility notification when text changes.
    public func postTextChangeNotification() {
        UIAccessibility.post(notification: .layoutChanged, argument: self)
    }
}

/// Accessibility extensions for BSTextCodeEditor.
extension BSTextCodeEditor {
    
    /// Configures accessibility settings for the code editor.
    public override func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = "Code editor"
        accessibilityHint = "Double tap to edit code"
        accessibilityTraits = .staticText
    }
}

/// Accessibility container for text attachments.
@objcMembers
public class BSTextAttachmentAccessibilityElement: UIAccessibilityElement {
    
    /// The attachment this element represents.
    public weak var attachment: BSTextAttachment?
    
    /// The text view containing this attachment.
    public weak var textView: UIView?
    
    public init(accessibilityContainer: Any, attachment: BSTextAttachment, textView: UIView) {
        super.init(accessibilityContainer: accessibilityContainer)
        self.attachment = attachment
        self.textView = textView
        configure()
    }
    
    private func configure() {
        guard let attachment = attachment else {
            accessibilityLabel = "Attachment"
            accessibilityTraits = .staticText
            return
        }
        
        switch attachment.attachmentType {
        case .image:
            accessibilityLabel = "Image attachment"
            accessibilityTraits = .image
            
        case .animatedImage:
            accessibilityLabel = "Animated image"
            accessibilityTraits = .image
            
        case .video:
            accessibilityLabel = "Video attachment"
            accessibilityTraits = .staticText
            
        case .view:
            accessibilityLabel = "View attachment"
            accessibilityTraits = .staticText
            
        case .swiftUI:
            accessibilityLabel = "SwiftUI attachment"
            accessibilityTraits = .staticText
            
        default:
            accessibilityLabel = "Attachment"
            accessibilityTraits = .staticText
        }
    }
}

/// Accessibility delegate for BSTextView.
@objc public protocol BSTextAccessibilityDelegate: AnyObject {
    
    /// Called when accessibility element needs to be created for an attachment.
    ///
    /// - Parameters:
    ///   - textView: The text view.
    ///   - attachment: The attachment.
    ///   - frame: The frame of the attachment.
    /// - Returns: An accessibility element for the attachment.
    @objc optional func textView(_ textView: BSTextView, accessibilityElementFor attachment: BSTextAttachment, frame: CGRect) -> BSTextAttachmentAccessibilityElement?
}

/// Accessibility helper for managing attachment accessibility.
@objcMembers
public class BSTextAccessibilityManager: NSObject {
    
    /// The text view being managed.
    public weak var textView: BSTextView?
    
    /// Accessibility elements for attachments.
    public private(set) var attachmentElements: [BSTextAttachmentAccessibilityElement] = []
    
    public init(textView: BSTextView) {
        self.textView = textView
        super.init()
    }
    
    /// Updates accessibility elements for current attachments.
    public func updateAccessibilityElements() {
        attachmentElements.removeAll()
        
        guard let textView = textView else {
            return
        }
        
        let textStorage = textView.textStorage
        textStorage.enumerateAttribute(.attachment, in: NSRange(location: 0, length: textStorage.length)) { value, range, _ in
            if let attachment = value as? BSTextAttachment {
                let element = BSTextAttachmentAccessibilityElement(
                    accessibilityContainer: textView,
                    attachment: attachment,
                    textView: textView
                )
                attachmentElements.append(element)
            }
        }
    }
    
    /// Returns all accessibility elements.
    public func attachmentAccessibilityElements() -> [Any] {
        return attachmentElements
    }
}

/// Dynamic Type support extensions.
extension BSTextView {
    
    /// Enables dynamic type support.
    public func enableDynamicType() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContentSizeCategoryChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }
    
    /// Disables dynamic type support.
    public func disableDynamicType() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleContentSizeCategoryChange() {
        // Update font based on content size category
        let preferredFont = UIFont.preferredFont(forTextStyle: .body)
        font = preferredFont
    }
}