// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "DebuggingHelpers",
  platforms: [.macOS(.v11), .iOS(.v14)],
  products: [
    .library(
      name: "DebuggingHelpers",
      targets: ["DebuggingHelpers"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.4.0")
  ],
  targets: [
    .target(
      name: "DebuggingHelpers",
      dependencies: [
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]),
    .testTarget(
      name: "DebuggingHelpersTests",
      dependencies: ["DebuggingHelpers"]),
  ]
)
