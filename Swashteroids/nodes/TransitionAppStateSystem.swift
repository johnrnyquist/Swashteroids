import Swash

final class TransitionAppStateSystem: Node {
	required init() {
		super.init()
		components = [
			TransitionAppComponent.name: nil_component,
			TouchableComponent.name: nil_component,
		]
	}
}
