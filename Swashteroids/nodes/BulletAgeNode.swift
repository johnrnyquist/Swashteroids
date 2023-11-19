import Swash

final class BulletAgeNode: Node {
    required init() {
        super.init()
        components = [
            BulletComponent.name: nil_component,
        ]
    }
}
