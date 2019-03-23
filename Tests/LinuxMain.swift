import XCTest

import StrongSelfRewriterTests

var tests = [XCTestCaseEntry]()
tests += StrongSelfRewriterTests.allTests()
XCTMain(tests)