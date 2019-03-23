import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StrongSelfRewriterTests.allTests),
    ]
}
#endif