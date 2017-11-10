import XCTest
import GysbBase
@testable import GysbKit
import Foundation
class GlobTest: XCTestCase {
    func testExpandGlobStar() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/globstar")
        var actual = try expandGlobStar(pattern: "**/*.txt", in: testDir)
        XCTAssertEqual(actual, [
            "*.txt",
            "a/*.txt",
            "a/b/*.txt",
            "a/b/c/*.txt"
            ])
        
        actual = try expandGlobStar(pattern: "a/**/*.txt", in: testDir)
        XCTAssertEqual(actual, [
            "a/*.txt",
            "a/b/*.txt",
            "a/b/c/*.txt"
            ])
        
        actual = try expandGlobStar(pattern: "b/**/*.txt", in: testDir)
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
}

