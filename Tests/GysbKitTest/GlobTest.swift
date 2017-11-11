import XCTest
import GysbBase
import GysbKit
import Foundation
class GlobTest: XCTestCase {
    func testNSStringPath1() throws {
        let actual = NSString(string: "").appendingPathComponent("*.txt")
        let expected = "*.txt"
        XCTAssertEqual(actual, expected)
    }
    
    func testExpandGlobStar1() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/globstar")
        let actual = try expandGlobStar(pattern: "**/*.txt", in: testDir)
        XCTAssertEqual(actual, [
            "*.txt",
            "a/*.txt",
            "a/b/*.txt",
            "a/b/c/*.txt"
            ])
    }
    
    func testExpandGlobStar2() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/globstar")
        let actual = try expandGlobStar(pattern: "a/**/*.txt", in: testDir)
        XCTAssertEqual(actual, [
            "a/*.txt",
            "a/b/*.txt",
            "a/b/c/*.txt"
            ])
    }
    
    func testExpandGlobStar3() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/globstar")
        let actual = try expandGlobStar(pattern: "b/**/*.txt", in: testDir)
        XCTAssertEqual(actual, [
            "b/*.txt"
            ])
    }
    
    func testGlobStar() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/globstar")
        var actual = try glob(pattern: "**/*.txt", in: testDir).map { $0.relativePath }
        XCTAssertEqual(actual, [
            "a0.txt",
            "a/b0.txt",
            "a/b/c0.txt",
            "a/b/c/d0.txt"
            ])
        
        actual = try glob(pattern: "a/**/*.txt", in: testDir).map { $0.relativePath }
        XCTAssertEqual(actual, [
            "a/b0.txt",
            "a/b/c0.txt",
            "a/b/c/d0.txt"
            ])
        
        actual = try glob(pattern: "b/**/*.txt", in: testDir).map { $0.relativePath }
        XCTAssertEqual(actual, [
            ])
        
        actual = try glob(pattern: "**", in: testDir).map { $0.relativePath }
        XCTAssertEqual(actual, [
            "a",
            "a/b",
            "a/b/c"
            ])
    }
    
    static var allTests: [(String, (GlobTest) -> () throws -> Void)] {
        return [
            ("testNSStringPath1", testNSStringPath1),
            ("testExpandGlobStar1", testExpandGlobStar1),
            ("testExpandGlobStar2", testExpandGlobStar2),
            ("testExpandGlobStar3", testExpandGlobStar3),
            ("testGlobStar", testGlobStar)
        ]
    }
}

