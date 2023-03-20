import SwiftUI
import UIKit

struct KeyValueView: View {

	// MARK: Lifecycle

	init(key: String, value: NSAttributedString) {
		self.key = key
		self.value = value
	}

	init(key: String, value: String) {
		self = KeyValueView(key: key, value: NSAttributedString(string: value))
	}

	// MARK: Internal

	let key: String
	let value: NSAttributedString

	var body: some View {
		VStack(alignment: .leading) {
			Text(key)
				.opacity(0.5)
				.font(.system(size: 18))

			TextCell(value)
				.font(.system(size: 14))
		}
	}
}
