import Combine
import SwiftHttp
import SwiftPrettyPrint
import SwiftUI

@available(iOS 14.0, *)
public struct DebugNavigation: View {

	// MARK: Lifecycle

	public init(
		allUrls: [(HttpUrl, String)],
		state: Encodable,
		baseUrl: Binding<HttpUrl>,
		featureService: FeaturesService
	) {
		self.allUrls = allUrls
		_baseUrl = baseUrl
		self.featureService = featureService
		self.state = state
	}

	// MARK: Public

	public var body: some View {
		NavigationView {
			firstPage
		}
	}

	// MARK: Internal

	enum Tabs: String, Hashable, Codable, CaseIterable {

		case network
//		case actions
		case state
		case logs
		case features
	}

	let allUrls: [(HttpUrl, String)]
	private let state: Encodable
	private let featureService: FeaturesService
	@Binding var baseUrl: HttpUrl

	// MARK: Private

	@State private var updater = false
	@State private var tab = Tabs.network
	@State private var search = ""
	@StateObject private var reqiestsLogsService: RequestLogsService = .shared
	@StateObject private var actionsLogsService: ActionsLogsService = .shared

	private var items: [RequestInfo] {
		reqiestsLogsService.requests
	}

	private var actions: [String] {
		actionsLogsService.actions
	}

	private var firstPage: some View {
		VStack(spacing: 0) {
			header
			switch tab {
			case .network:
				RequestList(items: filter(items, text: search))
					.transition(.move(edge: .leading))

			case .state:
				ScrollView(.vertical) {
					if #available(iOS 15.0, *) {
						JSONView(state)
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
							.padding()
					}
				}

			case .logs:
				LoggsList(filter: search)

			case .features:
				FeaturesList(viewModel: featureService)
			}
		}
		.listStyle(PlainListStyle())
		.navigationBarHidden(true)
	}

	@ViewBuilder
	private var header: some View {
		HStack(spacing: 0) {
			Picker(
				"",
				selection: Binding {
					allUrls.firstIndex(where: { $0.0.url == baseUrl.url }) ?? 0
				} set: {
					baseUrl = allUrls[$0].0
					updater.toggle()
				}
			) {
				ForEach(allUrls.indices, id: \.self) {
					Text(allUrls[$0].1).tag($0)
				}
			}
		}
		.padding()

		TextField("Искать", text: $search)
			.frame(height: 55)
			.textFieldStyle(RoundedBorderTextFieldStyle())
			.padding(5)

		Picker(
			"",
			selection: Binding {
				tab
			} set: {
				tab = $0
				search = ""
			}
			.animation(.default)
		) {
			ForEach(Tabs.allCases, id: \.rawValue) {
				Text($0.rawValue).tag($0)
			}
		}.pickerStyle(SegmentedPickerStyle())
	}

	private func filter(_ items: [RequestInfo], text: String) -> [RequestInfo] {
		guard !text.isEmpty else { return items }
		let value = text.lowercased()
		return items.filter {
			($0.endpoint.url.path.joined(separator: "/") + " " + $0.endpoint.method.rawValue).lowercased().contains(value)
		}
	}

	private func filter(_ actions: [String], text: String) -> [String] {
		guard !text.isEmpty else { return actions }
		let value = text.lowercased()
		return actions.filter { $0.lowercased().contains(value) }
	}
}
