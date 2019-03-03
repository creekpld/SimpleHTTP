import XCTest

import SimpleHTTPTests

var tests = [XCTestCaseEntry]()
tests += SimpleHTTPTests.allTests()
XCTMain(tests)