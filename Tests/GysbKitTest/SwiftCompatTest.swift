//
//  NSStringTest.swift
//  GysbKitTest
//
//  Created by omochimetaru on 2017/11/11.
//

import XCTest
import Foundation
class SwiftCompatTest: XCTestCase {
    func testPathAppend1() throws {
        let actual = NSString(string: "").appendingPathComponentCompat("*.txt")
        let expected = "*.txt"
        XCTAssertEqual(actual, expected)
    }
    
    func testPathAppend2() throws {
        let actual = NSString(string: "a").appendingPathComponentCompat("*.txt")
        let expected = "a/*.txt"
        XCTAssertEqual(actual, expected)
    }
    
    static var allTests: [(String, (SwiftCompatTest) -> () throws -> Void)] {
        return [
            ("testPathAppend1", testPathAppend1),
            ("testPathAppend2", testPathAppend2),
        ]
    }
}
