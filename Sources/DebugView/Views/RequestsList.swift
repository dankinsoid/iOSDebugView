import SwiftUI

@available(iOS 14.0, *)
struct RequestList: View {

	var items: [RequestInfo]

	var body: some View {
		List(items) { item in
			NavigationLink {
				if #available(iOS 15.0, *) {
					DetailsNetworkLogs(item: item)
				}
			} label: {
				VStack(alignment: .leading, spacing: 0) {
					HStack(spacing: 4) {
						if item.response == nil {
							ProgressView()
						}

						Text(item.endpoint.url.scheme.hasPrefix("ws") ? "WS" : item.endpoint.method.rawValue.uppercased())
							.bold()

						Text("\(item.endpoint.url.path.joined(separator: "/"))")
							.foregroundColor(item.response == nil ? .gray : (item.error == nil ? .green : .red))
							.truncationMode(.head)
					}
					.font(.system(size: 18))

					Spacer(minLength: 0)

					Text("\(item.completionDate ?? item.requestingDate)")
						.font(.system(size: 14))
						.opacity(0.5)
				}
				.frame(height: 55)
			}
		}
	}
}
