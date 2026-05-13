import XCTest
@testable import BSText

final class BSTextAttachmentTests: XCTestCase {
    
    func testAttachmentInitialization() {
        let attachment = BSTextAttachment(type: .image)
        XCTAssertNotNil(attachment)
        XCTAssertEqual(attachment.attachmentType, .image)
    }
    
    func testAttachmentDisplaySize() {
        let attachment = BSTextAttachment(type: .image)
        let testSize = CGSize(width: 100, height: 100)
        attachment.displaySize = testSize
        
        XCTAssertEqual(attachment.displaySize.width, testSize.width)
        XCTAssertEqual(attachment.displaySize.height, testSize.height)
    }
    
    func testAttachmentState() {
        let attachment = BSTextAttachment(type: .image)
        XCTAssertEqual(attachment.state, .placeholder)
    }
}

final class BSTextMarkdownParserTests: XCTestCase {
    
    var parser: BSTextMarkdownParser!
    
    override func setUp() {
        super.setUp()
        parser = BSTextMarkdownParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    func testMarkdownParserInitialization() {
        XCTAssertNotNil(parser)
    }
    
    func testMarkdownParsing() {
        let markdownText = "# Heading 1\n**Bold Text**\n*Italic Text*"
        let attributedString = parser.parse(markdownText)
        
        XCTAssertNotNil(attributedString)
        XCTAssertGreaterThan(attributedString.length, 0)
    }
}

final class BSTextSyntaxParserTests: XCTestCase {
    
    var parser: BSTextSyntaxParser!
    
    override func setUp() {
        super.setUp()
        parser = BSTextSyntaxParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    func testSyntaxParserInitialization() {
        XCTAssertNotNil(parser)
    }
    
    func testSwiftSyntaxHighlighting() {
        let swiftCode = """
        func test() -> String {
            let message = "Hello, World!"
            return message
        }
        """
        
        parser.language = .swift
        let attributedString = parser.parse(swiftCode)
        
        XCTAssertNotNil(attributedString)
        XCTAssertGreaterThan(attributedString.length, 0)
    }
    
    func testMultipleLanguageSupport() {
        let testCodes: [(BSTextSyntaxLanguage, String)] = [
            (.swift, "let x = 5"),
            (.python, "x = 5"),
            (.javascript, "const x = 5"),
            (.json, "{\"key\": \"value\"}")
        ]
        
        for (language, code) in testCodes {
            parser.language = language
            let attributedString = parser.parse(code)
            XCTAssertNotNil(attributedString)
        }
    }
}

final class BSTextSyntaxThemeTests: XCTestCase {
    
    func testDefaultTheme() {
        let theme = BSTextSyntaxTheme.default
        XCTAssertNotNil(theme)
    }
    
    func testDarkTheme() {
        let theme = BSTextSyntaxTheme.dark
        XCTAssertNotNil(theme)
    }
    
    func testCustomTheme() {
        var theme = BSTextSyntaxTheme()
        theme.keywordColor = .red
        theme.stringColor = .green
        
        XCTAssertEqual(theme.keywordColor, .red)
        XCTAssertEqual(theme.stringColor, .green)
    }
}
