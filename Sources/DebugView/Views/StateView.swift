import SwiftUI
import VDCodable

@available(iOS 15.0, *)
struct JSONView: View {

	let json: JSON
	private let prefix: Text
	private let nestedLevel: Int
	private let needComma: Bool
	private var comma: Text { Text(needComma ? "," : "") }
	@State private var isOpened = true
	@Environment(\.jsonAttributes) var jsonAttributes

	init(
		_ json: JSON,
		prefix: Text = Text(""),
		nestedLevel: Int = 0,
		needComma: Bool = false
	) {
		self.json = json
		self.prefix = prefix
		self.nestedLevel = nestedLevel
		self.needComma = needComma
	}

	init(
		_ encodable: Encodable,
		prefix: Text = Text(""),
		nestedLevel: Int = 0,
		needComma: Bool = false
	) {
		self.init(encodable.asJSON, prefix: prefix, nestedLevel: nestedLevel, needComma: needComma)
	}

	var body: some View {
		HStack(spacing: 0) {
			Text("  ")
			if isOpened, canBeOpened {
				VStack(spacing: 0) {
					Text(" ")
					(bracketsAttributes.foregroundColor ?? Color.clear)
						.frame(width: 1)
						.opacity(0.4)
					Text(" ")
				}
				.containerShape(Rectangle())
				.onTapGesture {
					isOpened.toggle()
				}
				.padding(.trailing, -1)
			}
			jsonBody
		}
	}

	@ViewBuilder
	private var jsonBody: some View {
		switch json {
		case let .bool(value):
			text(prefix, text("\(value)", .boolean), comma)
		case let .number(value):
			text(prefix, text("\(value)", .number), comma)
		case let .string(value):
			text(prefix, text("\"\(value)\"", .string), comma)
		case let .array(value): nested(
				prefix: prefix + bracket("["),
				suffix: bracket("]") + comma
			) {
				ForEach(Array(value.enumerated()), id: \.offset) { offset, item in
					JSONView(item, nestedLevel: nestedLevel + 1, needComma: offset < value.count - 1)
				}
			}
		case let .object(value): nested(
				prefix: prefix + bracket("{"),
				suffix: bracket("}") + comma
			) {
				ForEach(Array(value.sorted(by: { $0.key < $1.key }).enumerated()), id: \.element.key) { offset, pair in
					JSONView(
						pair.value,
						prefix: text("\"\(pair.key)\"", jsonAttributes.key) + Text(": "),
						nestedLevel: nestedLevel + 1,
						needComma: offset < value.count - 1
					)
				}
			}
		case .null: text(prefix, text("null", .null), comma)
		}
	}

	@ViewBuilder
	private func nested(
		prefix: Text,
		suffix: Text,
		@ViewBuilder opened: () -> some View
	) -> some View {
		if isOpened, canBeOpened {
			LazyVStack(alignment: .leading, spacing: 0) {
				text(prefix)
					.onTapGesture {
						isOpened.toggle()
					}
				opened()
					.transition(.opacity)
				text(suffix)
			}
		} else {
			if canBeOpened {
				HStack(spacing: 0) {
					text(prefix, Text(" \(json.count) "), suffix)
				}.onTapGesture {
					isOpened.toggle()
				}
			} else {
				text(prefix, suffix)
			}
		}
	}

	private func text(_ text: Text...) -> Text {
		text.reduce(Text(""), +)
	}

	private func text(_ value: String, _ kind: JSON.Kind) -> Text {
		text(value, jsonAttributes.value[kind] ?? AttributeContainer())
	}

	private func text(_ value: String, _ attributes: AttributeContainer) -> Text {
		Text(AttributedString(value, attributes: attributes))
	}

	private func bracket(_ value: String) -> Text {
		text(value, bracketsAttributes)
	}

	private var bracketsAttributes: AttributeContainer {
		guard !jsonAttributes.bracketsAttributes.isEmpty else {
			return AttributeContainer()
		}
		return jsonAttributes.bracketsAttributes[nestedLevel % jsonAttributes.bracketsAttributes.count]
	}

	private var canBeOpened: Bool {
		switch json {
		case let .array(value): return !value.isEmpty
		case let .object(value): return !value.isEmpty
		default: return false
		}
	}
}

@available(iOS 15.0, *)
struct JSONAttributes {

	let key: AttributeContainer
	let value: [JSON.Kind: AttributeContainer]
	let bracketsAttributes: [AttributeContainer]
}

@available(iOS 15.0, *)
extension EnvironmentValues {

	var jsonAttributes: JSONAttributes {
		get { self[JSONAttributesKey.self] }
		set { self[JSONAttributesKey.self] = newValue }
	}

	private enum JSONAttributesKey: EnvironmentKey {

		static let defaultValue = JSONAttributes(
			key: AttributeContainer()
				.foregroundColor(Color(hue: 234.0 / 360, saturation: 0.62, brightness: 0.99)),
			value: [
				.boolean: AttributeContainer()
					.foregroundColor(Color(hue: 334.0 / 360, saturation: 0.62, brightness: 0.99)),
				.number: AttributeContainer()
					.foregroundColor(Color(hue: 5.0 / 36, saturation: 0.49, brightness: 0.81)),
				.string: AttributeContainer()
					.foregroundColor(Color(hue: 5.0 / 360, saturation: 0.63, brightness: 0.99)),
				.null: AttributeContainer()
					.foregroundColor(Color(hue: 334.0 / 360, saturation: 0.62, brightness: 0.99)),
			],
			bracketsAttributes: [
				AttributeContainer()
					.foregroundColor(Color.green),
				AttributeContainer()
					.foregroundColor(Color.blue),
				AttributeContainer()
					.foregroundColor(Color.purple),
				AttributeContainer()
					.foregroundColor(Color.orange),
				AttributeContainer()
					.foregroundColor(Color.red),
			]
		)
	}
}
