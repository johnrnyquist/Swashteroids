import Swash

final class ShipControlsStateNode: Node {
	required init() {
		super.init()
		components = [
			ChangeShipControlsStateComponent.name: nil_component,
		]
	}
}
