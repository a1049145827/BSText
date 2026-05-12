//
//  BSTextLogger.swift
//  BSText
//
//  Lightweight logging utility for BSText 3.
//

import Foundation

/// Logging levels for BSText.
@objc public enum BSTextLogLevel: Int {
    /// No logging.
    case off = 0
    /// Error messages only.
    case error = 1
    /// Warning and error messages.
    case warning = 2
    /// Info, warning, and error messages.
    case info = 3
    /// All messages including debug.
    case debug = 4
}

/// Lightweight logger for BSText internal use.
@objcMembers
public final class BSTextLogger {

    /// The current log level.
    public static var level: BSTextLogLevel = .warning

    /// Log a debug message.
    /// - Parameter message: The message to log.
    public static func debug(_ message: String, file: String = #file, line: Int = #line) {
        log(level: .debug, message: message, file: file, line: line)
    }

    /// Log an info message.
    /// - Parameter message: The message to log.
    public static func info(_ message: String, file: String = #file, line: Int = #line) {
        log(level: .info, message: message, file: file, line: line)
    }

    /// Log a warning message.
    /// - Parameter message: The message to log.
    public static func warning(_ message: String, file: String = #file, line: Int = #line) {
        log(level: .warning, message: message, file: file, line: line)
    }

    /// Log an error message.
    /// - Parameter message: The message to log.
    public static func error(_ message: String, file: String = #file, line: Int = #line) {
        log(level: .error, message: message, file: file, line: line)
    }

    private static func log(level: BSTextLogLevel, message: String, file: String, line: Int) {
        guard level.rawValue <= BSTextLogger.level.rawValue else { return }
        let prefix = "[BSText.\(level)]"
        print("\(prefix) \(file):\(line) - \(message)")
    }
}
