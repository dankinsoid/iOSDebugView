import Foundation

public struct Feature: Equatable, Codable {

	public var key: FeatureKey
	public var title: String
	public var isEnabled: Bool

	public init(key: FeatureKey, title: String, isEnabled: Bool = false) {
		self.key = key
		self.title = title
		self.isEnabled = isEnabled
	}
}

extension Feature: Identifiable {

	public var id: FeatureKey { key }
}

public struct FeatureKey: Hashable, Codable, RawRepresentable, ExpressibleByStringLiteral {

	public var rawValue: String

	public init(rawValue: String) {
		self.init(rawValue)
	}

	public init(stringLiteral value: String) {
		self.init(value)
	}

	public init(_ rawValue: String) {
		self.rawValue = rawValue
	}

	public init(from decoder: Decoder) throws {
		try self.init(String(from: decoder))
	}

	public func encode(to encoder: Encoder) throws {
		try rawValue.encode(to: encoder)
	}
}
