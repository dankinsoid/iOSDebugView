import SwiftUI

@available(iOS 14.0, *)
struct LoggsList: View {

	// MARK: Lifecycle

	init(_ logger: LoggerObject = .shared, filter: String = "") {
		_logger = ObservedObject(initialValue: logger)
		self.filter = filter
	}

	// MARK: Internal

	@ObservedObject var logger: LoggerObject

	var body: some View {
		ScrollView {
			LazyVStack(spacing: 5) {
				ScrollView(.horizontal) {
					HStack(alignment: .center, spacing: 4) {
						ForEach(Set(logger.logger.outputs.map { $0.tag }).sorted()) { tag in
							Button {
								withAnimation {
									if unselectedTags.contains(tag) {
										unselectedTags.remove(tag)
									} else {
										unselectedTags.insert(tag)
									}
								}
							} label: {
								Text(tag.value.uppercased())
									.padding(4)
									.background(unselectedTags.contains(tag) ? Color.clear : color(for: tag))
									.overlay(
										RoundedRectangle(cornerRadius: 4)
											.stroke(color(for: tag), lineWidth: 2)
									)
									.cornerRadius(4)
									.foregroundColor(unselectedTags.contains(tag) ? color(for: tag) : back)
									.font(.system(size: 12))
							}
						}
					}
					.padding(.vertical, 6)
				}

				ForEach(array, id: \.1.id) { output in
					item(output: output)
				}
			}
		}
		.background(back.ignoresSafeArea())
	}

	// MARK: Private

	private let filter: String
	@State private var attributed = Wrapper()
	@State private var unselectedTags: Set<PrettyLogger.Tag> = []

	private var array: [(Int, PrettyLogger.Output)] {
		filtered.reversed().enumerated().map { ($0.offset, $0.element) }
	}

	private var back: Color {
		Color(#colorLiteral(red: 0.06086101395, green: 0.06086101395, blue: 0.06086101395, alpha: 1))
	}

	private var filtered: [PrettyLogger.Output] {
		guard !filter.isEmpty || !unselectedTags.isEmpty else { return logger.logger.outputs }
		guard !filter.isEmpty else { return logger.logger.outputs.filter { !unselectedTags.contains($0.tag) } }
		let value = filter.lowercased()
		return logger.logger.outputs.filter {
			!unselectedTags.contains($0.tag) && $0.message.lowercased().contains(value)
		}
	}

	private func string(output: PrettyLogger.Output) -> NSAttributedString {
		if let result = attributed.attributed[output.id] {
			return result
		}
		return output.message.colorizedAttributed(font: .systemFont(ofSize: 14))
	}

	private func color(for tag: PrettyLogger.Tag) -> Color {
		switch tag {
		case .debug: return .green
		case .info: return Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
		case .notice: return .orange
		case .warning: return .yellow
		case .error: return Color(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.2103752467, alpha: 1))
		case .critical: return Color(#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1))
		case .alert: return .purple
		case .emergency: return Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
		default: return .white
		}
	}

	private func item(output: (Int, PrettyLogger.Output)) -> some View {
		HStack(spacing: 0) {
			color(for: output.1.tag)
				.frame(width: 4)
				.cornerRadius(2)

			VStack(alignment: .leading, spacing: 6) {
				VStack(alignment: .leading, spacing: 0) {
					Text("\(output.1.timestampString)")
						.foregroundColor(.white.opacity(0.5))

					Text(output.1.file).foregroundColor(.yellow.opacity(0.8)) +
						Text(", \(output.1.line)").foregroundColor(.blue) +
						Text(", " + output.1.function).foregroundColor(.green)
				}
				.opacity(0.8)
				.multilineTextAlignment(.leading)
				.font(.system(size: 11))
				if let comment = output.1.comment {
					Text(comment)
						.foregroundColor(.white.opacity(0.8))
						.multilineTextAlignment(.leading)
						.font(.system(size: 11))
				}
				TextCell(string(output: output.1))
			}
			.padding(.horizontal, 4)
			.font(.system(size: 12))
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(4)
		.background(color(for: output.1.tag).opacity(0.05))
		//          .background(backColor(i: output.0))
		.transition(.opacity)
	}
}

private final class Wrapper {
	var attributed: [UUID: NSAttributedString] = [:]
}

@available(iOS 14.0, *)
struct LoggsList_Previews: PreviewProvider {
	static var previews: some View {
		LoggsList()
			.onAppear {
				log(tag: .error, EdgeInsets())
				log(tag: .critical, "Critical")
				log(EdgeInsets())
				log(tag: .warning, "Custom")
			}
	}
}
