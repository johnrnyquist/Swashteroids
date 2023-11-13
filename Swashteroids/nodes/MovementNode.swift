import Swash

class MovementNode: Node {
    required init() {
        super.init()
        components = [
            MotionComponent.name: nil_component,
            PositionComponent.name: nil_component,
        ]
    }
}
