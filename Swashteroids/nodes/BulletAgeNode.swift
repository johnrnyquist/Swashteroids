import Swash

final class BulletAgeNode: Node {
    required init() {
        super.init()
        components = [
            PlasmaTorpedoComponent.name: nil_component,
        ]
    }
}
