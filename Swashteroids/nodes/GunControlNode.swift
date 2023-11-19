import Swash

final class GunControlNode: Node {
    required init() {
        super.init()
        components = [
            MotionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            GunControlsComponent.name: nil_component,
            GunComponent.name: nil_component,
			InputComponent.name: nil_component
        ]
    }
}

