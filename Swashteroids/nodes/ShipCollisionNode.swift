import Swash

final class ShipCollisionNode: Node {
    required init() {
        super.init()
        components = [
            CollisionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            ShipComponent.name: nil_component,
            MotionComponent.name: nil_component,
            AudioComponent.name: nil_component,
        ]
    }
}
