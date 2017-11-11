//
//  ParserTest.swift
//  GysbKitTest
//
//  Created by omochimetaru on 2017/11/11.
//

import XCTest
import GysbKit

class ParserTest: XCTestCase {
    func testErrorInfo() {
        let source = [
            "one is",
            "100%"
            ].joined(separator: "\n")
        let path = URL.init(fileURLWithPath: "aaa/bbb/ccc.gysb")
        let parser = Parser.init(source: source, path: path)
        
        do {
            let _ = try parser.parse()
            XCTFail("must throw")
        } catch let e {
            guard let e = e as? ParserError else {
                XCTFail("not parser error")
                return
            }
            XCTAssertEqual(e.line, 2)
            XCTAssertEqual(e.column, 4)
            print(e.description)
        }
    
    }
    
    static var allTests: [(String, (ParserTest) -> () throws -> Void)] {
        return [
            ("testErrorInfo", testErrorInfo)
        ]
    }

    
}
