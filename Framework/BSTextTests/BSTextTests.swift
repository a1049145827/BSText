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

}
