import SwiftUI

public final class LoggerObject: ObservableObject, TextOutputStream {

	// MARK: Lifecycle

	private init() {
		logger = PrettyLogger()
	}

	// MARK: Public

	public static let shared = LoggerObject()

	@Published public var logger = PrettyLogger()

	public func write(_ string: String) {
		logger.write(string)
	}
}

public func log(
	tag: PrettyLogger.Tag = .debug,
	_ values: Any?...,
	comment: String? = nil,
	file: String = #fileID,
	function: String = #function,
	line: UInt = #line
) {
	LoggerObject.shared.logger.log(tag: tag, values: values, comment: comment, file: file, function: function, line: line)
}
