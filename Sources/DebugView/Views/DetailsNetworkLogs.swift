import SwiftHttp
import SwiftUI
import VDCodable

@available(iOS 15.0, *)
struct DetailsNetworkLogs: View {

	// MARK: Internal

	var item: RequestInfo

	var body: some View {
		let query = item.endpoint.url.query
		return List {
			Section {
				Text("\(item.line) ").foregroundColor(.orange) + Text(item.file.dropProjectPath())
				Text(item.file.dropProjectPath())
			}

			Section {
				if item.response == nil {
					ProgressView()
				} else {
					TextHeader(text: item.error == nil ? "Success" : "Failure")
						.foregroundColor(item.error == nil ? .green : .red)
				}
				if let error = item.error {
					TextCell("\(error)")
				}
			}

			Section {
				KeyValueView(key: "Url", value: item.endpoint.url.url.absoluteString)
				if let response = item.response {
					KeyValueView(key: "Status code", value: "\(response.statusCode.rawValue)")
				}
				KeyValueView(key: "Time", value: dateFormatter.string(from: item.requestingDate))
				if let date = item.completionDate {
					KeyValueView(key: "Duration", value: "\(date.timeIntervalSince(item.requestingDate))")
				}
			} header: {
				TextHeader(text: "Info")
			}

			if !query.isEmpty {
				Section {
					ForEach(Array(query), id: \.key) {
						KeyValueView(key: $0.key, value: "\($0.value)")
					}
				} header: {
					TextHeader(text: "Query parameters")
				}
			}
			if !item.endpoint.headers.isEmpty {
				Section {
					ForEach(Array(item.endpoint.headers), id: \.key) {
						KeyValueView(key: $0.key.rawValue, value: $0.value)
					}
				} header: {
					TextHeader(text: "Headers")
				}
			}
			if item.response?.headers.isEmpty == false {
				Section {
					ForEach(item.response?.headers.sorted(by: { $0.key.rawValue < $1.key.rawValue }) ?? [], id: \.key) {
						KeyValueView(key: $0.key.rawValue, value: $0.value)
					}
				} header: {
					TextHeader(text: "Response headers")
				}
			}
			if let reqBody = requestBody {
				Section {
					JSONView(reqBody)
				} header: {
					TextHeader(text: "Body")
				}
			}
			if let resBody = responseBody {
				Section {
					JSONView(resBody)
				} header: {
					TextHeader(text: "Response body")
				}
			}
		}
		.listStyle(GroupedListStyle())
		.padding(.vertical, 16)
		.padding(.horizontal, 5)
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarTitle(item.endpoint.url.path.joined(separator: "/"))
		.onChange(of: item.id) { _ in
			update()
		}
		.onChange(of: item.response == nil) { _ in
			updateResponse()
		}
		.onAppear(perform: update)
	}

	// MARK: Private

	@State private var requestBody: JSON?
	@State private var responseBody: JSON?
	@State private var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
		return formatter
	}()

	private func update() {
		requestBody = nil
		responseBody = nil
		DispatchQueue.global().async {
			let requestBody = (item.endpoint.body).flatMap(body(item:))
			let responseBody = (item.response?.data).flatMap(body(item:))
			guard requestBody != nil || responseBody != nil else { return }
			DispatchQueue.main.async {
				self.requestBody = requestBody
				self.responseBody = responseBody
			}
		}
	}

	private func updateResponse() {
		responseBody = nil
		DispatchQueue.global().async {
			let responseBody = (item.response?.data).flatMap(body(item:))
			guard responseBody != nil else { return }
			DispatchQueue.main.async {
				self.responseBody = responseBody
			}
		}
	}

	private func body(item: Data) -> JSON? {
		try? JSON(from: item)
//		let code = NSMutableAttributedString(string: item.prettyPrintedJSONString)
//		highlighter.highlight(code, as: .json)
//		return code
	}
}

struct TextHeader: View {
	let text: String

	var body: some View {
		Text(text)
			.font(.system(size: 22, weight: .medium))
			.frame(height: 34)
	}
}

extension String {
	func dropProjectPath() -> String {
		components(separatedBy: "/").suffix(3).joined(separator: "/")
	}
}
