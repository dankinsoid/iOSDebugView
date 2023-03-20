import Foundation

public final class FeaturesService: ObservableObject {

	@Published public private(set) var features: [Feature] = []
	@Published public var isEnabled: Bool
	private var isLoaded = false
	private let cacheKey = "features"
	private let onUpdate: ((Feature) -> Void)?

	public init(
		features: [Feature] = [],
		isEnabled: Bool = false,
		onUpdate: ((Feature) -> Void)? = nil
	) {
		self.features = features
		self.isEnabled = isEnabled
		self.onUpdate = onUpdate
	}

	public func isEnabled(_ key: FeatureKey) -> Bool {
		guard isEnabled else { return false }
		load()
		return features.first { $0.key == key }?.isEnabled ?? false
	}

	public func setEnabled(_ enabled: Bool, for key: FeatureKey) {
		guard isEnabled else { return }
		load()
		guard let index = features.firstIndex(where: { $0.key == key }) else { return }
		features[index].isEnabled = enabled
		save()
		onUpdate?(features[index])
	}

	private func save() {
		let dictionary = Dictionary(features.map { ($0.key.rawValue, $0.isEnabled) }) { _, new in new }
		try? UserDefaults.standard.set(PropertyListEncoder().encode(dictionary), forKey: cacheKey)
	}

	private func load() {
		guard !isLoaded else { return }
		isLoaded = true
		guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return }
		guard let dictionary = try? PropertyListDecoder().decode([String: Bool].self, from: data) else { return }
		features = features.map { feature in
			var feature = feature
			feature.isEnabled = dictionary[feature.key.rawValue] ?? feature.isEnabled
			return feature
		}
	}
}
