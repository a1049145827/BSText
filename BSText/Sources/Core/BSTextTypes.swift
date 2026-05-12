//
//  BSTextTypes.swift
//  BSText 3.0
//
//  Common types and protocols used throughout BSText 3.
//

import UIKit

// MARK: - Attachment Types

/// The type of content an attachment represents.
@objc public enum BSTextAttachmentType: Int {
    /// A static image.
    case image = 0
    /// An animated image (GIF, APNG, WebP).
    case animatedImage = 1
    /// A video attachment.
    case video = 2
    /// A UIView attachment.
    case view = 3
    /// A SwiftUI View attachment.
    case swiftUI = 4
    /// An asynchronously loaded attachment.
    case async = 5
}

// MARK: - Attachment Loading Protocol

/// Protocol for attachment loading lifecycle.
@objc public protocol BSTextAttachmentLoading: AnyObject {

    /// Begin loading the attachment content.
    func load()

    /// Cancel any in-progress loading.
    @objc optional func cancelLoad()
}

// MARK: - Text Position Types

/// Represents the vertical alignment of text within a line.
@objc public enum BSTextVerticalAlignment: Int {
    /// Align with the top of the line.
    case top = 0
    /// Align with the center of the line.
    case center = 1
    /// Align with the bottom of the line.
    case bottom = 2
}

// MARK: - Decoration Types

/// Represents the type of text decoration.
@objc public enum BSTextDecorationType: Int {
    /// A background highlight.
    case background = 0
    /// An underline.
    case underline = 1
    /// A strikethrough.
    case strikethrough = 2
    /// A border around the text.
    case border = 3
    /// A custom decoration.
    case custom = 4
}

// MARK: - Layout Direction

/// Represents the text layout direction.
@objc public enum BSTextLayoutDirection: Int {
    /// Left to right.
    case leftToRight = 0
    /// Right to left.
    case rightToLeft = 1
    /// Top to bottom.
    case topToBottom = 2
    /// Bottom to top.
    case bottomToTop = 3
}

// MARK: - Debug Helpers

/// Debug options for BSText.
public struct BSTextDebugOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Show layout fragment bounds.
    public static let showFragments = BSTextDebugOptions(rawValue: 1 << 0)

    /// Show text container bounds.
    public static let showTextContainer = BSTextDebugOptions(rawValue: 1 << 1)

    /// Show line fragment bounds.
    public static let showLineFragments = BSTextDebugOptions(rawValue: 1 << 2)

    /// Show selection rects.
    public static let showSelection = BSTextDebugOptions(rawValue: 1 << 3)

    /// Show all debug overlays.
    public static let all: BSTextDebugOptions = [.showFragments, .showTextContainer, .showLineFragments, .showSelection]
}
