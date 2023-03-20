import SwiftPrettyPrint
import SwiftUI

public final class ActionsLogsService: ObservableObject {

	// MARK: Lifecycle

	private init() {}

	// MARK: Public

	public static let shared = ActionsLogsService()

	public func add(action: Any) {
		let string = (action as? CustomStringConvertible)?.description ?? Pretty.prettyString(for: action)
		DispatchQueue.main.async { [self] in
			actions.append(string)
		}
	}

	// MARK: Internal

	@Published private(set) var actions: [String] = []
}
