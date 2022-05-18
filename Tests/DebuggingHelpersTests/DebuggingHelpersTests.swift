import CustomDump
import OSLog
import XCTest

@testable import DebuggingHelpers

final class DebuggingHelpersTests: XCTestCase {
  func testLoggerModule() async throws {
    let logger = Logger.module(bundleIdentifier: "co.binaryscraping.swift-debugging-helpers")
    logger.info("Run test: \(#function)")

    if #available(iOS 15.0, *) {
      let entries: [OSLogEntryLog] = try await Logger.export(
        bundleIdentifier: "co.binaryscraping.swift-debugging-helpers")
      XCTAssertEqual(entries[0].category, "DebuggingHelpersTests")
      XCTAssertEqual(entries[0].subsystem, "co.binaryscraping.swift-debugging-helpers")
    }
  }
}
