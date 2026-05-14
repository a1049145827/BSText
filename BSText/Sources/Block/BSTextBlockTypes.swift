//
//  BSTextBlockTypes.swift
//  BSText 3.0
//
//  Block types for block-based document editing.
//

import UIKit

/// The type of block content.
@objc public enum BSTextBlockType: Int {
    case paragraph = 0
    case heading1 = 1
    case heading2 = 2
    case heading3 = 3
    case bulletList = 4
    case orderedList = 5
    case blockquote = 6
    case code = 7
    case divider = 8
    case table = 9
}

/// A single block in a block-based document.
@objcMembers
public class BSTextBlock: NSObject {
    
    /// The type of this block.
    public let type: BSTextBlockType
    
    /// The attributed content of this block.
    public var attributedContent: NSAttributedString
    
    /// The plain text content.
    public var content: String {
        return attributedContent.string
    }
    
    /// Block-level metadata.
    public var metadata: [String: Any] = [:]
    
    /// Whether this block is selected.
    public var isSelected: Bool = false
    
    /// Block ID for identification.
    public let blockId: String
    
    public init(type: BSTextBlockType, attributedContent: NSAttributedString) {
        self.type = type
        self.attributedContent = attributedContent
        self.blockId = UUID().uuidString
        super.init()
    }
    
    public convenience init(type: BSTextBlockType, content: String) {
        self.init(type: type, attributedContent: NSAttributedString(string: content))
    }
}

/// A collection of blocks representing a document.
@objcMembers
public class BSTextBlockDocument: NSObject {
    
    /// The blocks in the document.
    public private(set) var blocks: [BSTextBlock] = []
    
    /// The currently selected block index.
    public var selectedBlockIndex: Int = -1
    
    /// Adds a block to the document.
    public func addBlock(_ block: BSTextBlock) {
        blocks.append(block)
    }
    
    /// Inserts a block at the specified index.
    public func insertBlock(_ block: BSTextBlock, at index: Int) {
        blocks.insert(block, at: index)
    }
    
    /// Removes a block at the specified index.
    public func removeBlock(at index: Int) {
        guard index >= 0 && index < blocks.count else { return }
        blocks.remove(at: index)
    }
    
    /// Moves a block from one position to another.
    public func moveBlock(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex >= 0 && sourceIndex < blocks.count,
              destinationIndex >= 0 && destinationIndex < blocks.count else {
            return
        }
        
        let block = blocks.remove(at: sourceIndex)
        blocks.insert(block, at: destinationIndex)
    }
    
    /// Returns the block at the specified index.
    public func block(at index: Int) -> BSTextBlock? {
        guard index >= 0 && index < blocks.count else { return nil }
        return blocks[index]
    }
    
    /// Returns the number of blocks.
    public func blockCount() -> Int {
        return blocks.count
    }
    
    /// Clears all blocks.
    public func clear() {
        blocks.removeAll()
    }
    
    /// Generates an attributed string representation of the document.
    public func attributedString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for (index, block) in blocks.enumerated() {
            result.append(block.attributedContent)
            
            // Add newline between blocks (except last)
            if index < blocks.count - 1 {
                result.append(NSAttributedString(string: "\n"))
            }
        }
        
        return result
    }
}