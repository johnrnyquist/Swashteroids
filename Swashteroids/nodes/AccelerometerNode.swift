import Swash

class AccelerometerNode: Node {
	required init() {
		super.init()
		components = [
			AccelerometerComponent.name: nil_component,
			InputComponent.name: nil_component,
			MotionControlsComponent.name: nil_component,
			PositionComponent.name: nil_component,
		]
	}
}

