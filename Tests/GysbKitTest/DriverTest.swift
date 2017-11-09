import XCTest
@testable import GysbKit
import Foundation
class DriverTest: XCTestCase {
    func test0() throws {
        let driver = Driver.init(path: "TestResources/vector.swift.gysb")
        let actual = try driver.render(to: .render)
        
        let expected = try String.init(contentsOfFile: "TestResources/vector_expected.swift", encoding: .utf8)
        XCTAssertEqual(actual, expected)
    }
}
