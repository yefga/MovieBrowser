//
//  LogLevel.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation
import os

public enum LogLevel: String {
    case debug, info, warning, error
}

public protocol AppLogger {
    func log(_ level: LogLevel, _ message: @autoclosure () -> String,
             file: StaticString, function: StaticString, line: UInt)
}

public extension AppLogger {
    func debug(_ message: @autoclosure () -> String,
               file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        log(.debug, message(), file: file, function: function, line: line)
    }
    func info(_ message: @autoclosure () -> String,
              file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        log(.info, message(), file: file, function: function, line: line)
    }
    func warn(_ message: @autoclosure () -> String,
              file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        log(.warning, message(), file: file, function: function, line: line)
    }
    func error(_ message: @autoclosure () -> String,
               file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        log(.error, message(), file: file, function: function, line: line)
    }
}

public struct DefaultLogger: AppLogger {
    private let logger: os.Logger

    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.yefga.MovieBrowser",
                category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    public func log(
        _ level: LogLevel,
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        let msg = "[\(level.rawValue.uppercased())] \(message()) (\(file):\(line) \(function))"
        switch level {
        case .debug: logger.debug("\(msg, privacy: .public)")
        case .info: logger.info("\(msg, privacy: .public)")
        case .warning: logger.warning("\(msg, privacy: .public)")
        case .error: logger.error("\(msg, privacy: .public)")
        }
    }
}
