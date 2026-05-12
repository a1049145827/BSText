//
//  BSTextTests.swift
//  BSTextTests
//
//  Created by BlueSky on 2018/10/22.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import XCTest
@testable import BSText

class BSTextTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLabelSizeThatFitsExpandsWhenTextOverflowsWithoutTruncationToken() {
        let label = BSLabel(frame: CGRect(x: 0, y: 0, width: 120, height: 44))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "BSText should measure all wrapped lines even when the current bounds are too short."

        let fittedSize = label.sizeThatFits(CGSize(width: 120, height: 44))

        XCTAssertGreaterThan(fittedSize.height, label.bounds.height)
    }

    func testLabelHighlightTapIsSuppressedWhenTouchIsCancelled() {
        XCTAssertFalse(BSLabel._shouldInvokeHighlightTap(wasTouchCancelled: true, touchMoved: false, touchStillInsideHighlight: true))
        XCTAssertTrue(BSLabel._shouldInvokeHighlightTap(wasTouchCancelled: false, touchMoved: false, touchStillInsideHighlight: true))
        XCTAssertTrue(BSLabel._shouldInvokeHighlightTap(wasTouchCancelled: false, touchMoved: true, touchStillInsideHighlight: true))
        XCTAssertFalse(BSLabel._shouldInvokeHighlightTap(wasTouchCancelled: false, touchMoved: true, touchStillInsideHighlight: false))
    }

    func testMarkdownParserDoesNotCrashWhenEscapingText() {
        let parser = TextSimpleMarkdownParser()
        let text = NSMutableAttributedString(string: "# Markdown Editor\nThis is **bold** text based on `BSTextView`.")

        XCTAssertTrue(parser.parseText(text, selectedRange: nil))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    // MARK: - Korean Input Composition Tests (Issue #35)

    func testKoreanInputCompositionViaSetMarkedText() {
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        // Step 1: Type first jamo "ㅇ"
        textView.setMarkedText("ㅇ", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(textView.markedTextRange, "markedTextRange should be set after first jamo")
        XCTAssertTrue(textView.text.contains("ㅇ"), "Text should contain the first jamo")

        // Step 2: Type second jamo "ㅏ" -> system composes to "아"
        textView.setMarkedText("아", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(textView.markedTextRange, "markedTextRange should remain set during composition")
        XCTAssertTrue(textView.text.contains("아"), "Text should contain the composed syllable '아'")
        XCTAssertFalse(textView.text.contains("ㅇㅏ"), "Text should NOT contain separate jamo 'ㅇㅏ'")

        // Step 3: Type third jamo "ㄴ" -> system composes to "안"
        textView.setMarkedText("안", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(textView.markedTextRange, "markedTextRange should remain set during composition")
        XCTAssertTrue(textView.text.contains("안"), "Text should contain the fully composed syllable '안'")
        XCTAssertFalse(textView.text.contains("아ㄴ"), "Text should NOT contain partially composed characters")
        XCTAssertFalse(textView.text.contains("ㅇㅏㄴ"), "Text should NOT contain separate jamo")

        // Step 4: Commit the composition
        textView.unmarkText()
        XCTAssertNil(textView.markedTextRange, "markedTextRange should be nil after unmarkText")
        XCTAssertTrue(textView.text.contains("안"), "Composed text '안' should remain after unmarking")
    }

    func testMarkedTextRangeBridgeIsWorking() {
        // Bug #1: _markedTextRange (private) was never set — all internal
        // checks that read it would always see nil, breaking caret clamping,
        // magnifier switching, and selection rendering.
        //
        // This test verifies that the public markedTextRange (now the
        // single source of truth) is readable after setMarkedText.
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        textView.setMarkedText("ㄱ", selectedRange: NSRange(location: 1, length: 0))

        let markedRange = textView.markedTextRange
        XCTAssertNotNil(markedRange, "markedTextRange must be non-nil so internal checks see it")
        XCTAssertFalse(markedRange!.isEmpty, "markedTextRange must not be empty")
    }

    func testInsertTextUnmarksWhenMarkedTextIsActive() {
        // Bug #3: insertText did not check for active marked text. If IME
        // commits via insertText (e.g. space after composition), the marked
        // state would be left dangling.
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        // Start a composition
        textView.setMarkedText("안", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(textView.markedTextRange, "markedTextRange should be set")

        // Insert a space (simulates user pressing space after composing)
        textView.insertText(" ")

        XCTAssertNil(textView.markedTextRange, "markedTextRange should be cleared after insertText with active marked text")
        XCTAssertTrue(textView.text.hasSuffix(" "), "Space should be inserted after the composed text")
    }

    func testInsertTextWithoutMarkedTextWorksNormally() {
        // insertText should work normally when no marked text is active
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        textView.insertText("A")
        XCTAssertEqual(textView.text, "A")
        XCTAssertNil(textView.markedTextRange)

        textView.insertText("B")
        XCTAssertEqual(textView.text, "AB")
    }

    func testMarkedTextStyleHasDefaultValue() {
        // Bug #2: markedTextStyle was nil by default. Korean IME may
        // check this property; if nil, it falls back to insertText per
        // jamo instead of using setMarkedText for composition.
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        XCTAssertNotNil(textView.markedTextStyle, "markedTextStyle should have a default value")
        let markedStyle = textView.markedTextStyle!
        XCTAssertNotNil(markedStyle[.backgroundColor], "markedTextStyle should include a background color")
    }

    func testUnmarkTextClearsMarkedRangeOnly() {
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        textView.setMarkedText("안", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(textView.markedTextRange)
        let textAfterComposition = textView.text

        textView.unmarkText()

        XCTAssertNil(textView.markedTextRange, "markedTextRange should be nil")
        XCTAssertEqual(textView.text, textAfterComposition, "unmarkText should preserve the composed text content")
    }

    func testEmptyMarkedTextClearsRange() {
        // Setting empty marked text should clear the marked range
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        textView.setMarkedText("ㅇ", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(textView.markedTextRange)

        textView.setMarkedText("", selectedRange: NSRange(location: 0, length: 0))
        XCTAssertNil(textView.markedTextRange, "Setting empty marked text should clear markedTextRange")
    }

    func testChinesePinyinInputStillWorks() {
        // Regression: Chinese Pinyin composition should also work
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        // Simulate typing "ni" -> "你"
        textView.setMarkedText("n", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(textView.markedTextRange)
        XCTAssertTrue(textView.text.contains("n"))

        textView.setMarkedText("ni", selectedRange: NSRange(location: 2, length: 0))
        XCTAssertNotNil(textView.markedTextRange)
        XCTAssertTrue(textView.text.contains("ni"))

        // User selects "你" from candidate list -> IME calls setMarkedText then unmarkText
        textView.setMarkedText("你", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(textView.markedTextRange)

        textView.unmarkText()
        XCTAssertNil(textView.markedTextRange)
        XCTAssertTrue(textView.text.contains("你"), "Text should contain the committed character")
    }

    func testJapaneseKanaInputStillWorks() {
        // Regression: Japanese Kana composition should also work
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        // Simulate typing "か" (ka)
        textView.setMarkedText("か", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(textView.markedTextRange)

        textView.unmarkText()
        XCTAssertNil(textView.markedTextRange)
        XCTAssertTrue(textView.text.contains("か"), "Text should contain the committed kana")
    }

    func testMultipleCompositionCycles() {
        // Multiple compose-unmark cycles should not corrupt state
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        // First word: 안녕
        textView.setMarkedText("안", selectedRange: NSRange(location: 1, length: 0))
        textView.unmarkText()
        textView.setMarkedText("녕", selectedRange: NSRange(location: 1, length: 0))
        textView.unmarkText()

        XCTAssertTrue(textView.text.contains("안녕"), "Text should contain both composed syllables")

        // Insert a space
        textView.insertText(" ")

        // Second word: 하세요
        textView.setMarkedText("하", selectedRange: NSRange(location: 1, length: 0))
        textView.unmarkText()
        textView.setMarkedText("세", selectedRange: NSRange(location: 1, length: 0))
        textView.unmarkText()
        textView.setMarkedText("요", selectedRange: NSRange(location: 1, length: 0))
        textView.unmarkText()

        XCTAssertTrue(textView.text.contains("안녕 하세요"), "Text should contain the full phrase")
        XCTAssertNil(textView.markedTextRange, "markedTextRange should be nil after final unmark")
    }
}
