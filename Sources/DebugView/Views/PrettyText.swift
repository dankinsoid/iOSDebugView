import SwiftPrettyPrint
import SwiftUI

public struct PrettyText: View {

	// MARK: Lifecycle

	public init(_ value: String) {
		self.value = value
	}

	// MARK: Public

	public var body: some View {
		TextCell(text ?? NSAttributedString(string: value))
			.onAppear {
				Task {
					let text = value.colorizedAttributed()
					await MainActor.run {
						self.text = text
					}
				}
			}
	}

	// MARK: Private

	private let value: String
	@State private var text: NSAttributedString?
}
