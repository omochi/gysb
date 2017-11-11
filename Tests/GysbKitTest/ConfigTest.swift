//
//  ConfigTest.swift
//  GysbKitTest
//
//  Created by omochimetaru on 2017/11/11.
//

import XCTest
import Foundation
import GysbKit

class ConfigTest: XCTestCase {
    
    func testSearch1() {
        let source = URL.init(fileURLWithPath: "Examples/simple_include/include.swift.gysb")
        let actual: URL? = Config.searchForSource(path: source)
        let expected = source.deletingLastPathComponent().appendingPathComponent("gysb.json")
        XCTAssertEqual(actual?.path, expected.path)
    }

    static var allTests: [(String, (ConfigTest) -> () throws -> Void)] {
        return [
            ("testSearch1", testSearch1)
        ]
    }
    
}
