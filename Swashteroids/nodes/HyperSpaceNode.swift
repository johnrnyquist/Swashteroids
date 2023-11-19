import Swash

final class HyperSpaceNode: Node {
	required init() {
		super.init()
		components = [
			HyperSpaceComponent.name: nil_component,
			PositionComponent.name: nil_component,
			InputComponent.name: nil_component
		]
	}
}
