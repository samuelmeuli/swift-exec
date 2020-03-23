# SwiftExec

**Simple process execution with Swift**

## Install

To use SwiftExec with the [Swift Package Manager](https://swift.org/package-manager), add the following lines to your `Package.swift` file:

```swift
let package = Package(
	dependencies: [
		.package(url: "https://github.com/samuelmeuli/swift-exec", "0.1.0" ..< "0.2.0"),
	],
	targets: [
		.target(
			name: "MyProject",
			dependencies: [
				"SwiftExec",
			]
		),
	]
)
```

## Examples

### Simple command

```swift
import SwiftExec

do {
	let result = try exec(program: "/bin/echo", arguments: ["hello", "world"])
	print(result.stdout!)
} catch {
	print("Command failed")
}
```

### Advanced output handling

```swift
import SwiftExec

var result: ExecResult
do {
	result = try exec(program: "/usr/bin/git", arguments: ["status"])
} catch {
	let error = error as! ExecError
	result = error.execResult
}

print(result.exitCode!)
print(result.stdout!)
print(result.stderr!)
```

### Bash command

```swift
import SwiftExec

var result: ExecResult
do {
	result = try execBash("git status")
} catch {
	let error = error as! ExecError
	result = error.execResult
}

print(result.exitCode!)
print(result.stdout!)
print(result.stderr!)
```

## API

### Functions

SwiftExec provides the following functions:

- **`exec(program, arguments?, options?) -> ExecResult`** – Invokes the specified program in a new process using the provided arguments
  - `program: String` – Path to the program which should be executed (e.g. `"/bin/ls"`)
  - `arguments: [String] = []` – Arguments to pass to the program
  - `options: ExecOptions = ExecOptions()` – See [options](#options)
- **`execBash(command, options?) -> ExecResult`** – Runs the provided command using Bash. The function calls `exec` internally
  - `command: String` – Command which should be executed using Bash (e.g. `"echo 'hello world'"`)
  - `options: ExecOptions = ExecOptions()` – See [options](#options)

### Output

The `exec` function returns an instance of **`ExecResult`**, which contains the following fields:

- **`failed: Bool`** – Status of the executed command. It is considered to be failed if either the execution failed or the process returned a non-zero exit code
- **`message: String?`** – Error message for failed commands. Contains `stderr` if a non-zero exit code is the reason for the failure
- **`exitCode: Int32?`** – Exit code of the process that was executed
- **`stdout: String?`** – `stout` of the process that was executed
- **`stderr: String?`** – `stderr` of the process that was executed

### Options

The `exec` function behavior can be configured by passing in an instance of **`ExecOptions`**, with the following optional fields:

- **`cwd: URL?`** – Current working directory of the process
- **`stripFinalNewline: Bool = true`** – Whether to remove the final newline character from output

## Contributing

Suggestions and contributions are always welcome! Please discuss larger changes via issue before submitting a pull request.
