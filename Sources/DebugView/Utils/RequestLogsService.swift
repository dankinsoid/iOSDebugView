import SwiftHttp
import SwiftUI

public final class RequestLogsService: ObservableObject {

	public static let shared = RequestLogsService()

	@Published public private(set) var requests: [RequestInfo] = []

	public func update(endpoint: HttpRequest, requestingDate: Date = Date(), file: String, line: Int) {
		let request = RequestInfo(endpoint: endpoint, requestingDate: requestingDate, file: file, line: line)
		DispatchQueue.main.async { [self] in
			requests.insert(request, at: 0)
		}
	}

	public func update(endpoint: HttpRequest, response: HttpResponse?, error: String?, completionDate: Date = Date(), file: String, line: Int) {
		let id = RequestID(file: file, line: line, url: endpoint.url.url)
		guard let i = requests.firstIndex(where: { $0.id == id }) else {
			return
		}
		var request = requests[i]
		request.response = response
		request.error = error
		request.completionDate = completionDate
		DispatchQueue.main.async { [self] in
			requests[i] = request
		}
	}

	public func clear() {
		DispatchQueue.main.async { [self] in
			requests.removeAll()
		}
	}
}
