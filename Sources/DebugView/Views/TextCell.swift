import SwiftUI

struct TextCell: View {

	// MARK: Lifecycle

	init(_ text: String) {
		self.text = NSAttributedString(string: text)
	}

	init(_ text: NSAttributedString) {
		self.text = text
	}

	// MARK: Internal

	let text: NSAttributedString
	@Environment(\.font) var font

	var body: some View {
		Group {
			if #available(iOS 15, *) {
				Text(AttributedString(text))
			} else {
				Text(text.string)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.fixedSize(horizontal: false, vertical: true)
		.padding(.vertical, 1)
		.padding(.horizontal, 5)
		.onTapGesture {
			UIPasteboard.general.string = text.string
		}
	}
}
