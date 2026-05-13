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
        let storage = NSTextStorage(string: "Test Text")
        XCTAssertEqual(storage.string, "Test Text")
    }
}

final class BSTextCacheTests: XCTestCase {
    
    var cache: BSTextCache!
    
    override func setUp() {
        super.setUp()
        cache = BSTextCache.shared
    }
    
    override func tearDown() {
        cache.removeAll()
        cache = nil
        super.tearDown()
    }
    
    func testCacheInitialization() {
        XCTAssertNotNil(cache)
    }
    
    func testImageCache() {
        let key = "testImageKey"
        let image = UIImage()
        
        cache.cacheImage(image, forKey: key, cost: 1000)
        let retrievedImage = cache.image(forKey: key)
        
        XCTAssertNotNil(retrievedImage)
    }
    
    func testCacheRemoveAll() {
        let image1 = UIImage()
        let image2 = UIImage()
        cache.cacheImage(image1, forKey: "key1", cost: 1000)
        cache.cacheImage(image2, forKey: "key2", cost: 1000)
        cache.removeAll()
        
        XCTAssertNil(cache.image(forKey: "key1"))
        XCTAssertNil(cache.image(forKey: "key2"))
    }
    
    func testCacheMaxCost() {
        XCTAssertEqual(cache.maxImageCacheCost, 100 * 1024 * 1024)
    }
    
    func testCacheMaxFragmentCount() {
        XCTAssertEqual(cache.maxFragmentCount, 100)
    }
}