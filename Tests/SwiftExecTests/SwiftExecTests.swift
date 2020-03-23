@testable import SwiftExec
import XCTest

final class SwiftExecTests: XCTestCase {
	func testExecSuccess() throws {
		let result = try exec(
			program: "/bin/echo",
			arguments: ["hello", "world"]
		)
		XCTAssertEqual(result, ExecResult(
			failed: false,
			exitCode: 0,
			stdout: "hello world",
			stderr: ""
		))
	}

	func testExecFailure() throws {
		// Call `cp` without arguments to get a non-zero exit code and output in `stderr`. The
		// `exec` function should throw an error
		let expectedStderr = """
		usage: cp [-R [-H | -L | -P]] [-fi | -n] [-apvXc] source_file target_file
		       cp [-R [-H | -L | -P]] [-fi | -n] [-apvXc] source_file ... target_directory
		"""
		let expectedErrorMessage = "Command returned non-zero exit code (64):\n\n\(expectedStderr)"
		XCTAssertThrowsError(try exec(program: "/bin/cp")) { error in
			let execError = error as? ExecError
			XCTAssertEqual(
				execError?.localizedDescription,
				expectedErrorMessage
			)
			XCTAssertEqual(execError, ExecError(execResult: ExecResult(
				failed: true,
				message: expectedErrorMessage,
				exitCode: 64,
				stdout: "",
				stderr: expectedStderr
			)))
		}
	}

	func testExecMissingProgram() {
		// Error should be thrown if the specified program cannot be found
		XCTAssertThrowsError(
			try exec(program: "/bin/something", arguments: ["hello", "world"])
		) { error in
			let execError = error as? ExecError
			let expectedErrorMessage = "Program with URL \"/bin/something\" was not found"
			XCTAssertEqual(
				execError?.localizedDescription,
				expectedErrorMessage
			)
			XCTAssertEqual(execError, ExecError(execResult: ExecResult(
				failed: true,
				message: expectedErrorMessage
			)))
		}
	}

	func testExecCwd() throws {
		// Run `pwd` in home directory, should return home directory path
		let homeDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
		let result = try exec(program: "/bin/pwd", options: ExecOptions(cwd: homeDirectoryURL))
		XCTAssertEqual(result, ExecResult(
			failed: false,
			exitCode: 0,
			stdout: homeDirectoryURL.path,
			stderr: ""
		))
	}

	func testExecWithFinalNewline() throws {
		// Final newline character should not be removed if the corresponding option is set
		let result = try exec(
			program: "/bin/echo",
			arguments: ["hello", "world"],
			options: ExecOptions(stripFinalNewline: false)
		)
		XCTAssertEqual(result, ExecResult(
			failed: false,
			exitCode: 0,
			stdout: "hello world\n",
			stderr: ""
		))
	}

	func testExecBash() throws {
		let result = try execBash("echo hello world")
		XCTAssertEqual(result, ExecResult(
			failed: false,
			exitCode: 0,
			stdout: "hello world",
			stderr: ""
		))
	}

	static var allTests = [
		("testExecSuccess", testExecSuccess),
		("testExecFailure", testExecFailure),
		("testExecMissingProgram", testExecMissingProgram),
		("testExecCwd", testExecCwd),
		("testExecWithFinalNewline", testExecWithFinalNewline),
		("textExecBash", testExecBash),
	]
}
