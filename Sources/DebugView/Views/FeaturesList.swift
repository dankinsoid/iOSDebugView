import SwiftUI

@available(iOS 14.0, *)
struct FeaturesList: View {

	@ObservedObject var viewModel: FeaturesService

	var body: some View {
		List(viewModel.features) { feature in
			Toggle(
				feature.title,
				isOn: Binding(
					get: { viewModel.isEnabled(feature.key) },
					set: { viewModel.setEnabled($0, for: feature.key) }
				)
			)
		}
	}
}
