import XCTest
import GysbKit
import Foundation
class DriverTests: XCTestCase {
    func testSimple1() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/simple1")
        let driver = Driver.init(path: testDir.appendingPathComponent("a.txt.gysb"))
        let actual = try driver.render()
        
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("a_expected.txt"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testSimple1Write() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/simple1")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("a.txt.gysb")], writeOnSame: true)
        try driver.run()
        
        let actual = try String.init(contentsOf: testDir.appendingPathComponent("a.txt"), encoding: .utf8)
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("a_expected.txt"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testSimple2() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/simple2")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("b.swift.gysb")], writeOnSame: true)
        try driver.run()
        
        let actual = try String.init(contentsOf: testDir.appendingPathComponent("b.swift"), encoding: .utf8)
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("b_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testVector() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/vector")
        let driver = Driver.init(path: testDir.appendingPathComponent("vector.swift.gysb"))
        let actual = try driver.render()
        
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("vector_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testVectorWrite() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/vector")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("vector.swift.gysb")],
                                 writeOnSame: true)
        try driver.run()
        
        let actual = try String.init(contentsOf: testDir.appendingPathComponent("vector.swift"), encoding: .utf8)
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("vector_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testSimpleInclude() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/simple_include")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("include.swift.gysb")],
                                 writeOnSame: true)
        try driver.run()
        
        let actual = try String.init(contentsOf: testDir.appendingPathComponent("include.swift"), encoding: .utf8)
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("include_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testSameNameInclude() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/same_name_include")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("include.swift.gysb")],
                                 writeOnSame: true)
        try driver.run()
        
        let actual = try String.init(contentsOf: testDir.appendingPathComponent("include.swift"), encoding: .utf8)
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("include_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testRecursiveInclude() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/recursive_include")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("include.swift.gysb")],
                                 writeOnSame: true)
        try driver.run()
        
        let actual = try String.init(contentsOf: testDir.appendingPathComponent("include.swift"), encoding: .utf8)
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("include_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testYaml() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/yaml")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("yaml.swift.gysb")],
                                 writeOnSame: true)
        try driver.run()
        
        let actual = try String.init(contentsOf: testDir.appendingPathComponent("yaml.swift"), encoding: .utf8)
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("yaml_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testSharedConfig() throws {
        let testDir = URL.init(fileURLWithPath: "Examples/yaml")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("yaml.swift.gysb"),
                                         testDir.appendingPathComponent("yaml2.swift.gysb")],
                                 writeOnSame: true)
        try driver.run()
        
        var actual = try String.init(contentsOf: testDir.appendingPathComponent("yaml.swift"), encoding: .utf8)
        var expected = try String.init(contentsOf: testDir.appendingPathComponent("yaml_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
        
        actual = try String.init(contentsOf: testDir.appendingPathComponent("yaml2.swift"), encoding: .utf8)
        expected = try String.init(contentsOf: testDir.appendingPathComponent("yaml2_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testMultipleConfigGroup() throws {
        let testDir = URL.init(fileURLWithPath: "Examples")
        let driver = Driver.init(paths: [
            testDir.appendingPathComponent("simple1/a.txt.gysb"),
            testDir.appendingPathComponent("simple2/b.swift.gysb"),
            testDir.appendingPathComponent("yaml/yaml.swift.gysb"),
            testDir.appendingPathComponent("yaml/yaml2.swift.gysb")],
                                 writeOnSame: true)
        try driver.run()
        
        let pairs: [(String, String)] = [
            ("simple1/a.txt", "simple1/a_expected.txt"),
            ("simple2/b.swift", "simple2/b_expected.swift"),
            ("yaml/yaml.swift", "yaml/yaml_expected.swift"),
            ("yaml/yaml2.swift", "yaml/yaml2_expected.swift")
        ]
        
        for pair in pairs {
            let actual = try String.init(contentsOf: testDir.appendingPathComponent(pair.0), encoding: .utf8)
            let expected = try String.init(contentsOf: testDir.appendingPathComponent(pair.1), encoding: .utf8)
            XCTAssertEqual(actual, expected)
        }
    }
    
    static var allTests: [(String, (DriverTests) -> () throws -> Void)] {
        return [
            ("testSimple1", testSimple1),
            ("testSimple1Write", testSimple1Write),
            ("testSimple2", testSimple2),
            ("testVector", testVector),
            ("testVectorWrite", testVectorWrite),
            ("testSimpleInclude", testSimpleInclude),
            ("testSameNameInclude", testSameNameInclude),
            ("testRecursiveInclude", testRecursiveInclude),
            ("testYaml", testYaml),
            ("testSharedConfig", testSharedConfig),
            ("testMultipleConfigGroup", testMultipleConfigGroup)
        ]
    }
}
