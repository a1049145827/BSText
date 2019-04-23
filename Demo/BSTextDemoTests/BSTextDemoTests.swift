//
//  BSTextDemoTests.swift
//  BSTextDemoTests
//
//  Created by BlueSky on 2019/1/23.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import XCTest
@testable import BSTextDemo
@testable import BSText

class BSTextDemoTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        var color = UIColor.colorWith(hexString: "#F00")
        print(color)
        let red = UIColor.red
        print(red)
        XCTAssert(color == red, "test hex string to red color")
        
        color = UIColor.init(hex: 0xFF0000)
        XCTAssert(color == red, "test hex string to red color")
        
        color = UIColor.color(with: 0xFF0000)
        XCTAssert(color == red, "test hex string to red color")
        
        color = UIColor.colorWith(hexString: "0xFF0000")
        XCTAssert(color == red, "test hex string to red color")
        
        color = UIColor.colorWith(hexString: "#FF0000")
        XCTAssert(color == red, "test hex string to red color")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            for _ in 0..<10000 {
                let scanner = Scanner(string: "0X0000FF")
                scanner.scanLocation = 0
                var value: UInt64 = 0
                scanner.scanHexInt64(&value)
                
//                let r = (value & 0xFF0000) >> 16, g = (value & 0x00FF00) >> 8, b = value & 0x0000FF, a = 1
//                print((value & 0xFF0000) >> 16, (value & 0x00FF00) >> 8, value & 0x0000FF, 0)
            }
        }
    }
    
    func testPerformanceExample2() {
        self.measure {
            for _ in 0..<10000 {
                
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                
//                if hexStrToRGBA(str: "#FFFA", r: &r, g: &g, b: &b, a: &a) {
////                    print(r, g, b, a)
//                } else {
//                }
                XCTAssert(hexStrToRGBA(str: "#0000FF66", r: &r, g: &g, b: &b, a: &a), "parser failed")
                
//                print((value & 0xFF0000) >> 16)
//                print((value & 0x00FF00) >> 8)
//                print(value & 0x0000FF)
            }
        }
    }
    
    func testPerformanceExample3() {
        self.measure {
            for _ in 0..<10000 {
                let value = 0xFF0066
//                let r = (value & 0xFF0000) >> 16, g = (value & 0x00FF00) >> 8, b = value & 0x0000FF, a = 1
            }
        }
    }

}

/// Parse Hex String To RGBA Value
///
/// - Parameters:
///   - str: Hex String
///   - r: Memory Address for a CGFloat variable to receive the red value
///   - g: Memory Address for a CGFloat variable to receive the green value
///   - b: Memory Address for a CGFloat variable to receive the blue value
///   - a: Memory Address for a CGFloat variable to receive the alpha value
/// - Returns: Parse is success or not
fileprivate func hexStrToRGBA(str: String?, r: UnsafeMutablePointer<CGFloat>?, g: UnsafeMutablePointer<CGFloat>?, b: UnsafeMutablePointer<CGFloat>?, a: UnsafeMutablePointer<CGFloat>?) -> Bool {
    
    guard var s = str?.uppercased(), s.length > 3 else {
        // Not a Hex String
        return false
    }
    
    if s.hasPrefix("#") {
        s = s.subString(start: 1, end: s.length)
    } else if s.hasPrefix("0X") {
        s = s.subString(start: 2, end: s.length)
    }
    
    let length = s.length
    
    // RGB, RGBA, RRGGBB, RRGGBBAA
    if length != 3 && length != 4 && length != 6 && length != 8 {
        // Not a Hex String
        return false
    }
    
    // RGB, RGBA, RRGGBB, RRGGBBAA
    if length < 5 {
        r?.pointee = CGFloat((s.subString(start: 0, end: 1) + s.subString(start: 0, end: 1)).hexToInt()) / 255.0
        g?.pointee = CGFloat((s.subString(start: 1, end: 2) + s.subString(start: 1, end: 2)).hexToInt()) / 255.0
        b?.pointee = CGFloat((s.subString(start: 2, end: 3) + s.subString(start: 2, end: 3)).hexToInt()) / 255.0
        if length == 4 {
            a?.pointee = CGFloat((s.subString(start: 3, end: 4) + s.subString(start: 3, end: 4)).hexToInt()) / 255.0
        } else {
            a?.pointee = 1
        }
    } else {
        r?.pointee = CGFloat(s.subString(start: 0, end: 2).hexToInt()) / 255.0
        g?.pointee = CGFloat(s.subString(start: 2, end: 4).hexToInt()) / 255.0
        b?.pointee = CGFloat(s.subString(start: 4, end: 6).hexToInt()) / 255.0
        if length == 8 {
            a?.pointee = CGFloat(s.subString(start: 6, end: 8).hexToInt()) / 255.0
        } else {
            a?.pointee = 1
        }
    }
    
    return true
}
