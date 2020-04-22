import Foundation

/// Custom error returned by the `exec` function
public struct ExecError: LocalizedError, Equatable {
	public var errorDescription: String? {
		execResult.message ?? "Process failed: Unknown error"
	}

	public var execResult: ExecResult

	public init(execResult: ExecResult) {
		self.execResult = execResult
	}
}

/// Options for customizing the behavior of the `exec` function
public struct ExecOptions {
	/// Current working directory of the process
	public let cwd: URL?

	/// Whether to remove the final newline character from output
	public let stripFinalNewline: Bool

	public init(cwd: URL? = nil, stripFinalNewline: Bool = true) {
		self.cwd = cwd
		self.stripFinalNewline = stripFinalNewline
	}
}

/// Results returned by the `exec` function
public struct ExecResult: Equatable {
	/// Status of the executed command. It is considered to be failed if either the execution failed
	/// or the process returned a non-zero exit code
	public let failed: Bool

	/// Error message for failed commands. Contains `stderr` if a non-zero exit code is the reason
	/// for the failure
	public let message: String?

	/// Exit code of the process that was executed
	public let exitCode: Int32?

	/// `stout` of the process that was executed
	public let stdout: String?

	/// `stderr` of the process that was executed
	public let stderr: String?

	public init(
		failed: Bool,
		message: String? = nil,
		exitCode: Int32? = nil,
		stdout: String? = nil,
		stderr: String? = nil
	) {
		self.failed = failed
		self.message = message
		self.exitCode = exitCode
		self.stdout = stdout
		self.stderr = stderr
	}
}

/// The `exec` function invokes the specified program in a new process using the provided (optional)
/// arguments. The process result is returned (`stdout` and `stderr` are converted to strings). If
/// the execution fails or the process returns a non-zero exit code, an error is thrown
public func exec(
	program programPath: String,
	arguments: [String] = [],
	options: ExecOptions = ExecOptions()
) throws -> ExecResult {
	guard FileManager.default.fileExists(atPath: programPath) else {
		throw ExecError(execResult: ExecResult(
			failed: true,
			message: "Program with URL \"\(programPath)\" was not found"
		))
	}
	let programUrl = URL(fileURLWithPath: programPath)

	// Create new process for the provided program and arguments
	let process = Process()
	process.executableURL = programUrl
	process.arguments = arguments
	if options.cwd != nil {
		process.currentDirectoryURL = options.cwd
	}

	// Create pipes for `stdout` and `stderr` so their content can be read later
	let outPipe = Pipe()
	let errPipe = Pipe()
	process.standardOutput = outPipe
	process.standardError = errPipe

	// Execute the process
	do {
		try process.run()
	} catch {
		throw ExecError(execResult: ExecResult(
			failed: true,
			message: "Process failed: \(error.localizedDescription)"
		))
	}

	let stdoutData = outPipe.fileHandleForReading.readDataToEndOfFile()
	let stderrData = errPipe.fileHandleForReading.readDataToEndOfFile()

	// Wait for process to finish. Must be called after `readDataToEndOfFile` because otherwise,
	// the process will hang if a pipe is full
	process.waitUntilExit()

	// Create strings with the contents of `stdout` and `stderr`
	var stdoutString = String(data: stdoutData, encoding: .utf8) ?? ""
	var stderrString = String(data: stderrData, encoding: .utf8) ?? ""
	if options.stripFinalNewline {
		if stdoutString.hasSuffix("\n") {
			stdoutString.removeLast()
		}
		if stderrString.hasSuffix("\n") {
			stderrString.removeLast()
		}
	}

	// Read, format and return the process result
	let exitCode = process.terminationStatus
	let failed = exitCode != 0
	if failed {
		var message = "Command returned non-zero exit code (\(exitCode))"
		if !stderrString.isEmpty {
			message.append(":\n\n\(stderrString)")
		}
		throw ExecError(execResult: ExecResult(
			failed: failed,
			message: message,
			exitCode: exitCode,
			stdout: stdoutString,
			stderr: stderrString
		))
	}
	return ExecResult(
		failed: failed,
		exitCode: exitCode,
		stdout: stdoutString,
		stderr: stderrString
	)
}

/// The `execBash` function runs the provided command using Bash
public func execBash(
	_ command: String,
	options: ExecOptions = ExecOptions()
) throws -> ExecResult {
	try exec(
		program: "/bin/bash",
		arguments: ["-c", command],
		options: options
	)
}
