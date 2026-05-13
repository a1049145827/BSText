import XCTest
@testable import BSText

final class BSTextCodeEditorTests: XCTestCase {
    
    var codeEditor: BSTextCodeEditor!
    
    override func setUp() {
        super.setUp()
        codeEditor = BSTextCodeEditor(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
    }
    
    override func tearDown() {
        codeEditor = nil
        super.tearDown()
    }
    
    func testCodeEditorInitialization() {
        XCTAssertNotNil(codeEditor)
        XCTAssertEqual(codeEditor.language, .swift)
        XCTAssertTrue(codeEditor.showLineNumbers)
    }
    
    func testLanguageSwitching() {
        codeEditor.language = .javascript
        XCTAssertEqual(codeEditor.language, .javascript)
        
        codeEditor.language = .python
        XCTAssertEqual(codeEditor.language, .python)
    }
    
    func testLineNumberDisplay() {
        codeEditor.showLineNumbers = true
        XCTAssertTrue(codeEditor.showLineNumbers)
        
        codeEditor.showLineNumbers = false
        XCTAssertFalse(codeEditor.showLineNumbers)
    }
    
    func testIndentationWidth() {
        let testWidth = 8
        codeEditor.indentationWidth = testWidth
        XCTAssertEqual(codeEditor.indentationWidth, testWidth)
    }
    
    func testToggleFold() {
        codeEditor.text = """
        func test() {
            let x = 5
            return x
        }
        """
        
        let originalText = codeEditor.text
        codeEditor.toggleFold(at: 0)
        
        // 折叠不会改变原始文本，只是影响显示
        XCTAssertEqual(codeEditor.text, originalText)
    }
    
    func testFoldAll() {
        codeEditor.text = """
        func test1() {
            let x = 5
        }
        func test2() {
            let y = 10
        }
        """
        
        let originalText = codeEditor.text
        codeEditor.foldAll()
        
        XCTAssertEqual(codeEditor.text, originalText)
    }
    
    func testUnfoldAll() {
        codeEditor.text = """
        func test() {
            let x = 5
        }
        """
        
        codeEditor.foldAll()
        let afterFoldText = codeEditor.text
        codeEditor.unfoldAll()
        
        XCTAssertEqual(codeEditor.text, afterFoldText)
    }
    
    func testIsLineFolded() {
        codeEditor.text = """
        func test() {
            let x = 5
        }
        """
        
        codeEditor.toggleFold(at: 0)
        XCTAssertTrue(codeEditor.isLineFolded(0))
    }
    
    func testThemeSwitching() {
        let originalTheme = codeEditor.theme
        codeEditor.theme = .dark
        XCTAssertNotEqual(codeEditor.theme.keywordColor, originalTheme.keywordColor)
    }
}

final class BSTextSearchIndexerTests: XCTestCase {
    
    var indexer: BSTextSearchIndexer!
    
    override func setUp() {
        super.setUp()
        indexer = BSTextSearchIndexer()
    }
    
    override func tearDown() {
        indexer = nil
        super.tearDown()
    }
    
    func testSearchIndexerInitialization() {
        XCTAssertNotNil(indexer)
    }
    
    func testTextIndexing() {
        let testText = "Hello, World! This is a test text with some keywords: keyword1, keyword2, keyword1"
        indexer.indexText(testText)
        XCTAssertTrue(indexer.indexedWordCount > 0)
    }
    
    func testBasicSearch() {
        let testText = "Hello, World! This is a test text with some keywords: keyword1, keyword2, keyword1"
        indexer.indexText(testText)
        let results = indexer.search("keyword1")
        XCTAssertGreaterThan(results.count, 0)
    }
    
    func testRegexSearch() {
        let testText = "Test 1, Test 2, Test 3"
        indexer.indexText(testText)
        let results = indexer.searchWithRegex("Test \\d")
        XCTAssertGreaterThan(results.count, 0)
    }
    
    func testClearIndex() {
        let testText = "Hello, World!"
        indexer.indexText(testText)
        indexer.clearIndex()
        XCTAssertEqual(indexer.indexedWordCount, 0)
    }
    
    func testReplaceAll() {
        let testText = "Hello, World! Hello, World!"
        let textStorage = NSTextStorage(string: testText)
        indexer.indexText(testText)
        let count = indexer.replaceAllOccurrences(of: "World", with: "Everyone", in: textStorage)
        
        XCTAssertGreaterThan(count, 0)
    }
}

final class BSTextEditorCommandTests: XCTestCase {
    
    var textView: BSTextView!
    
    override func setUp() {
        super.setUp()
        textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
    }
    
    override func tearDown() {
        textView = nil
        super.tearDown()
    }
    
    func testInsertNewLine() {
        textView.text = "Hello, World!"
        textView.selectedRange = NSRange(location: textView.text.count, length: 0)
        textView.insertNewline()
        
        XCTAssertTrue(textView.text.contains("\n"))
    }
    
    func testSelectedText() {
        textView.text = "Hello, World!"
        textView.selectedRange = NSRange(location: 0, length: 5)
        let selected = textView.selectedText
        XCTAssertNotNil(selected)
        XCTAssertEqual(selected, "Hello")
    }
    
    func testSelectedAttributedText() {
        let attributedText = NSAttributedString(string: "Hello, World!")
        textView.textStorage.setAttributedString(attributedText)
        textView.selectedRange = NSRange(location: 0, length: 5)
        let selectedAttributed = textView.selectedAttributedText
        XCTAssertNotNil(selectedAttributed)
    }
    
    func testSelectRange() {
        textView.text = "Hello, World!"
        let testRange = NSRange(location: 0, length: 5)
        textView.selectRange(testRange)
        XCTAssertEqual(textView.selectedRange, testRange)
    }
    
    func testAttributesAtCursor() {
        textView.text = "Hello, World!"
        textView.selectedRange = NSRange(location: 0, length: 0)
        let attributes = textView.attributesAtCursor
        XCTAssertNotNil(attributes)
    }
}
