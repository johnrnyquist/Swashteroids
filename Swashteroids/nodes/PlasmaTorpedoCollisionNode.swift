import Swash

final class PlasmaTorpedoCollisionNode: Node {
    required init() {
        super.init()
        components = [
            PlasmaTorpedoComponent.name: nil_component,
            CollisionComponent.name: nil_component,
            PositionComponent.name: nil_component,
        ]
    }
}
