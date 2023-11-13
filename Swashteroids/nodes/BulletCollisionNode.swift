import Swash

class BulletCollisionNode: Node {
    required init() {
        super.init()
        components = [
            BulletComponent.name: nil_component,
            CollisionComponent.name: nil_component,
            PositionComponent.name: nil_component,
        ]
    }
}
