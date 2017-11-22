import XCTest
import GysbBase
import GysbKit
import Foundation
class GlobTests: XCTestCase {
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
    
    func testGlobStar1() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/globstar")
        let actual = try glob(pattern: "**/*.txt", in: testDir).map { $0.relativePath }
        XCTAssertEqual(actual, [
            "a0.txt",
            "a/b0.txt",
            "a/b/c0.txt",
            "a/b/c/d0.txt"
            ])
    }
    
    func testGlobStar2() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/globstar")
        let actual = try glob(pattern: "a/**/*.txt", in: testDir).map { $0.relativePath }
        XCTAssertEqual(actual, [
            "a/b0.txt",
            "a/b/c0.txt",
            "a/b/c/d0.txt"
            ])
    }
    
    func testGlobStar3() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/globstar")
        let actual = try glob(pattern: "b/**/*.txt", in: testDir).map { $0.relativePath }
        XCTAssertEqual(actual, [
            ])
    }
    
    func testGlobStar4() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/globstar")
        let actual = try glob(pattern: "**", in: testDir).map { $0.relativePath }
        XCTAssertEqual(actual, [
            "a",
            "a/b",
            "a/b/c"
            ])
    }
    
    static var allTests: [(String, (GlobTests) -> () throws -> Void)] {
        return [
            ("testExpandGlobStar1", testExpandGlobStar1),
            ("testExpandGlobStar2", testExpandGlobStar2),
            ("testExpandGlobStar3", testExpandGlobStar3),
            ("testGlobStar1", testGlobStar1),
            ("testGlobStar2", testGlobStar2),
            ("testGlobStar3", testGlobStar3),
            ("testGlobStar4", testGlobStar4)
        ]
    }
}

