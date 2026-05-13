import XCTest
@testable import BSText

final class BSTextCoreTests: XCTestCase {
    
    var textView: BSTextView!
    
    override func setUp() {
        super.setUp()
        textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
    }
    
    override func tearDown() {
        textView = nil
        super.tearDown()
    }
    
    func testTextViewInitialization() {
        XCTAssertNotNil(textView)
        XCTAssertEqual(textView.backgroundColor, .systemBackground)
    }
    
    func testTextEditing() {
        let testText = "Hello, BSText!"
        textView.text = testText
        
        XCTAssertEqual(textView.text, testText)
    }
    
    func testTextReplacement() {
        textView.text = "Hello, World!"
        textView.selectedRange = NSRange(location: 7, length: 5)
        textView.replaceSelection(with: "BSText")
        
        XCTAssertEqual(textView.text, "Hello, BSText!")
    }
    
    func testClearAllText() {
        textView.text = "Hello, World!"
        textView.clearAllText()
        
        XCTAssertEqual(textView.text, "")
    }
    
    func testSelectAllText() {
        textView.text = "Hello, World!"
        textView.selectAllText()
        
        XCTAssertEqual(textView.selectedRange, NSRange(location: 0, length: textView.text.count))
    }
    
    func testVisibleFragmentCount() {
        textView.text = "Line 1\nLine 2\nLine 3\nLine 4\nLine 5"
        let count = textView.visibleFragmentCount
        XCTAssertGreaterThanOrEqual(count, 0)
    }
}

final class BSTextContentStorageTests: XCTestCase {
    
    var contentStorage: BSTextContentStorage!
    
    override func setUp() {
        super.setUp()
        contentStorage = BSTextContentStorage()
    }
    
    override func tearDown() {
        contentStorage = nil
        super.tearDown()
    }
    
    func testContentStorageInitialization() {
        XCTAssertNotNil(contentStorage)
    }
    
    func testTextStorageDelegation() {
        contentStorage.string = "Test Text"
        XCTAssertEqual(contentStorage.string, "Test Text")
    }
}

final class BSTextCacheTests: XCTestCase {
    
    var cache: BSTextCache!
    
    override func setUp() {
        super.setUp()
        cache = BSTextCache()
    }
    
    override func tearDown() {
        cache = nil
        super.tearDown()
    }
    
    func testCacheInitialization() {
        XCTAssertNotNil(cache)
    }
    
    func testCacheSetAndGet() {
        let key = "testKey"
        let value = "testValue"
        
        cache.setObject(value as AnyObject, forKey: key)
        
        let retrievedValue = cache.object(forKey: key) as? String
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testCacheRemove() {
        let key = "testKey"
        cache.setObject("value" as AnyObject, forKey: key)
        cache.removeObject(forKey: key)
        
        let retrievedValue = cache.object(forKey: key)
        XCTAssertNil(retrievedValue)
    }
    
    func testCacheRemoveAll() {
        cache.setObject("value1" as AnyObject, forKey: "key1")
        cache.setObject("value2" as AnyObject, forKey: "key2")
        cache.removeAllObjects()
        
        XCTAssertNil(cache.object(forKey: "key1"))
        XCTAssertNil(cache.object(forKey: "key2"))
    }
}
