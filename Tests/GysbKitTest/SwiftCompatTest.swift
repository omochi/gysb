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
    
    func testSubpaths1() throws {
        let fm = FileManager.default
        func isDir(_ str: String) -> Bool {
            var y: ObjCBool = false
            return fm.fileExists(atPath: str, isDirectory: &y) && y.boolValue
        }
        let dir = URL.init(fileURLWithPath: "TestResources/globstar")
        
        let subpaths = try fm.subpathsOfDirectory(atPath: dir.path)
        dump(subpaths)
        
        let actual: [String] = subpaths
            .filter { isDir(dir.appendingPathComponent($0).path) }
            .sorted()
        dump(actual)
        
        let expected = [
            "a",
            "a/b",
            "a/b/c"
        ]
        XCTAssertEqual(actual, expected)
    }
    
    static var allTests: [(String, (SwiftCompatTest) -> () throws -> Void)] {
        return [
            ("testPathAppend1", testPathAppend1),
            ("testPathAppend2", testPathAppend2),
            ("testSubpaths1", testSubpaths1)
        ]
    }
}
