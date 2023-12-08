import Swash

final class TransitionAppStateNode: Node {
	required init() {
		super.init()
		components = [
			AppStateComponent.name: nil_component,
			TransitionAppStateComponent.name: nil_component,
		]
	}
}
