//
//  BSTextSnapshotTests.swift
//  BSTextTests
//
//  Snapshot tests for BSText components.
//

import XCTest
import UIKit
import BSText

@available(iOS 17.0, *)
class BSTextSnapshotTests: XCTestCase {
    
    var textView: BSTextView!
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        window = UIWindow(frame: UIScreen.main.bounds)
        textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 400))
        textView.backgroundColor = .white
        window.addSubview(textView)
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        textView = nil
        window = nil
        super.tearDown()
    }
    
    func testBasicText() {
        textView.text = "Hello, BSText!"
        textView.font = .systemFont(ofSize: 16)
        
        let image = textView.snapshot()
        XCTAssertNotNil(image, "Snapshot should not be nil")
    }
    
    func testAttributedText() {
        let attributedText = NSMutableAttributedString(string: "Bold Text", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.systemBlue
        ])
        attributedText.append(NSAttributedString(string: "\nNormal Text"))
        
        textView.attributedText = attributedText
        
        let image = textView.snapshot()
        XCTAssertNotNil(image, "Snapshot should not be nil")
    }
    
    func testMarkdownText() {
        let markdown = "# Heading\n\n**Bold** and *italic* text.\n\n- List item 1\n- List item 2"
        let parser = BSTextMarkdownParser()
        let attributedText = parser.parse(markdown)
        
        textView.attributedText = attributedText
        
        let image = textView.snapshot()
        XCTAssertNotNil(image, "Snapshot should not be nil")
    }
    
    func testCodeEditor() {
        let codeEditor = BSTextCodeEditor(frame: CGRect(x: 0, y: 0, width: 320, height: 400))
        codeEditor.language = .swift
        codeEditor.text = """
        func hello() {
            print("Hello, World!")
        }
        """
        window.addSubview(codeEditor)
        
        let image = codeEditor.snapshot()
        XCTAssertNotNil(image, "Snapshot should not be nil")
    }
    
    func testImageAttachment() {
        let attributedText = NSMutableAttributedString(string: "Text with image: ")
        
        let attachment = BSTextAttachment.imageAttachment(
            url: URL(string: "https://picsum.photos/100/100")!,
            displaySize: CGSize(width: 100, height: 100)
        )
        attributedText.append(NSAttributedString(attachment: attachment))
        
        textView.attributedText = attributedText
        
        let image = textView.snapshot()
        XCTAssertNotNil(image, "Snapshot should not be nil")
    }
    
    func testEmojiAttachment() {
        let attributedText = NSMutableAttributedString()
        
        let emojis = ["🎉", "🚀", "💡"]
        for emoji in emojis {
            let attachment = BSTextAttachment.emojiAttachment(emoji: emoji)
            attributedText.append(NSAttributedString(attachment: attachment))
            attributedText.append(NSAttributedString(string: " "))
        }
        
        textView.attributedText = attributedText
        
        let image = textView.snapshot()
        XCTAssertNotNil(image, "Snapshot should not be nil")
    }
    
    func testTableAttachment() {
        let markdownTable = """
        | Feature | Status |
        |---------|--------|
        | Text | ✅ |
        | Table | ✅ |
        """
        let tableAttachment = BSTextTableAttachment.tableAttachment(from: markdownTable)
        tableAttachment.displaySize = CGSize(width: 300, height: 100)
        
        if let tableImage = tableAttachment.renderTable() {
            tableAttachment.image = tableImage
            let attributedText = NSAttributedString(attachment: tableAttachment)
            textView.attributedText = attributedText
            
            let image = textView.snapshot()
            XCTAssertNotNil(image, "Snapshot should not be nil")
        }
    }
}

extension UIView {
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}