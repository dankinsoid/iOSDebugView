import Foundation
import SwiftHttp

public struct RequestInfo: Identifiable {

	// MARK: Lifecycle

	public init(
    endpoint: HttpRequest,
    response: HttpResponse? = nil,
    error: String? = nil,
    requestingDate: Date,
    completionDate: Date? = nil,
    file: String,
    line: Int
  ) {
		id = RequestID(file: file, line: line, url: endpoint.url.url)
		self.endpoint = endpoint
		self.response = response
		self.error = error
		self.requestingDate = requestingDate
		self.completionDate = completionDate
		self.file = file
		self.line = line
	}

	// MARK: Public

	public var id: RequestID
	public var endpoint: HttpRequest
	public var response: HttpResponse?
	public var error: String?
	public var requestingDate: Date
	public var completionDate: Date?
	public var file: String
	public var line: Int
}

public struct RequestID: Hashable {

	var file: String
	var line: Int
	var url: URL
}
