import XCTest

#if !canImport(ObjectiveC)
	public func allTests() -> [XCTestCaseEntry] {
		[
			testCase(SwiftExecTests.allTests),
		]
	}
#endif
