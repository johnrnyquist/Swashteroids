import Swash

final class HyperSpaceNode: Node {
	required init() {
		super.init()
		components = [
			HyperSpaceJumpComponent.name: nil_component,
			HyperSpaceEngineComponent.name: nil_component,
			PositionComponent.name: nil_component,
			DisplayComponent.name: nil_component,
		]
	}
}
