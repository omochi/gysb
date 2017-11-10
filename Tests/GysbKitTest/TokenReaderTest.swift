import XCTest
@testable import GysbKit
import Foundation
class TokenReaderTest: XCTestCase {
    func testTokenReader() {
        let source = [
            "abc",
            "def"
            ].joined(separator: "\n")
        let tr = TokenReader(source: source)
        
        XCTAssertEqual(tr.position.line, 1)
        XCTAssertEqual(tr.position.column, 1)
        var tk = tr.read()
        XCTAssertEqual(tk.description, "a")
        
        XCTAssertEqual(tr.position.line, 1)
        XCTAssertEqual(tr.position.column, 2)
        tk = tr.read()
        XCTAssertEqual(tk.description, "b")
        
        XCTAssertEqual(tr.position.line, 1)
        XCTAssertEqual(tr.position.column, 3)
        tk = tr.read()
        XCTAssertEqual(tk.description, "c")
        
        XCTAssertEqual(tr.position.line, 1)
        XCTAssertEqual(tr.position.column, 4)
        tk = tr.read()
        XCTAssertEqual(tk.description, "\n")
        
        XCTAssertEqual(tr.position.line, 2)
        XCTAssertEqual(tr.position.column, 1)
        tk = tr.read()
        XCTAssertEqual(tk.description, "d")
        
        XCTAssertEqual(tr.position.line, 2)
        XCTAssertEqual(tr.position.column, 2)
        tk = tr.read()
        XCTAssertEqual(tk.description, "e")
        
        XCTAssertEqual(tr.position.line, 2)
        XCTAssertEqual(tr.position.column, 3)
        tk = tr.read()
        XCTAssertEqual(tk.description, "f")

        XCTAssertEqual(tr.position.line, 2)
        XCTAssertEqual(tr.position.column, 4)
        tk = tr.read()
        XCTAssertEqual(tk.description, "")
        
        XCTAssertEqual(tr.position.line, 2)
        XCTAssertEqual(tr.position.column, 4)
        tk = tr.read()
        XCTAssertEqual(tk.description, "")
    }
}
