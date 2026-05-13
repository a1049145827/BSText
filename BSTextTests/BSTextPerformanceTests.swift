import XCTest
@testable import BSText

final class BSTextPerformanceTests: XCTestCase {
    
    var textView: BSTextView!
    var largeText: String!
    
    override func setUp() {
        super.setUp()
        textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        largeText = generateLargeText()
    }
    
    override func tearDown() {
        textView = nil
        largeText = nil
        super.tearDown()
    }
    
    private func generateLargeText() -> String {
        var text = ""
        for i in 0..<1000 {
            text += "Line \(i): This is a test line for performance testing.\n"
        }
        return text
    }
    
    func testTextViewInitializationPerformance() {
        measure {
            let _ = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        }
    }
    
    func testTextSettingPerformance() {
        measure {
            textView.text = largeText
        }
    }
    
    func testLargeTextRenderingPerformance() {
        textView.text = largeText
        measure {
            let _ = textView.sizeThatFits(CGSize(width: 320, height: CGFloat.greatestFiniteMagnitude))
        }
    }
}

final class BSTextMarkdownPerformanceTests: XCTestCase {
    
    var parser: BSTextMarkdownParser!
    var largeMarkdown: String!
    
    override func setUp() {
        super.setUp()
        parser = BSTextMarkdownParser()
        largeMarkdown = generateLargeMarkdown()
    }
    
    override func tearDown() {
        parser = nil
        largeMarkdown = nil
        super.tearDown()
    }
    
    private func generateLargeMarkdown() -> String {
        var markdown = ""
        for i in 0..<100 {
            markdown += "# Heading \(i)\n"
            markdown += "**Bold text** with *italic* and `code` snippets.\n\n"
            markdown += "- List item 1\n- List item 2\n- List item 3\n\n"
        }
        return markdown
    }
    
    func testMarkdownParsingPerformance() {
        measure {
            let _ = parser.parse(largeMarkdown)
        }
    }
}

final class BSTextSyntaxPerformanceTests: XCTestCase {
    
    var parser: BSTextSyntaxParser!
    var largeCode: String!
    
    override func setUp() {
        super.setUp()
        parser = BSTextSyntaxParser()
        parser.language = .swift
        largeCode = generateLargeCode()
    }
    
    override func tearDown() {
        parser = nil
        largeCode = nil
        super.tearDown()
    }
    
    private func generateLargeCode() -> String {
        var code = "import Foundation\n\n"
        for i in 0..<50 {
            code += "func function\(i)(parameter: String) -> String {\n"
            code += "    let result = \"Result: \\(parameter)\"\n"
            code += "    return result\n"
            code += "}\n\n"
        }
        return code
    }
    
    func testSyntaxHighlightingPerformance() {
        measure {
            let _ = parser.parse(largeCode)
        }
    }
}

final class BSTextSearchIndexerPerformanceTests: XCTestCase {
    
    var indexer: BSTextSearchIndexer!
    var largeText: String!
    
    override func setUp() {
        super.setUp()
        indexer = BSTextSearchIndexer()
        largeText = generateLargeText()
    }
    
    override func tearDown() {
        indexer = nil
        largeText = nil
        super.tearDown()
    }
    
    private func generateLargeText() -> String {
        var text = ""
        for i in 0..<1000 {
            text += "Line \(i): This is a test line for performance testing with keyword \(i % 10).\n"
        }
        return text
    }
    
    func testIndexingPerformance() {
        measure {
            indexer.indexText(largeText)
        }
    }
    
    func testSearchPerformance() {
        indexer.indexText(largeText)
        measure {
            let _ = indexer.search("keyword")
        }
    }
}

final class BSTextCachePerformanceTests: XCTestCase {
    
    var cache: BSTextCache!
    let testKeys = (0..<1000).map { "key\($0)" }
    
    override func setUp() {
        super.setUp()
        cache = BSTextCache()
    }
    
    override func tearDown() {
        cache = nil
        super.tearDown()
    }
    
    func testCacheWritePerformance() {
        measure {
            for (index, key) in testKeys.enumerated() {
                cache.setObject("value\(index)" as AnyObject, forKey: key)
            }
        }
    }
    
    func testCacheReadPerformance() {
        for (index, key) in testKeys.enumerated() {
            cache.setObject("value\(index)" as AnyObject, forKey: key)
        }
        
        measure {
            for key in testKeys {
                _ = cache.object(forKey: key)
            }
        }
    }
}
