import Foundation
import VDCodable

extension Encodable {

	var asJSON: JSON {
		(try? VDJSONEncoder().encodeToJSON(AnyEncodable(value: self))) ?? .null
	}
}

private struct AnyEncodable: Encodable {

	var value: Encodable

	func encode(to encoder: Encoder) throws {
		try value.encode(to: encoder)
	}
}
