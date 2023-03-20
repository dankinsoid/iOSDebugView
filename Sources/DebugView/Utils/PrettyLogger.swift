import Foundation
import SwiftPrettyPrint

public struct PrettyLogger: TextOutputStream {

	// MARK: Lifecycle

	// internal for testing only
	public init() {}

	// MARK: Public

	public struct Output: Codable, Equatable, Hashable, CustomStringConvertible, Identifiable {

		// MARK: Public

		public var id = UUID()
		public var message: String
		public var comment: String?
		public var tag: Tag
		public var timestamp: Date
		public var file: String
		public var function: String
		public var line: UInt

		public var description: String {
			"\(timestampString) \(tag) \(file) \(line) \(function)\n\(comment.map { "\($0)\n" } ?? "")\(message)"
		}

		public var timestampString: String {
			PrettyLogger.Output.dateFormatter.string(from: timestamp)
		}

		// MARK: Private

		private static let dateFormatter: DateFormatter = {
			let formatter = DateFormatter()
			formatter.dateFormat = "HH:mm:ss.SSSS"
			return formatter
		}()
	}

	public struct Tag: Equatable, Hashable, Codable, ExpressibleByStringInterpolation, CustomStringConvertible, Identifiable, Comparable {

		// MARK: Lifecycle

		public init(_ value: String) {
			self.value = value
		}

		public init(stringLiteral value: String.StringLiteralType) {
			self.value = String(stringLiteral: value)
		}

		public init(stringInterpolation: DefaultStringInterpolation) {
			self.init(String(stringInterpolation: stringInterpolation))
		}

		public init(from decoder: Decoder) throws {
			value = try String(from: decoder)
		}

		// MARK: Public

		public static let debug: Tag = "DEBUG"
		public static let info: Tag = "INFO"
		public static let notice: Tag = "NOTICE"
		public static let warning: Tag = "WARNING"
		public static let error: Tag = "ERROR"
		public static let critical: Tag = "CRITICAL"
		public static let alert: Tag = "ALERT"
		public static let emergency: Tag = "EMERGENCY"

		public var value: String

		public var id: String { value }
		public var description: String { value }

		public static func < (lhs: PrettyLogger.Tag, rhs: PrettyLogger.Tag) -> Bool {
			lhs.value < rhs.value
		}

		public func encode(to encoder: Encoder) throws {
			try value.encode(to: encoder)
		}
	}

	public private(set) var outputs: [Output] = []

	public mutating func log(
		tag: Tag,
		values: [Any?],
		comment: String? = nil,
		file: String,
		function: String,
		line: UInt
	) {
		var output = Output(
			message: string(for: values, colorized: true),
			comment: comment,
			tag: tag,
			timestamp: timestamp(),
			file: file,
			function: function,
			line: line
		)
		outputs.append(output)
		if !Pretty.consoleSupportsColors {
			output.message = string(for: values, colorized: false)
			Pretty.prettyPrint(output)
		} else {
			Pretty.prettyPrint(output, option: Pretty.Option(colored: true))
		}
	}

	public mutating func log(
		tag: Tag = .debug,
		_ values: Any?...,
		comment: String? = nil,
		file: String = #fileID,
		function: String = #function,
		line: UInt = #line
	) {
		log(tag: tag, values: values, comment: comment, file: file, function: function, line: line)
	}

	public mutating func write(_ string: String) {
		log(string)
	}

	// MARK: Private

	private func string(for values: [Any?], colorized: Bool) -> String {
		var message: [String] = []
		let options = Pretty.Option(colored: colorized)
		values.enumerated().forEach {
			var string = ""
			Pretty.prettyPrint($0.element as Any, option: options, to: &string)
			if string.hasSuffix("\n") {
				string.removeLast()
			}
			message.append(string)
		}
		if message.contains(where: { $0.contains("\n") }) {
			return message.joined(separator: "\n")
		} else {
			return message.joined(separator: " ")
		}
	}

	private func timestamp() -> Date {
		Date()
	}
}

public extension Pretty {

	static var consoleSupportsColors: Bool {
		ProcessInfo.processInfo.environment["Colorized_Output"] == "true"
	}
}
