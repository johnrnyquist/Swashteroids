import Swash

final class GameOverNode: Node {
	required init() {
		super.init()
		components = [
			AppStateComponent.name: nil_component,
			GameOverComponent.name: nil_component,
		]
	}
}
