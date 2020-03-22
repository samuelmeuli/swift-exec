// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "SwiftExec",
	platforms: [
		.macOS(.v10_13),
	],
	products: [
		.library(
			name: "SwiftExec",
			targets: ["SwiftExec"]
		),
	],
	dependencies: [],
	targets: [
		.target(
			name: "SwiftExec",
			dependencies: []
		),
		.testTarget(
			name: "SwiftExecTests",
			dependencies: ["SwiftExec"]
		),
	]
)
