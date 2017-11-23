import XCTest
@testable import GysbKitTest

XCTMain([
    testCase(SwiftCompatTests.allTests),
    testCase(GlobTests.allTests),
    testCase(ParserTests.allTests),
    testCase(TokenReaderTests.allTests),
    testCase(ConfigTests.allTests),
    testCase(DriverTests.allTests),
])