@testable import SwiftExec
import XCTest

final class SwiftExecTests: XCTestCase {
	func testExample() {
		XCTAssertEqual(SwiftExec().text, "Hello, World!")
	}

	static var allTests = [
		("testExample", testExample),
	]
}
