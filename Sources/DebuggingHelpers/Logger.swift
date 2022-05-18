import CustomDump
import OSLog

extension Logger {
  /// Logger instance specific for the current module.
  /// - Parameters:
  ///   - bundleIdentifier: The bundleID for this application, defaults to `Bundle.main.bundleIdentifier`.
  ///   - fileID: The fileID where this method was called, this is used for automatically extracting the module name, this should not be overriden.
  /// - Returns: Logger instance specific for the current module.
  public static func module(
    bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "",
    _ fileID: String = #fileID
  ) -> Logger {
    Logger(
      subsystem: bundleIdentifier,
      category: fileID.components(separatedBy: "/")[0]
    )
  }

  /// Globally enable/disable tracing.
  public static var tracingEnabled = true

  @discardableResult
  public func tracing<R>(
    _ name: String = "",
    function: String = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    block: () async throws -> R
  ) async rethrows -> R {
    guard Logger.tracingEnabled else {
      return try await block()
    }

    var messageComponents: [String] = []

    if !name.isEmpty {
      messageComponents.append("[\(name)]")
    }

    messageComponents.append("\(file).\(function):\(line)")
    let message = messageComponents.joined(separator: " ")

    self.trace("Start: \(message)")
    do {
      let result = try await block()
      var output = ""
      customDump(result, to: &output)
      self.debug("End: \(message) | Success: \(output)")
      return result
    } catch {
      self.debug("End: \(message) | Failure: \(error.localizedDescription)")
      throw error
    }
  }

  @discardableResult
  public func tracing<R>(
    _ name: String = "",
    function: String = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    block: () throws -> R
  ) rethrows -> R {
    guard Logger.tracingEnabled else {
      return try block()
    }

    var messageComponents: [String] = []

    if !name.isEmpty {
      messageComponents.append("[\(name)]")
    }

    messageComponents.append("\(file).\(function):\(line)")
    let message = messageComponents.joined(separator: " ")

    self.trace("Start: \(message)")
    do {
      let result = try block()
      var output = ""
      customDump(result, to: &output)
      self.debug("End: \(message) | Success: \(output)")
      return result
    } catch {
      self.debug("End: \(message) | Failure: \(error.localizedDescription)")
      throw error
    }
  }

  @available(iOS 15.0, *)
  public static func export(
    bundleIdentifier: String = Bundle.main.bundleIdentifier ?? ""
  ) async throws -> [OSLogEntryLog] {
    let store = try OSLogStore(scope: .currentProcessIdentifier)
    return try store.getEntries(
      matching: NSPredicate(format: "subsystem = %@", bundleIdentifier)
    )
    .compactMap { $0 as? OSLogEntryLog }
  }

  @available(iOS 15.0, *)
  public static func export(
    bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "",
    to url: URL? = nil
  ) async throws -> URL {
    let content = try await export(bundleIdentifier: bundleIdentifier)
      .map { "[\($0.date.ISO8601Format())] [\($0.category)] \($0.composedMessage)" }
      .joined(separator: "\n")

    let url =
      url
      ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(
        "\(Date().ISO8601Format()).log")

    let data = content.data(using: .utf8)!
    try data.write(to: url)
    return url
  }
}
