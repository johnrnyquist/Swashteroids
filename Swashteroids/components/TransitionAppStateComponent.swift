import Swash


final class TransitionAppStateComponent: Component {
	var from: AppState?
	var to: AppState

	init(to: AppState, from: AppState? = nil) {
		self.from = from
		self.to = to
	}
}

