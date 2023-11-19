import Swash

final class GameOverNode: Node {
	required init() {
		super.init()
		components = [
			GameOverComponent.name: nil_component,
			InputComponent.name: nil_component
		]
	}
}
