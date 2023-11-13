import Swash

class AsteroidCollisionNode: Node {
    required init() {
        super.init()
        components = [
            AudioComponent.name: nil_component,
            AsteroidComponent.name: nil_component,
            CollisionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            MotionComponent.name: nil_component,
        ]
    }
}
