import XCTest
@testable import GysbKitTest

XCTMain([
     testCase(DriverTest.allTests),
     testCase(GlobTest.allTests),
     testCase(ParserTest.allTests),
     testCase(TokenReaderTest.allTests),
     testCase(ConfigTest.allTests),
     testCase(NSStringTest.allTests),
])