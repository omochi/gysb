import XCTest
@testable import GysbKit
import Foundation
class DriverTest: XCTestCase {
    func testVector() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/vector")
        let driver = Driver.init(path: testDir.appendingPathComponent("vector.swift.gysb"))
        let actual = try driver.render(to: .render)
        
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("vector_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testVectorWrite() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/vector")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("vector.swift.gysb")],
                                 writeOnSame: true)
        try driver.run(to: .render)
        
        let actual = try String.init(contentsOf: testDir.appendingPathComponent("vector.swift"), encoding: .utf8)
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("vector_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
    
    func testYaml() throws {
        let testDir = URL.init(fileURLWithPath: "TestResources/yaml")
        let driver = Driver.init(paths: [testDir.appendingPathComponent("yaml.swift.gysb")],
                                 writeOnSame: true)
        try driver.run(to: .render)
        
        let actual = try String.init(contentsOf: testDir.appendingPathComponent("yaml.swift"), encoding: .utf8)
        let expected = try String.init(contentsOf: testDir.appendingPathComponent("yaml_expected.swift"), encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
}
